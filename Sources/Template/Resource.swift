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

    public func content(for relativePath: String) -> String? {
        let resourcePath = absolutePath(for: relativePath)
        guard let content = try? String(contentsOfFile: resourcePath) else {
            print("Template.Resource: file not found at \(resourcePath)")
            return nil
        }
        return content
    }
}
