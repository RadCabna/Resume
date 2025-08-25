//
//  MainMenuView.swift
//  Resume
//
//  Created by Алкександр Степанов on 24.08.2025.
//

import SwiftUI
import CoreData

struct MainMenuView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // FetchRequest для получения всех Person
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Person.name, ascending: true)],
        animation: .default
    ) private var persons: FetchedResults<Person>
    
    @State private var showPersonCreation = false
    @State private var showPersonList = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                // Заголовок приложения
                VStack(spacing: 15) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("Resume Builder")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Создайте профессиональное резюме")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 60)
                
                Spacer()
                
                // Статистика
                if !persons.isEmpty {
                    VStack(spacing: 10) {
                        Text("У вас \(persons.count) резюме")
                            .font(.headline)
                        
                        Text("Последнее обновление: сегодня")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
                
                Spacer()
                
                // Кнопки действий
                VStack(spacing: 20) {
                    // Создать новое резюме
                    Button(action: {
                        showPersonCreation = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                            
                            Text("Создать новое резюме")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    
                    // Просмотреть существующие резюме
                    if !persons.isEmpty {
                        Button(action: {
                            showPersonList = true
                        }) {
                            HStack {
                                Image(systemName: "list.bullet")
                                    .font(.title2)
                                
                                Text("Мои резюме (\(persons.count))")
                                    .font(.headline)
                            }
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 30)
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showPersonCreation) {
            PersonCreationFlow()
        }
        .sheet(isPresented: $showPersonList) {
            PersonListView()
        }
    }
}

// MARK: - PersonListView для просмотра существующих резюме
struct PersonListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Person.name, ascending: true)],
        animation: .default
    ) private var persons: FetchedResults<Person>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(persons) { person in
                    PersonRowView(person: person)
                }
                .onDelete(perform: deletePersons)
            }
            .navigationTitle("Мои резюме")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
    }
    
    private func deletePersons(offsets: IndexSet) {
        withAnimation {
            offsets.map { persons[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                print("Ошибка при удалении: \(error)")
            }
        }
    }
}

#Preview {
    MainMenuView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
} 