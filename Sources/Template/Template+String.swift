//
//  Template+String.swift
//
//
//  Created by Tomasz on 01/07/2024.
//

import Foundation

extension Template: CustomStringConvertible {
    public var description: String {
        self.output
    }
}
