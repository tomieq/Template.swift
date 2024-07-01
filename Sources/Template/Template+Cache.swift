//
//  Template+Cache.swift
//
//
//  Created by Tomasz on 08/09/2023.
//

import Foundation

extension Template {
    public static func cahed(relativePath: String) -> Template {
        Template(raw: Cache.shared.get(relativePath: relativePath) ?? "")
    }

    public static func cahed(absolutePath: String) -> Template {
        Template(raw: Cache.shared.get(absolutePath: absolutePath) ?? "")
    }
}
