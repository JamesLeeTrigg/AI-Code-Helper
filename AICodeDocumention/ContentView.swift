import SwiftUI
import UniformTypeIdentifiers
import XcodeProj
import PathKit
import UniformTypeIdentifiers
#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension UTType {
    static var xcodeProject: UTType {
        UTType(importedAs: "com.apple.dt.xcode.project",
               conformingTo: .directory)
    }
}

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 15)
            .background(Color.blue)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
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
            Button(action: selectProjectFolder) {
                HStack {
                    Image(systemName: "folder")
                        .foregroundColor(.white)
                        .imageScale(.large)
                    Text("Select Xcode Project")
                }
            }
            .buttonStyle(CustomButtonStyle())
            
            if projectURL != nil || true {
                VStack(alignment: .leading, spacing: 10) {
                    VStack {
                        Text("Selected Target: \(selectedTarget)")
                        
                        Picker("Target", selection: $selectedTarget) {
                            pickerContent()
                        }
                        .pickerStyle(DefaultPickerStyle())
                    }
                    .id(UUID())
                    
                    Text("Selected Xcode Project: \(projectURL?.lastPathComponent ?? "None")")
                }
            
                Button(action: generateDocumentation) {
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundColor(.white)
                            .imageScale(.large)
                        Text("Generate Documentation")
                    }
                }.buttonStyle(CustomButtonStyle())
            }

            // copy the generated documentation to the clipboard
            // only show the button if there is documentation to copy
            if !documentText.isEmpty || true {
                Button(action : copyToClipboard) {
                    HStack {
                        Image(systemName: "doc.on.doc")
                            .foregroundColor(.white)
                            .imageScale(.large)
                        Text("Copy Documentation to Clipboard")
                    }
                }.buttonStyle(CustomButtonStyle())
                // Add the total word count label
                if !documentText.isEmpty {
                    Text("Total Word Count: \(wordCount)")
                        .padding(.top)
                }
            }

/*
            ScrollView {
                Text(documentText)
                    .padding()
            }
 */
        }
        .padding()
        .frame(minWidth: 600,minHeight: 400)
    }
    
    @ViewBuilder
    func pickerContent() -> some View {
        ForEach(projectTargets, id: \.self) {
            Text($0)
        }
    }
    
    
    private func copyToClipboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(documentText, forType: .string)
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
            let fileTypesHeadings: [String: String] = [
                "swift": "Swift File",
                "json": "JSON File",
                "txt": "Text File",
                "md": "Markdown File",
                // Add more file types and their headings here
            ]

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

                    let heading = fileTypesHeadings[fileType] ?? "Other File"
                    documentation += "\n\(heading): \(source.path ?? "Unnamed")\n\(fileContent)\n"

                    documentation += "\n\(heading)\n\(fileContent)\n"
                }
            }

            // Update the text view with the generated documentation
            documentText = documentation
            //print(documentText)
        } catch {
            print("Error generating documentation:", error)
        }
    }
    
    private var wordCount: Int {
        documentText.split(separator: " ").count
    }
    
    // Add this code to the end of the file, after the closing brace of ContentView
    #if DEBUG

    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
    #endif


}






