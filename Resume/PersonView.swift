//
//  PersonView.swift
//  Resume
//
//  Created by Алкександр Степанов on 24.08.2025.
//

import SwiftUI
import CoreData

struct PersonView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var dataManager = PersonDataManager()
    
    // Для формы создания нового Person
    @State private var name = ""
    @State private var surname = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var website = ""
    @State private var address = ""
    
    // FetchRequest для получения всех Person из CoreData
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Person.name, ascending: true)],
        animation: .default)
    private var persons: FetchedResults<Person>
    
    var body: some View {
        NavigationView {
            VStack {
                // Форма для создания нового Person
                Form {
                    Section(header: Text("Создать новое резюме")) {
                        TextField("Имя", text: $name)
                        TextField("Фамилия", text: $surname)
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                        TextField("Телефон", text: $phone)
                            .keyboardType(.phonePad)
                        TextField("Веб-сайт", text: $website)
                            .keyboardType(.URL)
                        TextField("Адрес", text: $address)
                        
                        Button("Создать") {
                            createPerson()
                        }
                        .disabled(name.isEmpty || surname.isEmpty)
                    }
                }
                .frame(maxHeight: 350)
                
                // Список всех Person
                List {
                    ForEach(persons) { person in
                        PersonRowView(person: person)
                    }
                    .onDelete(perform: deletePersons)
                }
            }
            .navigationTitle("Резюме")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
    }
    
    // MARK: - Функции для работы с данными
    
    private func createPerson() {
        withAnimation {
            dataManager.createPerson(
                name: name,
                surname: surname,
                email: email,
                phone: phone,
                website: website,
                address: address
            )
            
            // Очищаем поля формы
            clearForm()
        }
    }
    
    private func clearForm() {
        name = ""
        surname = ""
        email = ""
        phone = ""
        website = ""
        address = ""
    }
    
    private func deletePersons(offsets: IndexSet) {
        withAnimation {
            offsets.map { persons[$0] }.forEach { person in
                dataManager.deletePerson(person)
            }
        }
    }
}

// MARK: - PersonRowView для отображения отдельного Person
struct PersonRowView: View {
    let person: Person
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("\(person.name ?? "") \(person.surname ?? "")")
                    .font(.headline)
                Spacer()
            }
            
            if let email = person.email, !email.isEmpty {
                Text("📧 \(email)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let phone = person.phone, !phone.isEmpty {
                Text("📱 \(phone)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let website = person.website, !website.isEmpty {
                Text("🌐 \(website)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let address = person.address, !address.isEmpty {
                Text("📍 \(address)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    PersonView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
} 