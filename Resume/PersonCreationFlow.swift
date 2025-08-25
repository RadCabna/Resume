//
//  PersonCreationFlow.swift
//  Resume
//
//  Created by Алкександр Степанов on 24.08.2025.
//

import SwiftUI

struct PersonCreationFlow: View {
    @StateObject private var formData = PersonFormData()
    
    var body: some View {
        NavigationStack {
            BasicInfoView(formData: formData)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    PersonCreationFlow()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
} 