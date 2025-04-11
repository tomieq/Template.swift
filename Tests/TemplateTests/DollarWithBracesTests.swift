//
//  DollarWithBracesTests.swift
//  Template
//
//  Created by Tomasz on 11/04/2025.
//

import XCTest
@testable import Template

final class DollarWithBracesTests: XCTestCase {
    func testVariableNotAssigned() throws {
        let template = Template(raw: "${number}empty", interpolation: .dollarWithBraces)
        XCTAssertEqual("empty", template.output)
    }

    func testStringAssignment() throws {
        let template = Template(raw: "${number}", interpolation: .dollarWithBraces)
        template.assign(["number": "45"])
        XCTAssertEqual("45", template.output)
    }

    func testIntAssignment() throws {
        let template = Template(raw: "${number}", interpolation: .dollarWithBraces)
        template.assign(["number": 45])
        XCTAssertEqual("45", template.output)
    }

    func testObjectAssignment() throws {
        struct ViewModel {
            let name: String
            let number: Int
        }
        let template = Template(raw: "${number} ${name}", interpolation: .dollarWithBraces)
        let model = ViewModel(name: "Tom", number: 45)
        template.assign(model)
        XCTAssertEqual("45 Tom", template.output)
    }

    func testNestAssignment() throws {
        let template = Template(raw: "${header}[START item]i${number}[END item]${footer}",
                                interpolation: .dollarWithBraces)
        template.assign(["header": "welcome", "footer": 120])
        for i in 1...3 {
            template.assign(["number": i], inNest: "item")
        }
        XCTAssertEqual("welcomei1i2i3120", template.output)
    }

    func testObjectAssignmentInNest() throws {
        struct ViewModel {
            let number: Int
        }
        let template = Template(raw: "${header}[START item]i${number}[END item]${footer}",
                                interpolation: .dollarWithBraces)
        template.assign(["header": "welcome", "footer": 120])
        for i in 1...3 {
            let model = ViewModel(number: i)
            template.assign(model, inNest: "item")
        }
        XCTAssertEqual("welcomei1i2i3120", template.output)
    }
    
    func testSubscriptAssign() throws {
        let template = Template(raw: "${number}", interpolation: .dollarWithBraces)
        template["number"] = 406
        XCTAssertEqual("406", template.output)
    }
}
