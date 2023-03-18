import SwiftUI

struct FileListView: View {
    @ObservedObject var manager: XcodeProjectManager
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        VStack {
            FileListToolbarView()
                .padding(.bottom)
            List {
                ForEach(manager.fileList) { file in
                    Button(action: {
                        toggleFileCheck(file: file)
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(file.name)
                                Text("\(file.wordCount) words")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Image(systemName: file.isSelected ? "checkmark.square" : "square")
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("File List")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        manager.generateSelectedDocumentation()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Generate Documentation")
                    }
                }
            }
        }
    }
    
    private func toggleFileCheck(file: FileItem) {
        if let index = manager.fileList.firstIndex(where: { $0.id == file.id }) {
            manager.fileList[index].isSelected.toggle()
        }
    }
    
    struct FileListView_Previews: PreviewProvider {
        static var previews: some View {
            let manager = XcodeProjectManager.shared
            manager.fileList = [
                FileItem(name: "File1.swift", content: "Some content", isSelected: true, subtype: .swiftUIView),
                FileItem(name: "File2.swift", content: "Another content", isSelected: false, subtype: .swiftUIView),
                FileItem(name: "File3.swift", content: "More content", isSelected: true, subtype: .swiftUIView)
            ]

            return NavigationStack {
                FileListView(manager: manager)
            }
        }
    }
}
