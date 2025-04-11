//
//  Template.swift
//
//
//  Created by Tomasz on 19/01/2023.
//

import Foundation

public typealias TemplateVariables = [String:CustomStringConvertible]

public class Template {
    private var content: String = ""
    private let contentCache: String
    private var nestedContent: [String: String] = [:]
    private let nestPattern = #"(\[START)[(\s)+]([a-zA-Z0-9-_]+)\](.+?)(\[END\s[a-zA-Z0-9-_]+\])"#
    private let interpolation: TemplateInterpolation

    public init(raw: String, interpolation: TemplateInterpolation = .default) {
        self.contentCache = raw
        self.interpolation = interpolation
        self.reset()
    }

    @discardableResult
    public func reset() -> Template {
        self.content = self.contentCache
        self.nestedContent = [:]

        var nests = [String: String]()
        if let regex = try? NSRegularExpression(pattern: nestPattern, options: [.dotMatchesLineSeparators]) {
            let range = NSRange(location: 0, length: content.utf16.count)
            regex.enumerateMatches(in: self.content, options: [], range: range) { match, _, _ in
                guard let match = match else { return }
                guard match.numberOfRanges == 5 else { return }

                let nestName = self.subContent(from: match.range(at: 2))
                let nestContent = self.subContent(from: match.range(at: 3))
                self.nestedContent[nestName] = nestContent

                let nestStart = match.range(at: 1).lowerBound
                let nestEnd = match.range(at: 4).lowerBound + match.range(at: 4).length - 1
                nests[nestName] = self.subContent(from: nestStart, to: nestEnd)
            }
        }
        for txt in nests {
            self.content = self.content.replacingOccurrences(of: txt.value, with: self.nestTag(txt.key))
        }
        return self
    }

    private func subContent(from range: NSRange) -> String {
        let start = range.lowerBound
        let end = range.lowerBound + range.length - 1
        return self.subContent(from: start, to: end)
    }

    private func subContent(from: Int, to: Int) -> String {
        let start = self.content.index(self.content.startIndex, offsetBy: from)
        let end = self.content.index(self.content.startIndex, offsetBy: to)
        return "\(self.content[start...end])"
    }

    private func cleanOutput() {
        if let regex = try? NSRegularExpression(pattern: interpolation.pattern, options: []) {
            let range = NSRange(location: 0, length: content.utf16.count)
            self.content = regex.stringByReplacingMatches(in: self.content, options: [], range: range, withTemplate: "")
        }
    }

    private func nestTag(_ name: String) -> String {
        return interpolation.format("nest-\(name)")
    }

    @discardableResult
    public func assign(_ variables: TemplateVariables, inNest nestName: String) -> Template {
        if let nestContent = nestedContent[nestName] {
            var content = nestContent
            for variable in variables {
                content = content.replacingOccurrences(of: interpolation.format(variable.key), with: variable.value.description)
            }
            let nestTag = self.nestTag(nestName)
            self.content = self.content.replacingOccurrences(of: nestTag, with: "\(content)\(nestTag)")
        }
        return self
    }

    @discardableResult
    public func assign(_ model: Any, inNest nestName: String) -> Template {
        let mirror = Mirror(reflecting: model)
        var variables = TemplateVariables()
        mirror.children.forEach { child in
            if let key = child.label, let value = child.value as? CustomStringConvertible {
                variables[key] = value
            }
        }
        return self.assign(variables, inNest: nestName)
    }

    @discardableResult
    public func assign(_ key: String, _ value: CustomStringConvertible) -> Template {
        self.content = self.content.replacingOccurrences(of: interpolation.format(key), with: value.description)
        return self
    }
    
    public subscript(_ key: String) -> CustomStringConvertible? {
        set {
            guard let value = newValue else { return }
            assign(key, value)
        }
        get {
            nil
        }
    }
    
    @discardableResult
    public func assign(_ variables: TemplateVariables) -> Template {
        for variable in variables {
            self.assign(variable.key, variable.value)
        }
        return self
    }
    
    @discardableResult
    public func assign(_ model: Any) -> Template {
        let mirror = Mirror(reflecting: model)
        mirror.children.forEach { child in
            if let key = child.label, let value = child.value as? CustomStringConvertible {
                self.assign(key, value)
            }
        }
        return self
    }

    public var output: String {
        self.cleanOutput()
        return self.content
    }
}
