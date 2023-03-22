//
//  FileTypeSelectionView.swift
//  AICodeDocumention
//
//  Created by James Trigg on 18/03/2023.
//

import SwiftUI

struct FileTypeSelectionView: View {
    @ObservedObject private var manager = XcodeProjectManager.shared
    private let columnWidth: CGFloat = 150 // Change this value to adjust the width of each column
    private let spacing: CGFloat = 10 // Change this value to adjust the spacing between columns

    
    var body: some View {
        GeometryReader { geometry in
            let numberOfColumns = max(Int(geometry.size.width / (columnWidth + spacing)), 1)
            let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: spacing), count: numberOfColumns)
    
            VStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(Array(manager.uniqueSubTypesInFileItems).sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { subtype in
                            Button(action: {
                                if manager.selectedSubtypes.contains(subtype) {
                                    manager.selectedSubtypes.remove(subtype)
                                } else {
                                    manager.selectedSubtypes.insert(subtype)
                                }
                            }) {
                                Text(subtype.rawValue)
                                    .fontWeight(.semibold)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 20)
                                    .background(manager.selectedSubtypes.contains(subtype) ? Color.blue : Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }.buttonStyle(BorderlessButtonStyle())
                        }
                    }
                }.frame(maxHeight: 100)
                
                
                HStack(spacing: 20) {
                    createButton(icon: "checkmark.circle", label: "Select", action:  manager.select, tooltip: "Select files with chosen types")
                    createButton(icon: "xmark.circle", label: "Deselect", action:  manager.deselect, tooltip: "Deselect files with chosen types")
                    createButton(icon: "arrow.triangle.2.circlepath.circle", label: "Toggle", action: manager.toggle, tooltip: "Toggle files with chosen types")
                    createButton(icon: "minus.circle", label: "Deselect Others", action: manager.deselectNonMatching, tooltip: "Deselect files that don't match chosen types")
                }.frame(maxHeight: 50)
            }
       }.frame(maxHeight: 150)
    }
    
    private func createButton(icon: String, label: String, action: @escaping () -> Void, tooltip: String) -> some View {
        Button(action: action) {
            VStack(alignment: .center, spacing: 2) {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                Text(label)
                    .font(.caption)
            }
            .frame(width: 110, height: 50)
        }
        .buttonStyle(BorderlessButtonStyle())
        .help(tooltip)
    }
    
    struct FileTypeSelectionView_Previews: PreviewProvider {
        @State static private var showFileTypeSelection = false
        static var previews: some View {
            FileTypeSelectionView()
                .previewLayout(.sizeThatFits)
                .padding()
        }
    }
}
