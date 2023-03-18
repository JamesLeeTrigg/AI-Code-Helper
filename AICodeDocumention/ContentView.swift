import SwiftUI

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
    let isPreview: Bool
    @ObservedObject private var manager = XcodeProjectManager.shared
    @State private var showingFileListView = false

    var body: some View {
        NavigationStack {
            VStack {
                Button(action: manager.selectProjectFolder) {
                    HStack {
                        Image(systemName: "folder")
                            .foregroundColor(.white)
                            .imageScale(.large)
                        Text("Select Xcode Project")
                    }
                }
                .buttonStyle(CustomButtonStyle())
                Text("Selected Xcode Project: \(manager.projectURL?.lastPathComponent ?? "None")")
                
                if manager.projectURL != nil || isPreview {
                    VStack(alignment: .center, spacing: 10) {
                        VStack {
                            Picker("Target", selection: $manager.selectedTarget) {
                                ForEach(manager.projectTargets, id: \.self) {
                                    Text($0)
                                }
                            }
                            .pickerStyle(DefaultPickerStyle())
                        }
                        .id(UUID())
                        
                        Button(action: {
                            manager.generateDocumentation()
                        }) {
                            HStack {
                                Image(systemName: "doc.text")
                                    .foregroundColor(.white)
                                    .imageScale(.large)
                                Text("Generate Documentation")
                            }
                        }.buttonStyle(CustomButtonStyle())
                        
                        
                    }
                }
                
                NavigationLink("Go to File List") {
                   FileListView(manager: manager)
                }
                .buttonStyle(CustomButtonStyle())
                .disabled(manager.fileList.isEmpty)
                
                if !manager.documentText.isEmpty || isPreview {
                    if(manager.wordCount < 20000) {
                        Button(action: manager.copyToClipboard) {
                            HStack {
                                Image(systemName: "doc.on.doc")
                                    .foregroundColor(.white)
                                    .imageScale(.large)
                                Text("Copy Documentation to Clipboard")
                            }
                        }.buttonStyle(CustomButtonStyle())
                    }
                    
                    Text("Total Word Count: \(manager.wordCount)")
                        .padding(.top)
                    
                }
            }
            .padding()
            .frame(minWidth: 600, minHeight: 400)
        }
    }
}

#if DEBUG

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(isPreview: true)
    }
}
#endif
