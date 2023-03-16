import SwiftUI
import UniformTypeIdentifiers
import XcodeProj
import PathKit
import UniformTypeIdentifiers

extension UTType {
    static var xcodeProject: UTType {
        UTType(importedAs: "com.apple.dt.xcode.project",
               conformingTo: .directory)
    }
}

struct ContentView: View {
    @State private var selectedTarget: String = "All Targets"
    @State private var projectTargets: [String] = []
    @State private var documentText: String = ""
    @State private var projectURL: URL?
    @State private var xcodeprojURL: URL?

    var body: some View {
        VStack {
            Button("Select Xcode Project") {
                selectProjectFolder()
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Selected Xcode Project: \(projectURL?.lastPathComponent ?? "None")")

                VStack {
                    Text("Selected Target: \(selectedTarget)")
                    
                    Picker("Target", selection: $selectedTarget) {
                        pickerContent()
                    }
                    .pickerStyle(DefaultPickerStyle())
                }
                .id(UUID())
            }


            Button("Generate Documentation") {
                generateDocumentation()
            }


            ScrollView {
                Text(documentText)
                    .padding()
            }
        }
        .padding()
    }
    
    @ViewBuilder
    func pickerContent() -> some View {
        ForEach(projectTargets, id: \.self) {
            Text($0)
        }
    }
    
    private func selectProjectFolder() {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [UTType.folder]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        
        if openPanel.runModal() == .OK, let url = openPanel.url {
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
    }

    private func loadProjectTargets() {
        guard let xcodeprojURL = xcodeprojURL else { return }
        
        print("xcodeprojURL = \(xcodeprojURL.description)")
        do {
            let xcodeProject = try XcodeProj(path: .init(xcodeprojURL.path))
            let targets = xcodeProject.pbxproj.nativeTargets.map { $0.name }
            projectTargets = ["All Targets"] + targets
        } catch {
            print("Error loading project targets:", error)
        }
    }

    private func generateDocumentation() {
        guard let projectURL = projectURL else { return }

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
                    let fileType = filePath.extension ?? ""
                    
                    // Filter out non-text based files
                    let allowedFileTypes = ["swift", "json", "txt", "md", "h", "m", "cpp", "c", "cs", "js", "css", "html", "xml", "yaml", "yml"]
                    guard allowedFileTypes.contains(fileType) else {
                        continue
                    }

                    let heading: String

                    switch fileType {
                    case "swift":
                        heading = "Swift File: \(source.path ?? "Unnamed")"
                    case "json":
                        heading = "JSON File: \(source.path ?? "Unnamed")"
                    default:
                        heading = "Other File: \(source.path ?? "Unnamed")"
                    }

                    documentation += "\n\(heading)\n\(fileContent)\n"
                }
            }

            // Update the text view with the generated documentation
            documentText = documentation
            print(documentText)
        } catch {
            print("Error generating documentation:", error)
        }
    }

}




