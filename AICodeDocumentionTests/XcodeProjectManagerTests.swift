//
//  XcodeProjectManagerTests.swift
//  AICodeDocumentionTests
//
//  Created by James Trigg on 17/03/2023.
//

import XCTest
@testable import AICodeDocumention

class XcodeProjectManagerTests: XCTestCase {
    var manager: XcodeProjectManager!

    override func setUp() {
        super.setUp()
        manager = XcodeProjectManager.shared
    }

    override func tearDown() {
        manager = nil
        super.tearDown()
    }
/*
    func testSelectProjectFolder() {
        let testBundle = Bundle(for: type(of: self))
        guard let testProjectURL = testBundle.url(forResource: "TestProject", withExtension: nil) else {
            XCTFail("Unable to find TestProject folder in test bundle.")
            return
        }

        let result = manager.selectProjectFolder()
        XCTAssertTrue(result, "selectProjectFolder should return true for a valid project folder.")
        XCTAssertNotNil(manager.projectURL, "projectURL should be set after selecting a valid project folder.")
        XCTAssertNotNil(manager.xcodeprojURL, "xcodeprojURL should be set after selecting a valid project folder.")
    }

    func testGenerateDocumentation() {
        let testBundle = Bundle(for: type(of: self))
        guard let testProjectURL = testBundle.url(forResource: "TestProject", withExtension: nil) else {
            XCTFail("Unable to find TestProject folder in test bundle.")
            return
        }

        _ = manager.selectProjectFolder()

        let documentation = manager.generateDocumentation(for: "All Targets")
        XCTAssertNotNil(documentation, "generateDocumentation should return non-nil value for a valid target.")
        XCTAssertFalse(documentation!.isEmpty, "Documentation should not be empty for a valid target.")
    }
 */
}
