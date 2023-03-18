import SwiftUI

struct FileListView: View {
    @ObservedObject var manager: XcodeProjectManager
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
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
    
    private func toggleFileCheck(file: FileItem) {
        if let index = manager.fileList.firstIndex(where: { $0.id == file.id }) {
            manager.fileList[index].isSelected.toggle()
        }
    }
}
