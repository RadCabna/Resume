//
//  PersonDataManager.swift
//  Resume
//
//  Created by Алкександр Степанов on 24.08.2025.
//

import CoreData
import SwiftUI

class PersonDataManager: ObservableObject {
    let persistenceController = PersistenceController.shared
    
    // MARK: - Создание нового Person
    func createPerson(name: String, surname: String, email: String, phone: String, website: String, address: String) {
        let context = persistenceController.container.viewContext
        
        let newPerson = Person(context: context)
        newPerson.name = name
        newPerson.surname = surname
        newPerson.email = email
        newPerson.phone = phone
        newPerson.website = website
        newPerson.address = address
        
        do {
            try context.save()
            print("Person успешно создан")
        } catch {
            print("Ошибка при сохранении Person: \(error)")
        }
    }
    
    // MARK: - Получение всех Person
    func fetchAllPersons() -> [Person] {
        let context = persistenceController.container.viewContext
        let request: NSFetchRequest<Person> = Person.fetchRequest()
        
        do {
            let persons = try context.fetch(request)
            return persons
        } catch {
            print("Ошибка при загрузке Person: \(error)")
            return []
        }
    }
    
    // MARK: - Поиск Person по имени
    func fetchPersonByName(_ name: String) -> Person? {
        let context = persistenceController.container.viewContext
        let request: NSFetchRequest<Person> = Person.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        request.fetchLimit = 1
        
        do {
            let persons = try context.fetch(request)
            return persons.first
        } catch {
            print("Ошибка при поиске Person по имени: \(error)")
            return nil
        }
    }
    
    // MARK: - Обновление Person
    func updatePerson(_ person: Person, name: String?, surname: String?, email: String?, phone: String?, website: String?, address: String?) {
        let context = persistenceController.container.viewContext
        
        if let name = name { person.name = name }
        if let surname = surname { person.surname = surname }
        if let email = email { person.email = email }
        if let phone = phone { person.phone = phone }
        if let website = website { person.website = website }
        if let address = address { person.address = address }
        
        do {
            try context.save()
            print("Person успешно обновлен")
        } catch {
            print("Ошибка при обновлении Person: \(error)")
        }
    }
    
    // MARK: - Удаление Person
    func deletePerson(_ person: Person) {
        let context = persistenceController.container.viewContext
        context.delete(person)
        
        do {
            try context.save()
            print("Person успешно удален")
        } catch {
            print("Ошибка при удалении Person: \(error)")
        }
    }
    
    // MARK: - Удаление всех Person
    func deleteAllPersons() {
        let context = persistenceController.container.viewContext
        let request: NSFetchRequest<NSFetchRequestResult> = Person.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            print("Все Person успешно удалены")
        } catch {
            print("Ошибка при удалении всех Person: \(error)")
        }
    }
}

// MARK: - Примеры использования
extension PersonDataManager {
    
    // Пример создания нового пользователя
    func createSamplePerson() {
        createPerson(
            name: "Иван",
            surname: "Иванов", 
            email: "ivan.ivanov@example.com",
            phone: "+7 (123) 456-78-90",
            website: "https://ivan-ivanov.dev",
            address: "Москва, ул. Примерная, д. 1"
        )
    }
    
    // Пример получения и отображения всех пользователей
    func printAllPersons() {
        let persons = fetchAllPersons()
        for person in persons {
            print("Имя: \(person.name ?? "Не указано")")
            print("Фамилия: \(person.surname ?? "Не указано")")
            print("Email: \(person.email ?? "Не указано")")
            print("Телефон: \(person.phone ?? "Не указано")")
            print("Сайт: \(person.website ?? "Не указано")")
            print("Адрес: \(person.address ?? "Не указано")")
            print("---")
        }
    }
} 