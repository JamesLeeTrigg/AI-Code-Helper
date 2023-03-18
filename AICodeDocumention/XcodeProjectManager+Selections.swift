//
//  XcodeProjectManager+Selections.swift
//  AICodeDocumention
//
//  Created by James Trigg on 18/03/2023.
//

import Foundation
extension XcodeProjectManager {
    func selectAll() {
        // Implement the functionality to select all files
        fileList = fileList.map { FileItem(name: $0.name, content: $0.content, isSelected: true, subtype: $0.subtype) }
    }
    
    func selectNone() {
        // Implement the functionality to deselect all files
        fileList = fileList.map { FileItem(name: $0.name, content: $0.content, isSelected: false, subtype: $0.subtype) }
    }
    
    func toggleViews() {
        fileList = fileList.map { file in
            var updatedFile = file
            if file.subtype == .swiftUIView || file.subtype == .uiViewController {
                updatedFile.isSelected.toggle()
            }
            return updatedFile
        }
    }
    
    func toggleFileTypes() {
        // Implement the functionality to toggle between file types
    }
    
    // Functions using selectedSubtypes for selection
        func select() {
            fileList = fileList.map { file in
                var updatedFile = file
                if selectedSubtypes.contains(file.subtype) {
                    updatedFile.isSelected = true
                }
                return updatedFile
            }
        }
        
        func deselect() {
            fileList = fileList.map { file in
                var updatedFile = file
                if selectedSubtypes.contains(file.subtype) {
                    updatedFile.isSelected = false
                }
                return updatedFile
            }
        }
        
        func toggle() {
            fileList = fileList.map { file in
                var updatedFile = file
                if selectedSubtypes.contains(file.subtype) {
                    updatedFile.isSelected.toggle()
                }
                return updatedFile
            }
        }
        
        func deselectNonMatching() {
            fileList = fileList.map { file in
                var updatedFile = file
                if !selectedSubtypes.contains(file.subtype) {
                    updatedFile.isSelected = false
                }
                return updatedFile
            }
        }
}
