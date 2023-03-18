//
//  FileTypeSelectionView.swift
//  AICodeDocumention
//
//  Created by James Trigg on 18/03/2023.
//

import SwiftUI

struct FileTypeSelectionView: View {
    @ObservedObject private var manager = XcodeProjectManager.shared
    
    @Binding var showFileTypeSelection: Bool
    
    var body: some View {
       VStack {
           NavigationStack {
               List(SubType.allCases, id: \.self) { subtype in
                   Toggle(subtype.rawValue, isOn: Binding(
                       get: { manager.selectedSubtypes.contains(subtype) },
                       set: { isSelected in
                           if isSelected {
                               manager.selectedSubtypes.insert(subtype)
                           } else {
                               manager.selectedSubtypes.remove(subtype)
                           }
                       }))
               }
               .navigationTitle("Select File Types")
               .toolbar {
                   ToolbarItem(placement: .confirmationAction) {
                       Button(action: { showFileTypeSelection.toggle() }) {
                           Image(systemName: "xmark.circle")
                       }
                   }
               }
           }
           
                                   
                                   
                                   
           HStack(spacing: 20) {
               createButton(icon: "checkmark.circle", label: "Select", action:  manager.select, tooltip: "Select files with chosen types")
               createButton(icon: "xmark.circle", label: "Deselect", action:  manager.deselect, tooltip: "Deselect files with chosen types")
               createButton(icon: "arrow.triangle.2.circlepath.circle", label: "Toggle", action: manager.toggle, tooltip: "Toggle files with chosen types")
               createButton(icon: "minus.circle", label: "Deselect Others", action: manager.deselectNonMatching, tooltip: "Deselect files that don't match chosen types")
           }
       }.frame(minWidth: 500, minHeight: 400)
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
            FileTypeSelectionView(showFileTypeSelection: $showFileTypeSelection)
                .previewLayout(.sizeThatFits)
                .padding()
        }
    }
}
