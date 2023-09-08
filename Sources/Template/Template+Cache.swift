//
//  Template+Cache.swift
//
//
//  Created by Tomasz KUCHARSKI on 08/09/2023.
//

import Foundation

public extension Template {
    static func cahed(from relativePath: String) -> Template {
        Template(raw: Cache.shared.get(path: relativePath) ?? "")
    }
}
