//
//  ResumeApp.swift
//  Resume
//
//  Created by Алкександр Степанов on 24.08.2025.
//

import SwiftUI

@main
struct ResumeApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            let testFormData = SurveyFormData()
            MainView()
            
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
