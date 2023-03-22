//
//  SwiftInterfaceExtractorTests.swift
//  AICodeDocumentionTests
//
//  Created by James Trigg on 22/03/2023.
//

import XCTest
@testable import AICodeDocumention

final class SwiftInterfaceExtractorTests: XCTestCase {
    var extractor: SwiftInterfaceExtractor!

    override func setUp() {
        super.setUp()
        extractor = SwiftInterfaceExtractor()
    }

    override func tearDown() {
        extractor = nil
        super.tearDown()
    }

    func testClassPublicInterfaceExtraction() throws {
        let input = """
        public class TestClass {
            public var publicVar: Int
            private var privateVar: Int
            public func publicFunc() -> Int { return 0 }
            private func privateFunc() { }
        }
        """

        let expectedOutput = """
        class TestClass {
            public var publicVar: Int
            public func publicFunc() -> Int
        }
        """

        let result = try extractor.extractPublicInterface(from: input)
        XCTAssertEqual(result, expectedOutput)
    }

    func testStructPublicInterfaceExtraction() throws {
        let source = """
            struct TestStruct {
                private var privateVar: Int
                public var publicVar: Int
                private func privateFunc() {}
                public func publicFunc() -> Int { return 0 }
            }
            """

        let expectedInterface = """
            struct TestStruct {
                public var publicVar: Int
                public func publicFunc() -> Int
            }
            """

        let extractedInterface = try extractor.extractPublicInterface(from: source)
        XCTAssertEqual(extractedInterface, expectedInterface)
    }

    func testProtocolPublicInterfaceExtraction() throws {
        let source = """
            protocol TestProtocol {
                var publicVar: Int { get }
                func publicFunc() -> Int
            }
            """

        let expectedInterface = """
            protocol TestProtocol {
                var publicVar: Int { get }
                func publicFunc() -> Int
            }
            """

        let extractedInterface = try extractor.extractPublicInterface(from: source)
        XCTAssertEqual(extractedInterface, expectedInterface)
    }

    func testMultiplePublicInterfaceExtraction() throws {
        let source = """
            class TestClass {
                public var classVar: Int
                public func classFunc() -> Int { return 0 }
            }

            struct TestStruct {
                public var structVar: Int
                public func structFunc() -> Int { return 0 }
            }

            protocol TestProtocol {
                var protocolVar: Int { get }
                func protocolFunc() -> Int
            }
            """

        let expectedInterface = """
            class TestClass {
                public var classVar: Int
                public func classFunc() -> Int
            }
            struct TestStruct {
                public var structVar: Int
                public func structFunc() -> Int
            }
            protocol TestProtocol {
                var protocolVar: Int { get }
                func protocolFunc() -> Int
            }
            """

        let extractedInterface = try extractor.extractPublicInterface(from: source)
        XCTAssertEqual(extractedInterface, expectedInterface)
    }
}

