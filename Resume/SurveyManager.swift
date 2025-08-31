//
//  SurveyManager.swift
//  Resume
//
//  Created by Алкександр Степанов on 24.08.2025.
//

import Foundation
import CoreData
import SwiftUI

// Класс для управления опросом с черновиками
class SurveyManager: ObservableObject {
    // Текущий шаг опроса (0-7 для 8 экранов)
    @Published var stepNumber = 0
    
    // Данные форм в оперативной памяти
    @Published var formData = SurveyFormData()
    
    // Текущий черновик Person в CoreData
    @Published var draftPerson: Person?
    
    // CoreData context
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        loadOrCreateDraft()
    }
    
    // MARK: - Управление черновиками
    
    // Загружаем существующий черновик или создаем новый
    func loadOrCreateDraft() {
        // Пытаемся найти незавершенный черновик
        let request: NSFetchRequest<Person> = Person.fetchRequest()
        request.predicate = NSPredicate(format: "isDraft == true AND isComplete == false")
        request.sortDescriptors = [NSSortDescriptor(key: "lastModified", ascending: false)]
        request.fetchLimit = 1
        
        do {
            let drafts = try viewContext.fetch(request)
            if let existingDraft = drafts.first {
                draftPerson = existingDraft
                loadDataFromDraft()
            } else {
                createNewDraft()
            }
        } catch {
            print("Ошибка загрузки черновика: \(error)")
            createNewDraft()
        }
    }
    
    // Создаем новый черновик в CoreData
    private func createNewDraft() {
        let draft = Person(context: viewContext)
        draft.isDraft = true        // Помечаем как черновик
        draft.isComplete = false    // Еще не завершен
        draft.createdAt = Date()    // Время создания
        
        draftPerson = draft
        saveDraft()
    }
    
    // Загружаем данные из черновика CoreData в formData (оперативную память)
    private func loadDataFromDraft() {
        guard let draft = draftPerson else { return }
        
        // Переносим данные из CoreData в formData
        formData.name = draft.name ?? ""
        formData.surname = draft.surname ?? ""
        formData.email = draft.email ?? ""
        formData.phone = draft.phone ?? ""
        formData.website = draft.website ?? ""
        formData.address = draft.address ?? ""
        formData.adress_1 = draft.adress_1 ?? ""
        
        // Загружаем образование
        loadEducationsFromDraft(draft)
    }
    
    // Загружаем образования из CoreData в formData (оперативную память)
    private func loadEducationsFromDraft(_ draft: Person) {
        let request: NSFetchRequest<Education> = Education.fetchRequest()
        request.predicate = NSPredicate(format: "person == %@", draft)
        request.sortDescriptors = [NSSortDescriptor(key: "whenStart", ascending: false)]
        
        do {
            let educations = try viewContext.fetch(request)
            formData.educations = educations.map { EducationData(from: $0) }
            print("📚 Загружено образований: \(educations.count)")
        } catch {
            print("❌ Ошибка загрузки образований: \(error)")
            formData.educations = []
        }
    }
    
    // Сохраняем данные из formData в черновик CoreData
    func saveDraft() {
        guard let draft = draftPerson else { return }
        
        // Переносим данные из formData в CoreData
        draft.name = formData.name
        draft.surname = formData.surname
        draft.email = formData.email
        draft.phone = formData.phone
        draft.website = formData.website
        draft.address = formData.address
        draft.adress_1 = formData.adress_1
        draft.lastModified = Date()
        
        // Сохраняем образования в CoreData
        saveEducationsToDraft(draft)
        
        // Сохраняем в базу данных
        do {
            try viewContext.save()
            print("Черновик сохранен: \(draft.name ?? "") \(draft.surname ?? "")")
        } catch {
            print("Ошибка сохранения черновика: \(error)")
        }
    }
    
    // Сохраняем образования из formData в CoreData
    private func saveEducationsToDraft(_ draft: Person) {
        // 1. Удаляем старые записи образования
        deleteExistingEducations(for: draft)
        
        // 2. Создаем новые записи образования
        createNewEducations(for: draft)
    }
    
    // Удаляем существующие образования для Person
    private func deleteExistingEducations(for person: Person) {
        let request: NSFetchRequest<Education> = Education.fetchRequest()
        request.predicate = NSPredicate(format: "person == %@", person)
        
        do {
            let existingEducations = try viewContext.fetch(request)
            for education in existingEducations {
                viewContext.delete(education)
            }
            print("🗑️ Удалено старых образований: \(existingEducations.count)")
        } catch {
            print("❌ Ошибка удаления старых образований: \(error)")
        }
    }
    
    // Создаем новые образования для Person
    private func createNewEducations(for person: Person) {
        for educationData in formData.educations {
            let education = Education(context: viewContext)
            education.isCurrentlyStudying = educationData.isCurrentlyStudying
            education.schoolName = educationData.schoolName
            education.whenFinished = educationData.isCurrentlyStudying ? nil : educationData.whenFinished
            education.whenStart = educationData.whenStart
            education.person = person  // Устанавливаем связь
        }
        print("📚 Создано новых образований: \(formData.educations.count)")
    }
    
    // MARK: - Навигация между экранами
    
    // Переход на следующий экран
    func nextStep() {
        print("🔄 nextStep() вызван. Текущий stepNumber: \(stepNumber)")
        print("📝 formData.name: '\(formData.name)', formData.surname: '\(formData.surname)', formData.email: '\(formData.email)'")
        print("📚 formData.educations.count: \(formData.educations.count)")
        print("✅ isCurrentStepValid(): \(isCurrentStepValid())")
        
        // Проверяем валидность текущего экрана
//        guard isCurrentStepValid() else {
//            print("❌ Текущий экран не заполнен корректно")
//            return
//        }
        
        saveDraft()

        if stepNumber < 7 {
            stepNumber += 1
        } else {
            _ = completeSurvey()
        }
    }
    
    // Переход на предыдущий экран
    func previousStep() {
        // Сохраняем данные в CoreData
        saveDraft()
        
        if stepNumber > 0 {
            stepNumber -= 1
        }
    }
    
    // Завершение опроса (помечаем черновик как завершенный)
    @discardableResult
    func completeSurvey() -> Bool {
        guard let draft = draftPerson else { return false }
        
        // Финальное сохранение данных
        saveDraft()
        
        // Помечаем как завершенный (больше не черновик)
        draft.isDraft = false
        draft.isComplete = true
        draft.completedAt = Date()
        
        do {
            try viewContext.save()
            print("Опрос завершен для: \(draft.name ?? "") \(draft.surname ?? "")")
            
            // Очищаем текущий черновик, чтобы можно было создать новый
            draftPerson = nil
            formData = SurveyFormData() // Очищаем формы
            stepNumber = 0 // Возвращаемся на первый экран
            
            return true
        } catch {
            print("Ошибка завершения опроса: \(error)")
            return false
        }
    }
    
    // MARK: - Валидация
    
    // Проверяем валидность текущего экрана
    func isCurrentStepValid() -> Bool {
        switch stepNumber {
        case 0: // Intro экран - имя и фамилия
            return !formData.name.trimmingCharacters(in: .whitespaces).isEmpty &&
                   !formData.surname.trimmingCharacters(in: .whitespaces).isEmpty
            
        case 1: // Contacts экран - email обязателен
            return !formData.email.trimmingCharacters(in: .whitespaces).isEmpty
            
        case 2: // Education экран - хотя бы одно образование с валидными данными
            return !formData.educations.isEmpty && 
                   formData.educations.allSatisfy { $0.isValid }
            
        default:
            return true // Остальные экраны пока не проверяем
        }
    }
}

// MARK: - Data Models

// Класс для хранения данных форм в оперативной памяти
class SurveyFormData: ObservableObject {
    // Основная информация
    @Published var name = ""
    @Published var surname = ""
    @Published var email = ""
    @Published var phone = ""
    @Published var website = ""
    @Published var address = ""
    @Published var adress_1 = ""
    
    // Образование
    @Published var educations: [EducationData] = []
}

// MARK: - EducationData класс для временного хранения образования
class EducationData: ObservableObject, Identifiable {
    let id = UUID()
    @Published var isCurrentlyStudying = false
    @Published var schoolName = ""
    @Published var whenFinished = ""
    @Published var whenStart = ""
    
    init() {}
    
    // Конструктор из CoreData объекта Education
    init(from education: Education) {
        self.isCurrentlyStudying = education.isCurrentlyStudying
        self.schoolName = education.schoolName ?? ""
        self.whenFinished = education.whenFinished ?? ""
        self.whenStart = education.whenStart ?? ""
    }
    
    // Валидация данных
    var isValid: Bool {
        return !schoolName.trimmingCharacters(in: .whitespaces).isEmpty
    }
}


