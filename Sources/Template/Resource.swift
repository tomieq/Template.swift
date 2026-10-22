//
//  Resource.swift
//
//
//  Created by Tomasz KUCHARSKI on 08/09/2023.
//

import Foundation

public struct Resource {
    let workingDir: String

    public init(workingDir: String = FileManager.default.currentDirectoryPath) {
        self.workingDir = workingDir
    }

    public func absolutePath(for relativePath: String) -> String {
        "\(self.workingDir)/Resources/\(relativePath)"
    }

    /// Absolute path of an existing regular file inside `<workingDir>/Resources/<folder>`, safe to serve for untrusted input.
    /// Returns `nil` for traversal (`..`), hidden (dot-prefixed) segments, backslashes, NUL, directories,
    /// missing files and symlinks that lead outside the folder.
    public func existingFilePath(for relativePath: String, inside folder: String) -> String? {
        let segments = relativePath.split(separator: "/")
        guard !segments.isEmpty,
              segments.allSatisfy({ !$0.hasPrefix(".") && !$0.contains("\\") && !$0.contains("\0") }) else {
            return nil
        }
        let root = URL(fileURLWithPath: absolutePath(for: folder)).resolvingSymlinksInPath().path
        let candidate = URL(fileURLWithPath: root + "/" + segments.joined(separator: "/")).resolvingSymlinksInPath().path
        var isDirectory: ObjCBool = false
        guard candidate.hasPrefix(root + "/"),
              FileManager.default.fileExists(atPath: candidate, isDirectory: &isDirectory),
              !isDirectory.boolValue else {
            return nil
        }
        return candidate
    }

    public func content(for relativePath: String) -> String? {
        let resourcePath = absolutePath(for: relativePath)
        guard let content = try? String(contentsOfFile: resourcePath) else {
            print("Template.Resource: file not found at \(resourcePath)")
            return nil
        }
        return content
    }
}
