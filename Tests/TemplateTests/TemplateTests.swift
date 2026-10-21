import XCTest
@testable import Template

final class TemplateTests: XCTestCase {
    func testVariableNotAssigned() throws {
        let template = Template(raw: "{number}empty")
        XCTAssertEqual("empty", template.output)
    }

    func testStringAssignment() throws {
        let template = Template(raw: "{number}")
        template.assign(["number": "45"])
        XCTAssertEqual("45", template.output)
    }

    func testIntAssignment() throws {
        let template = Template(raw: "{number}")
        template.assign(["number": 45])
        XCTAssertEqual("45", template.output)
    }

    func testObjectAssignment() throws {
        struct ViewModel {
            let name: String
            let number: Int
        }
        let template = Template(raw: "{number} {name}")
        let model = ViewModel(name: "Tom", number: 45)
        template.assign(model)
        XCTAssertEqual("45 Tom", template.output)
    }

    func testNestAssignment() throws {
        let template = Template(raw: "{header}[START item]i{number}[END item]{footer}")
        template.assign(["header": "welcome", "footer": 120])
        for i in 1...3 {
            template.assign(["number": i], inNest: "item")
        }
        XCTAssertEqual("welcomei1i2i3120", template.output)
    }
    func testStringAssignmentWithEmoji() throws {
        let template = Template(raw: "🌿{number}")
        template.assign(["number": "45"])
        XCTAssertEqual("🌿45", template.output)
    }
    func testNestAssignmentWithEmoji() throws {
        let template = Template(raw: "🌿{header}[START item]i{number}[END item]{footer}")
        template.assign(["header": "welcome", "footer": 120])
        for i in 1...3 {
            template.assign(["number": i], inNest: "item")
        }
        XCTAssertEqual("🌿welcomei1i2i3120", template.output)
    }
    func testObjectAssignmentInNest() throws {
        struct ViewModel {
            let number: Int
        }
        let template = Template(raw: "{header}[START item]i{number}[END item]{footer}")
        template.assign(["header": "welcome", "footer": 120])
        for i in 1...3 {
            let model = ViewModel(number: i)
            template.assign(model, inNest: "item")
        }
        XCTAssertEqual("welcomei1i2i3120", template.output)
    }
    
    func testOptionalPropertiesInModel() throws {
        struct ViewModel {
            let name: String?
            let nickname: String?
            let age: Int??
        }
        let template = Template(raw: "[{name}][{nickname}][{age}]")
        template.assign(ViewModel(name: "Tom", nickname: nil, age: 30))
        XCTAssertEqual("[Tom][][30]", template.output)
    }

    func testOptionalPropertiesInNest() throws {
        struct ViewModel {
            let name: String
            let note: String?
        }
        let template = Template(raw: "[START item]{name}:{note};[END item]")
        template.assign(ViewModel(name: "a", note: "x"), inNest: "item")
        template.assign(ViewModel(name: "b", note: nil), inNest: "item")
        XCTAssertEqual("a:x;b:;", template.output)
    }

    func testSubscriptAssign() throws {
        let template = Template(raw: "{number}")
        template["number"] = 406
        XCTAssertEqual("406", template.output)
    }
}
