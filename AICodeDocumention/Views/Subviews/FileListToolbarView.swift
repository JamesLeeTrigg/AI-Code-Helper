//
//  FileListToolbarView.swift
//  AICodeDocumention
//
//  Created by James Trigg on 18/03/2023.
//

import SwiftUI

enum FileListToolbarSelectedOption: String, CaseIterable {
    case selectAll = "Select All"
    case selectNone = "Select None"
    case toggleViews = "Toggle Views"
    case toggleFileTypes = "Toggle File Types"
    case none = "None"
}

struct FileListToolbarView: View {
    @ObservedObject private var manager = XcodeProjectManager.shared
    @State private var selectedOption : FileListToolbarSelectedOption = .none

    var body: some View {
        VStack {
            HStack(spacing: 20) {
                createButton(
                    icon: "checkmark.circle",
                    label: "Select All",
                    action: {
                        self.selectedOption = .selectAll
                        manager.selectAll()
                    },
                    tooltip: "Select all files"
                )
                createButton(
                    icon: "xmark.circle",
                    label: "Select None",
                    action: {
                        self.selectedOption = .selectNone
                        manager.selectNone()
                    },
                    tooltip: "Deselect all files"
                )
                createButton(
                    icon: "arrow.triangle.2.circlepath.circle",
                    label: "Toggle Views",
                    action: {
                        self.selectedOption = .toggleViews
                        manager.toggleViews()
                    },
                    tooltip: "Toggle between views"
                )
                createButton(
                    icon: "doc.text",
                    label: "Toggle File Types",
                    action: {
                        // toggle between none and toggleFileTypes
                        self.selectedOption = self.selectedOption != .toggleFileTypes ? .toggleFileTypes : .none
                    },
                    tooltip: "Toggle between file types"
                )
            }
            
            if selectedOption == .toggleFileTypes {
                FileTypeSelectionView()
            }
            
        }
    }

    func createButton(icon: String, label: String, action: @escaping () -> Void, tooltip: String) -> some View {
            Button(action: action) {
                VStack(alignment: .center, spacing: 2) {
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    Text(label)
                        .font(.caption)
                }
                .frame(width: 100, height: 50)
            }
            .buttonStyle(BorderlessButtonStyle())
            .help(tooltip)
        }
    
    struct FileListToolbarView_Previews: PreviewProvider {
        static var previews: some View {
            let manager = XcodeProjectManager.shared
            manager.fileList = [
                FileItem(name: "File1.swift", content: "Some content", isSelected: true, subtype: .swiftUIView, interface: "class test"),
                FileItem(name: "File2.swift", content: "Another content", isSelected: false, subtype: .swiftUIView, interface: "class test"),
                FileItem(name: "File3.swift", content: "More content", isSelected: true, subtype: .swiftUIView, interface: "class test")
            ]

            return FileListToolbarView()
                .previewLayout(.sizeThatFits)
                .padding()
        }
    }
}
