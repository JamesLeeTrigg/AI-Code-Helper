//
//  XcodeProjectManager.swift
//  AICodeDocumention
//
//  Created by James Trigg on 17/03/2023.
//

import XcodeProj
import PathKit
import UniformTypeIdentifiers
import AppKit

enum SubType: String, CaseIterable  {
    case swiftUIView = "SwiftUI View"
    case uiViewController = "UIKit ViewController"
    case networking = "Networking"
    case utility = "Utility"
    case manager = "Manager"
    case viewModel = "ViewModel"
    case service = "Service"
    case other = "Other"
}

struct FileItem: Identifiable {
    let id = UUID()
    let name: String
    let content: String
    var isSelected: Bool
    var wordCount: Int {
        return content.split(separator: " ").count
    }
    var subtype: SubType
}

class XcodeProjectManager: ObservableObject {
    static let shared = XcodeProjectManager()
    private init() {}
    
    @Published var projectURL: URL?
    @Published var xcodeprojURL: URL?
    @Published var projectTargets: [String] = []
    @Published var selectedTarget: String = "All Targets"
    @Published var documentText: String = "" {
        didSet {
            wordCount = documentText.split(separator: " ").count
        }
    }
    @Published var wordCount: Int = 0
    @Published var fileList: [FileItem] = []
    @Published var selectedSubtypes: Set<SubType> = []
    var uniqueSubTypesInFileItems: Set<SubType> {
        Set(fileList.map { $0.subtype })
    }


    
    func selectProjectFolder() {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [UTType.folder]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true

        if openPanel.runModal() == .OK, let url = openPanel.url {
            processSelectedProjectFolder(url: url)
        }
    }
    
    private func processSelectedProjectFolder(url: URL) {
        // Check if the selected folder contains an .xcodeproj package
        let xcodeprojURLs = (try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: []))?.filter { $0.pathExtension == "xcodeproj" }
        
        if let xcodeprojURL = xcodeprojURLs?.first {
            // Check if the .xcodeproj package contains a project.pbxproj file
            let pbxprojURL = xcodeprojURL.appendingPathComponent("project.pbxproj")
            
            if FileManager.default.fileExists(atPath: pbxprojURL.path) {
                // Save the selected .xcodeproj package URL for future use
                self.projectURL = url
                self.xcodeprojURL = xcodeprojURL
                
                // Load project targets
                loadProjectTargets()
            } else {
                // Display an error or alert, as the selected folder is not an Xcode project
                print("The selected folder does not contain an Xcode project")
            }
        } else {
            // Display an error or alert, as the selected folder does not contain an .xcodeproj package
            print("The selected folder does not contain an .xcodeproj package")
        }
    }
    
    private func loadProjectTargets() {
        guard let xcodeprojURL = xcodeprojURL else { return }
        
        do {
            let xcodeProject = try XcodeProj(path: .init(xcodeprojURL.path))
            let targets = xcodeProject.pbxproj.nativeTargets.map { $0.name }
            projectTargets = ["All Targets"] + targets
        } catch {
            print("Error loading project targets:", error)
        }
    }

    func generateDocumentation() {
        guard let projectURL = projectURL else { return }
        
        //fileList = [] // Reset fileList

        do {
            let xcodeProject = try XcodeProj(path: .init(projectURL.appendingPathComponent("\(projectURL.lastPathComponent).xcodeproj").path))
            let projectDirectoryPath = projectURL.path

            // Get the list of targets to process
            let targetsToProcess: [PBXNativeTarget]
            if selectedTarget == "All Targets" {
                targetsToProcess = xcodeProject.pbxproj.nativeTargets
            } else {
                targetsToProcess = xcodeProject.pbxproj.nativeTargets.filter { $0.name == selectedTarget }
            }

            var documentation = ""

            // Process each target
            for target in targetsToProcess {
                let sources = try target.sourceFiles()

                for source in sources {
                    guard let sourcePath = try source.fullPath(sourceRoot: projectDirectoryPath) else { continue }
                    let filePath = PathKit.Path(sourcePath)
                    if filePath.isDirectory { continue }
                    let fileContent = try String(contentsOfFile: filePath.string)
                    let subType = determineSubType(name: source.path ?? "Unnamed", content: fileContent)
                    let fileItem = FileItem(name: source.path ?? "Unnamed", content: fileContent, isSelected: true, subtype: subType)
                    fileList.append(fileItem) // Add file to fileList

                    documentation += "\n\(fileItem.name)\n\(fileContent)\n"
                }
            }

            // Update the documentText with the generated documentation
            documentText = documentation
        } catch {
            print("Error generating documentation:", error)
        }
    }

    func generateSelectedDocumentation() {
        let selectedFiles = fileList.filter { $0.isSelected }
        let documentation = selectedFiles.map { "\n\($0.name)\n\($0.content)\n" }.joined()
        
        // Update the documentText with the generated documentation
        documentText = documentation
    }
    
    func copyToClipboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(documentText, forType: .string)
    }
    
    private func determineSubType(name: String, content: String) -> SubType {
        if content.contains("import SwiftUI") && content.contains("struct") && content.contains(": View") {
            return .swiftUIView
        } else if content.contains("import UIKit") && content.contains("class") && content.contains(": UIViewController") {
            return .uiViewController
        } else if content.contains("import Foundation") && content.contains("class") && content.contains("Networking") {
            return .networking
        } else if content.contains("import Foundation") && content.contains("class") && content.contains("Utility") {
            return .utility
        } else if content.contains("import Foundation") && content.contains("class") && content.contains("Manager") {
            return .manager
        } else if content.contains("import Foundation") && content.contains("class") && content.contains("ViewModel") {
            return .viewModel
        } else if content.contains("import Foundation") && content.contains("class") && content.contains("Service") {
            return .service
        }
        return .other
    }
}

