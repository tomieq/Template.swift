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
}
