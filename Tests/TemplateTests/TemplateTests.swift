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

    func testNestAssignment() throws {
        let template = Template(raw: "{header}[START item]i{number}[END item]{footer}")
        template.assign(["header": "welcome", "footer": 120])
        for i in 1...3 {
            template.assign(["number": i], inNest: "item")
        }
        XCTAssertEqual("welcomei1i2i3120", template.output)
    }
}
