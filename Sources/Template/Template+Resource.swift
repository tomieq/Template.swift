//
//  Template+Resource.swift
//
//
//  Created by Tomasz KUCHARSKI on 08/09/2023.
//

import Foundation

public extension Template {
    convenience init(from relativePath: String) {
        self.init(raw: Resource().content(for: relativePath))
    }
}
