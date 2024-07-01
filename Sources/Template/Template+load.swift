//
//  Template+Resource.swift
//
//
//  Created by Tomasz KUCHARSKI on 08/09/2023.
//

import Foundation

public extension Template {
    static func load(relativePath: String) -> Template {
        Template.load(absolutePath: Resource().absolutePath(for: relativePath))
    }

    static func load(absolutePath: String) -> Template {
        guard let content = try? String(contentsOfFile: absolutePath) else {
            print("Template.load: file not found at \(absolutePath)")
            return Template(raw: "")
        }
        return Template(raw: content)
    }
}
