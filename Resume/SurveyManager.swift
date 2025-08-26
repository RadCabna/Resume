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
    
    // Временные данные формы (в оперативной памяти)
    @Published var formData = SurveyFormData()
    
    // Черновик в CoreData (сохраняется на диск)
    @Published var draftPerson: Person?
    
    // Контекст CoreData для работы с базой данных
    private let viewContext: NSManagedObjectContext
    
    // Инициализация с контекстом CoreData
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        // При создании сразу загружаем или создаем черновик
        loadOrCreateDraft()
    }
    
    // MARK: - Управление черновиками
    
    // Загружаем существующий черновик или создаем новый
    private func loadOrCreateDraft() {
        // Ищем незавершенный черновик в CoreData
        let request: NSFetchRequest<Person> = Person.fetchRequest()
        request.predicate = NSPredicate(format: "isComplete == false AND isDraft == true")
        request.fetchLimit = 1
        
        do {
            let existingDrafts = try viewContext.fetch(request)
            if let existingDraft = existingDrafts.first {
                // Если нашли черновик - загружаем его
                draftPerson = existingDraft
                loadDataFromDraft()
                print("Загружен существующий черновик")
            } else {
                // Если черновика нет - создаем новый
                createNewDraft()
                print("Создан новый черновик")
            }
        } catch {
            print("Ошибка поиска черновика: \(error)")
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
        draft.lastModified = Date()
        
        // Сохраняем в базу данных
        do {
            try viewContext.save()
            print("Черновик сохранен: \(draft.name ?? "") \(draft.surname ?? "")")
        } catch {
            print("Ошибка сохранения черновика: \(error)")
        }
    }
    
    // MARK: - Навигация между экранами
    
    // Переход к следующему экрану
    func nextStep() {
        // Сначала сохраняем текущие данные в черновик
        saveDraft()
        
        // Переходим к следующему экрану (максимум 7, так как у нас 8 экранов: 0-7)
        if stepNumber < 7 {
            stepNumber += 1
            print("Переход на экран \(stepNumber)")
        }
    }
    
    // Переход к предыдущему экрану
    func previousStep() {
        // Сохраняем данные перед переходом
        saveDraft()
        
        // Возвращаемся к предыдущему экрану
        if stepNumber > 0 {
            stepNumber -= 1
            print("Возврат на экран \(stepNumber)")
        }
    }
    
    // MARK: - Завершение опроса
    
    // Финальное сохранение (завершение всего опроса)
    func completeSurvey() -> Bool {
        guard let draft = draftPerson else { return false }
        
        // Сохраняем последние изменения
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
    
    // Проверяем, валидны ли данные на текущем экране
    func isCurrentStepValid() -> Bool {
        switch stepNumber {
        case 0: // Intro - имя и фамилия обязательны
            return !formData.name.trimmingCharacters(in: .whitespaces).isEmpty && 
                   !formData.surname.trimmingCharacters(in: .whitespaces).isEmpty
        case 1: // Contacts - email обязателен
            return !formData.email.trimmingCharacters(in: .whitespaces).isEmpty
        default: // Остальные экраны пока считаем валидными
            return true
        }
    }
    
    // Проверяем, можно ли завершить весь опрос
    func canCompleteSurvey() -> Bool {
        return !formData.name.isEmpty && 
               !formData.surname.isEmpty && 
               !formData.email.isEmpty
    }
}

// MARK: - Модель данных формы (временное хранилище в памяти)
class SurveyFormData: ObservableObject {
    // Данные с экрана Intro
    @Published var name = ""
    @Published var surname = ""
    
    // Данные с экрана Contacts
    @Published var email = ""
    @Published var phone = ""
    @Published var website = ""
    @Published var address = ""
    
    // Здесь можно добавить поля для других экранов
    // @Published var workExperience = ""
    // @Published var education = ""
    // и т.д.
} 