//
//  PersonFormData.swift
//  Resume
//
//  Created by Алкександр Степанов on 24.08.2025.
//

import Foundation
import CoreData

class PersonFormData: ObservableObject {
    // Основная информация (первый экран)
    @Published var name = ""
    @Published var surname = ""
    
    // Детальная информация (второй экран)
    @Published var email = ""
    @Published var phone = ""
    @Published var website = ""
    @Published var address = ""
    
    // Валидация для первого экрана
    var isBasicInfoValid: Bool {
        return !name.trimmingCharacters(in: .whitespaces).isEmpty && 
               !surname.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    // Валидация для второго экрана
    var isDetailedInfoValid: Bool {
        return !email.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    // Сохранение в Core Data
    func saveToCoreData(context: NSManagedObjectContext) -> Bool {
        let newPerson = Person(context: context)
        newPerson.name = name.trimmingCharacters(in: .whitespaces)
        newPerson.surname = surname.trimmingCharacters(in: .whitespaces)
        newPerson.email = email.trimmingCharacters(in: .whitespaces)
        newPerson.phone = phone.trimmingCharacters(in: .whitespaces)
        newPerson.website = website.trimmingCharacters(in: .whitespaces)
        newPerson.address = address.trimmingCharacters(in: .whitespaces)
        
        do {
            try context.save()
            print("Person успешно сохранен: \(newPerson.name ?? "") \(newPerson.surname ?? "")")
            return true
        } catch {
            print("Ошибка при сохранении Person: \(error)")
            return false
        }
    }
    
    // Очистка данных формы
    func reset() {
        name = ""
        surname = ""
        email = ""
        phone = ""
        website = ""
        address = ""
    }
} 