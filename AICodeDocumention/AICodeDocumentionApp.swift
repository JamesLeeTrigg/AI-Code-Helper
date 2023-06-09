//
//  AICodeDocumentionApp.swift
//  AICodeDocumention
//
//  Created by James Trigg on 16/03/2023.
//

import SwiftUI

@main
struct AICodeDocumentionApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView(isPreview: false)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
