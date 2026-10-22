import XCTest
@testable import Template

final class ResourceTests: XCTestCase {
    private var workingDir = ""

    override func setUpWithError() throws {
        workingDir = NSTemporaryDirectory() + "TemplateResourceTests-" + UUID().uuidString
        let fm = FileManager.default
        try fm.createDirectory(atPath: workingDir + "/Resources/public/css", withIntermediateDirectories: true)
        try fm.createDirectory(atPath: workingDir + "/Resources/login", withIntermediateDirectories: true)
        try "body {}".write(toFile: workingDir + "/Resources/public/css/style.css", atomically: true, encoding: .utf8)
        try "secret".write(toFile: workingDir + "/Resources/public/.hidden", atomically: true, encoding: .utf8)
        try "page".write(toFile: workingDir + "/Resources/login/page.tpl.html", atomically: true, encoding: .utf8)
        try "outside".write(toFile: workingDir + "/outside.txt", atomically: true, encoding: .utf8)
        try fm.createSymbolicLink(atPath: workingDir + "/Resources/public/link.txt",
                                  withDestinationPath: workingDir + "/outside.txt")
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(atPath: workingDir)
    }

    func testFindsFileInsideFolder() {
        let resource = Resource(workingDir: workingDir)
        let path = resource.existingFilePath(for: "css/style.css", inside: "public")
        XCTAssertEqual(path.map { URL(fileURLWithPath: $0).lastPathComponent }, "style.css")
    }

    func testLeadingSlashIsAccepted() {
        let resource = Resource(workingDir: workingDir)
        XCTAssertNotNil(resource.existingFilePath(for: "/css/style.css", inside: "public"))
    }

    func testRejectsTraversal() {
        let resource = Resource(workingDir: workingDir)
        XCTAssertNil(resource.existingFilePath(for: "../login/page.tpl.html", inside: "public"))
        XCTAssertNil(resource.existingFilePath(for: "css/../../../outside.txt", inside: "public"))
    }

    func testRejectsHiddenFilesDirectoriesAndMissingFiles() {
        let resource = Resource(workingDir: workingDir)
        XCTAssertNil(resource.existingFilePath(for: ".hidden", inside: "public"))
        XCTAssertNil(resource.existingFilePath(for: "css", inside: "public"))
        XCTAssertNil(resource.existingFilePath(for: "", inside: "public"))
        XCTAssertNil(resource.existingFilePath(for: "css/missing.css", inside: "public"))
    }

    func testRejectsBackslashAndNul() {
        let resource = Resource(workingDir: workingDir)
        XCTAssertNil(resource.existingFilePath(for: "css\\style.css", inside: "public"))
        XCTAssertNil(resource.existingFilePath(for: "css/style.css\0.png", inside: "public"))
    }

    func testRejectsSymlinkLeavingFolder() {
        let resource = Resource(workingDir: workingDir)
        XCTAssertNil(resource.existingFilePath(for: "link.txt", inside: "public"))
    }

    func testOtherFoldersAreNotReachable() {
        let resource = Resource(workingDir: workingDir)
        XCTAssertNil(resource.existingFilePath(for: "page.tpl.html", inside: "public"))
        XCTAssertNotNil(resource.existingFilePath(for: "page.tpl.html", inside: "login"))
    }
}
