//
//  SwiftInterfaceExtractor.swift
//  AICodeDocumention
//
//  Created by James Trigg on 22/03/2023.
//

import SwiftSyntaxParser
import Foundation
import SwiftSyntax

class SwiftInterfaceExtractor: SyntaxVisitor {
    private(set) var result: String = ""
    private var currentInterface: String = ""
    
    func extractPublicInterface(from source: String) throws -> String {
        let sourceFile = try SyntaxParser.parse(source: source)
        self.walk(sourceFile)
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        currentInterface = "class \(node.identifier.text) {"
        return .visitChildren
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        currentInterface = "struct \(node.identifier.text) {"
        return .visitChildren
    }

    override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        currentInterface = "protocol \(node.identifier.text) {"
        return .visitChildren
    }

    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        let shouldInclude = currentInterface.starts(with: "protocol") ||
            (node.modifiers?.contains(where: { modifier in
                modifier.name.text == "public" || modifier.name.text == "open"
            }) ?? false)

        if shouldInclude {
            let signature = node.signature.description.trimmingCharacters(in: .whitespacesAndNewlines)
            let funcName = node.identifier.text
            let modifierText = node.modifiers?.description.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            currentInterface += "\n    \(modifierText.isEmpty ? "" : "\(modifierText) ")func \(funcName)\(signature)"
        }
        return .skipChildren
    }

    override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        let shouldInclude = currentInterface.starts(with: "protocol") ||
            (node.modifiers?.contains(where: { modifier in
                modifier.name.text == "public" || modifier.name.text == "open"
            }) ?? false)

        if shouldInclude {
            let bindings = node.bindings
            let modifierText = node.modifiers?.description.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            currentInterface += "\n    \(modifierText.isEmpty ? "" : "\(modifierText) ")var \(bindings)"
        }
        return .skipChildren
    }

    override func visitPost(_ node: ClassDeclSyntax) {
        currentInterface += "\n}"
        result += currentInterface + "\n"
        currentInterface = ""
    }

    override func visitPost(_ node: StructDeclSyntax) {
        currentInterface += "\n}"
        result += currentInterface + "\n"
        currentInterface = ""
    }

    override func visitPost(_ node: ProtocolDeclSyntax) {
        currentInterface += "\n}"
        result += currentInterface + "\n"
        currentInterface = ""
    }


}
