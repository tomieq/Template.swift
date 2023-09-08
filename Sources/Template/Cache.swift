//
//  Cache.swift
//
//
//  Created by Tomasz KUCHARSKI on 08/09/2023.
//

import Foundation

class Cache {
    static let shared = Cache()
    var templates: [String: String] = [:]

    func get(path: String) -> String {
        if let cached = templates[path] {
            return cached
        }
        let content = Resource().content(for: path)
        self.templates[path] = content
        return content
    }
}
