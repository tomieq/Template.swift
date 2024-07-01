//
//  Cache.swift
//
//
//  Created by Tomasz KUCHARSKI on 08/09/2023.
//

import Foundation

class Cache {
    static let shared = Cache()
    var fileContents: [String: String] = [:]

    func get(relativePath: String) -> String? {
        self.get(absolutePath: Resource().absolutePath(for: relativePath))
    }
    
    func get(absolutePath: String) -> String? {
        if let cached = fileContents[absolutePath] {
            return cached
        }
        guard let content = try? String(contentsOfFile: absolutePath) else {
            return nil
        }
        self.fileContents[absolutePath] = content
        return content
    }
}
