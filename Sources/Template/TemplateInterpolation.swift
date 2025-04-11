//
//  TemplateInterpolation.swift
//  Template
//
//  Created by Tomasz on 11/04/2025.
//

public enum TemplateInterpolation {
    case `default` // {value}
    case mustache // {{value}}
    case dollar // $value
    case dollarWithBraces // ${value}
}

extension TemplateInterpolation {
    var pattern: String {
        switch self {
        case .default:
            return "(\\{[a-zA-Z0-9-_]+\\})"
        case .mustache:
            return "(\\{\\{[a-zA-Z0-9-_]+\\}\\})"
        case .dollar:
            return "(\\$[a-zA-Z0-9-_]+)"
        case .dollarWithBraces:
            return "(\\$\\{[a-zA-Z0-9-_]+\\})"
        }
    }
    
    func format(_ key: String) -> String {
        switch self {
        case .default:
            return "{\(key)}"
        case .mustache:
            return "{{\(key)}}"
        case .dollar:
            return "$\(key)"
        case .dollarWithBraces:
            return "${\(key)}"
        }
    }
}
