//
//  Cache.swift
//
//
//  Created by Tomasz KUCHARSKI on 08/09/2023.
//

import Foundation

class Cache {
    static let shared = Cache()
    private var fileContents: [String: String] = [:]
    private let lock = NSLock()

    func get(relativePath: String) -> String? {
        self.get(absolutePath: Resource().absolutePath(for: relativePath))
    }

    func get(absolutePath: String) -> String? {
        self.lock.lock()
        defer { self.lock.unlock() }
        if let cached = self.fileContents[absolutePath] {
            return cached
        }
        guard let content = try? String(contentsOfFile: absolutePath) else {
            return nil
        }
        self.fileContents[absolutePath] = content
        return content
    }
}
