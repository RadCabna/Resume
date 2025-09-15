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
    
    // Публичный доступ к контексту для синхронизации
    var context: NSManagedObjectContext {
        return viewContext
    }
    
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
        
        // Загружаем опыт работы
        loadWorksFromDraft(draft)
        
        // Загружаем summary
        loadSummaryFromDraft(draft)
        
        // Загружаем photos
        loadPhotosFromDraft(draft)
        
        // Загружаем additional skills
        loadAdditionalSkillsFromDraft(draft)
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
    
    // Загружаем опыт работы из CoreData в formData (оперативную память)
    private func loadWorksFromDraft(_ draft: Person) {
        let request: NSFetchRequest<Work> = Work.fetchRequest()
        request.predicate = NSPredicate(format: "person == %@", draft)
        request.sortDescriptors = [NSSortDescriptor(key: "workAt", ascending: false)]
        
        do {
            let works = try viewContext.fetch(request)
            formData.works = works.map { WorkData(from: $0) }
            print("💼 Загружено работ: \(works.count)")
        } catch {
            print("❌ Ошибка загрузки работ: \(error)")
            formData.works = []
        }
    }
    
    // Загружаем summary из CoreData в formData (оперативную память)
    private func loadSummaryFromDraft(_ draft: Person) {
        let request: NSFetchRequest<Summary> = Summary.fetchRequest()
        request.predicate = NSPredicate(format: "person == %@", draft)
        
        do {
            let summaries = try viewContext.fetch(request)
            if let summary = summaries.first {
                formData.summaryData = SummaryData(from: summary)
                print("📝 Загружен summary")
            } else {
                formData.summaryData = SummaryData()
                print("📝 Summary не найден, создан пустой")
            }
        } catch {
            print("❌ Ошибка загрузки summary: \(error)")
            formData.summaryData = SummaryData()
        }
    }
    
    // Принудительно загружаем все данные из CoreData в formData
    func forceReloadFromCoreData() {
        guard let _ = draftPerson else { return }
        loadDataFromDraft()
        print("🔄 Принудительно перезагружены все данные из CoreData")
    }
    
    // Принудительная синхронизация конкретного образования с CoreData
    func syncEducationWithCoreData(at index: Int) {
        guard let draft = draftPerson,
              index < formData.educations.count else { return }
        
        // Получаем образования из CoreData
        let request: NSFetchRequest<Education> = Education.fetchRequest()
        request.predicate = NSPredicate(format: "person == %@", draft)
        // Убираем сортировку, так как порядок может отличаться
        
        do {
            let coreDataEducations = try viewContext.fetch(request)
            let formDataEducation = formData.educations[index]
            
            // Ищем соответствующее образование по названию школы
            if let matchingEducation = coreDataEducations.first(where: { $0.schoolName == formDataEducation.schoolName }) {
                // Синхронизируем educationalDetails из CoreData
                formDataEducation.educationalDetails = matchingEducation.educationalDetails ?? ""
                
                print("🔄 Синхронизировано образование \(formDataEducation.schoolName): educationalDetails='\(formDataEducation.educationalDetails)'")
            } else {
                print("⚠️ Не найдено соответствующее образование в CoreData для \(formDataEducation.schoolName)")
            }
        } catch {
            print("❌ Ошибка синхронизации образования: \(error)")
        }
    }
    
    // MARK: - Additional Skills Methods
    
    // Переключение Hard Skill
    func toggleHardSkill(at index: Int) {
        guard index < formData.additionalSkills.hardSkills.count else { return }
        formData.additionalSkills.hardSkills[index].active.toggle()
        print("🎯 Hard Skill '\(formData.additionalSkills.hardSkills[index].name)' \(formData.additionalSkills.hardSkills[index].active ? "включен" : "выключен")")
    }
    
    // Переключение Soft Skill
    func toggleSoftSkill(at index: Int) {
        guard index < formData.additionalSkills.softSkills.count else { return }
        formData.additionalSkills.softSkills[index].active.toggle()
        print("🎯 Soft Skill '\(formData.additionalSkills.softSkills[index].name)' \(formData.additionalSkills.softSkills[index].active ? "включен" : "выключен")")
    }
    
    // Получение выбранных навыков для PDF
    func getSelectedSkills() -> (hardSkills: [String], softSkills: [String]) {
        let hardSkills = formData.additionalSkills.hardSkills
            .filter { $0.active }
            .map { $0.name }
        
        let softSkills = formData.additionalSkills.softSkills
            .filter { $0.active }
            .map { $0.name }
        
        return (hardSkills: hardSkills, softSkills: softSkills)
    }
    
    // Сохранение конкретного образования в CoreData
    func saveEducationToCoreData(at index: Int) {
        guard let draft = draftPerson,
              index < formData.educations.count else { 
            print("❌ Невозможно сохранить образование: неверный индекс или нет draft")
            return 
        }
        
        let formDataEducation = formData.educations[index]
        
        // Получаем образования из CoreData
        let request: NSFetchRequest<Education> = Education.fetchRequest()
        request.predicate = NSPredicate(format: "person == %@", draft)
        
        do {
            let coreDataEducations = try viewContext.fetch(request)
            
            // Ищем соответствующее образование по названию школы
            if let matchingEducation = coreDataEducations.first(where: { $0.schoolName == formDataEducation.schoolName }) {
                // Обновляем существующее образование
                matchingEducation.educationalDetails = formDataEducation.educationalDetails
                
                print("💾 Обновлено образование в CoreData: \(formDataEducation.schoolName)")
                print("💾 Сохранены educationalDetails: '\(formDataEducation.educationalDetails)'")
                
                // Сохраняем контекст
                try viewContext.save()
                print("✅ CoreData успешно сохранено")
            } else {
                print("⚠️ Не найдено образование в CoreData для обновления: \(formDataEducation.schoolName)")
            }
        } catch {
            print("❌ Ошибка сохранения образования в CoreData: \(error)")
        }
    }
    
    /**
     * Синхронизирует данные о работе из CoreData в formData
     */
    func syncWorkWithCoreData(at index: Int) {
        guard let draft = draftPerson,
              index < formData.works.count else { return }
        
        // Получаем работы из CoreData
        let request: NSFetchRequest<Work> = Work.fetchRequest()
        request.predicate = NSPredicate(format: "person == %@", draft)
        
        do {
            let coreDataWorks = try viewContext.fetch(request)
            let formDataWork = formData.works[index]
            
            // Ищем соответствующую работу по названию компании
            if let matchingWork = coreDataWorks.first(where: { $0.companyName == formDataWork.companyName }) {
                // Синхронизируем responsibilities из CoreData
                formDataWork.responsibilities = matchingWork.responsibilities ?? ""
                
                print("🔄 Синхронизирована работа \(formDataWork.companyName): responsibilities='\(formDataWork.responsibilities)'")
            } else {
                print("⚠️ Не найдена соответствующая работа в CoreData для \(formDataWork.companyName)")
            }
        } catch {
            print("❌ Ошибка синхронизации работы: \(error)")
        }
    }
    
    /**
     * Сохраняет данные о работе из formData в CoreData
     */
    func saveWorkToCoreData(at index: Int) {
        guard let draft = draftPerson,
              index < formData.works.count else { 
            print("❌ Невозможно сохранить работу: неверный индекс или нет draft")
            return 
        }
        
        let formDataWork = formData.works[index]
        
        // Получаем работы из CoreData
        let request: NSFetchRequest<Work> = Work.fetchRequest()
        request.predicate = NSPredicate(format: "person == %@", draft)
        
        do {
            let coreDataWorks = try viewContext.fetch(request)
            
            // Ищем соответствующую работу по названию компании
            if let matchingWork = coreDataWorks.first(where: { $0.companyName == formDataWork.companyName }) {
                // Обновляем существующую работу
                matchingWork.responsibilities = formDataWork.responsibilities
                
                print("💾 Обновлена работа в CoreData: \(formDataWork.companyName)")
                print("💾 Сохранены responsibilities: '\(formDataWork.responsibilities)'")
                
                // Сохраняем контекст
                try viewContext.save()
                print("✅ CoreData успешно сохранено")
            } else {
                print("⚠️ Не найдена работа в CoreData для обновления: \(formDataWork.companyName)")
            }
        } catch {
            print("❌ Ошибка сохранения работы в CoreData: \(error)")
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
        
        // Сохраняем опыт работы в CoreData
        saveWorksToDraft(draft)
        
        // Сохраняем summary в CoreData
        saveSummaryToDraft(draft)
        
        // Сохраняем additional skills в CoreData
        saveAdditionalSkillsToDraft(draft)
        
        // Сохраняем photos в CoreData
        savePhotosToDraft(draft)
        
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
            education.educationalDetails = educationData.educationalDetails
            education.person = person  // Устанавливаем связь
        }
        print("📚 Создано новых образований: \(formData.educations.count)")
    }
    
    // MARK: - Методы для работы с опытом работы
    
    // Сохраняем опыт работы в черновик
    private func saveWorksToDraft(_ draft: Person) {
        // 1. Удаляем старые записи о работе
        deleteExistingWorks(for: draft)
        
        // 2. Создаем новые записи о работе
        createNewWorks(for: draft)
    }
    
    // Удаляем существующие записи о работе для Person
    private func deleteExistingWorks(for person: Person) {
        let request: NSFetchRequest<Work> = Work.fetchRequest()
        request.predicate = NSPredicate(format: "person == %@", person)
        
        do {
            let existingWorks = try viewContext.fetch(request)
            for work in existingWorks {
                viewContext.delete(work)
            }
            print("🗑️ Удалено старых работ: \(existingWorks.count)")
        } catch {
            print("❌ Ошибка удаления старых работ: \(error)")
        }
    }
    
    // Создаем новые записи о работе для Person
    private func createNewWorks(for person: Person) {
        for workData in formData.works {
            let work = Work(context: viewContext)
            work.isCurentlyWork = workData.isCurentlyWork
            work.companyName = workData.companyName
            work.yourPosition = workData.position
            work.workAt = workData.whenStart
            work.workTo = workData.isCurentlyWork ? nil : workData.whenFinished
            work.companiLocation = workData.companiLocation
            work.responsibilities = workData.responsibilities
            work.person = person  // Устанавливаем связь
        }
        print("💼 Создано новых работ: \(formData.works.count)")
    }
    
    // MARK: - Методы для работы с Summary
    
    // Сохраняем summary в черновик
    private func saveSummaryToDraft(_ draft: Person) {
        // 1. Удаляем старую запись summary
        deleteExistingSummary(for: draft)
        
        // 2. Создаем новую запись summary если есть текст
        createNewSummary(for: draft)
    }
    
    // Удаляем существующий summary для Person
    private func deleteExistingSummary(for person: Person) {
        let request: NSFetchRequest<Summary> = Summary.fetchRequest()
        request.predicate = NSPredicate(format: "person == %@", person)
        
        do {
            let existingSummaries = try viewContext.fetch(request)
            for summary in existingSummaries {
                viewContext.delete(summary)
            }
            print("🗑️ Удалено старых summary: \(existingSummaries.count)")
        } catch {
            print("❌ Ошибка удаления старого summary: \(error)")
        }
    }
    
    // Создаем новый summary для Person
    private func createNewSummary(for person: Person) {
        if !formData.summaryData.summaryText.trimmingCharacters(in: .whitespaces).isEmpty {
            let summary = Summary(context: viewContext)
            summary.summaryText = formData.summaryData.summaryText
            summary.person = person  // Устанавливаем связь
            print("📝 Создан новый summary")
        }
    }
    
    // MARK: - Методы для работы с Photos
    
    // Сохраняем photos в черновик
    private func saveAdditionalSkillsToDraft(_ draft: Person) {
        do {
            let encoded = try JSONEncoder().encode(formData.additionalSkills)
            draft.additionalSkillsData = encoded
            print("🎯 Сохранены additional skills в CoreData")
        } catch {
            print("❌ Ошибка сохранения additional skills: \(error)")
        }
    }
    
    private func savePhotosToDraft(_ draft: Person) {
        // 1. Удаляем старые фото
        deleteExistingPhotos(for: draft)
        
        // 2. Создаем новые фото
        createNewPhotos(for: draft)
    }
    
    // Удаляем существующие фото для Person
    private func deleteExistingPhotos(for person: Person) {
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        request.predicate = NSPredicate(format: "person == %@", person)
        
        do {
            let existingPhotos = try viewContext.fetch(request)
            for photo in existingPhotos {
                viewContext.delete(photo)
            }
            print("🗑️ Удалено старых фото: \(existingPhotos.count)")
        } catch {
            print("❌ Ошибка удаления старых фото: \(error)")
        }
    }
    
    // Создаем новые фото для Person
    private func createNewPhotos(for person: Person) {
        for photoData in formData.photos {
            if let image = photoData.image {
                let photo = Photo(context: viewContext)
                
                // Сжимаем изображение для хранения
                if let compressedData = image.jpegData(compressionQuality: 0.8) {
                    photo.imageData = compressedData
                }
                
                // Создаем thumbnail
                if let thumbnail = image.resized(to: CGSize(width: 150, height: 150)),
                   let thumbnailData = thumbnail.jpegData(compressionQuality: 0.7) {
                    photo.thumbnailData = thumbnailData
                }
                
                photo.fileName = photoData.fileName
                photo.createdAt = photoData.createdAt
                photo.person = person
            }
        }
        print("📷 Создано новых фото: \(formData.photos.count)")
    }
    
    // Загружаем photos из CoreData в formData (оперативную память)
    private func loadPhotosFromDraft(_ draft: Person) {
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        request.predicate = NSPredicate(format: "person == %@", draft)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        
        do {
            let photos = try viewContext.fetch(request)
            formData.photos = photos.map { PhotoData(from: $0) }
            print("📷 Загружено фото: \(photos.count)")
        } catch {
            print("❌ Ошибка загрузки фото: \(error)")
            formData.photos = []
        }
    }
    
    private func loadAdditionalSkillsFromDraft(_ draft: Person) {
        if let data = draft.additionalSkillsData {
            do {
                let decoded = try JSONDecoder().decode(AdditionalSkillsData.self, from: data)
                formData.additionalSkills = decoded
                print("🎯 Загружены additional skills: Hard(\(decoded.hardSkills.filter{$0.active}.count)), Soft(\(decoded.softSkills.filter{$0.active}.count))")
            } catch {
                print("❌ Ошибка загрузки additional skills: \(error)")
                formData.additionalSkills = AdditionalSkillsData()
            }
        } else {
            formData.additionalSkills = AdditionalSkillsData()
            print("📝 Созданы дефолтные additional skills")
        }
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
            
        case 3: // Work экран - хотя бы одна работа с валидными данными
            return !formData.works.isEmpty && 
                   formData.works.allSatisfy { $0.isValid }
            
        case 4: // Summary экран - проверяем наличие текста summary
            return formData.summaryData.isValid
            
        default:
            return true // Остальные экраны пока не проверяем
        }
    }
    
    // MARK: - Debug Functions
    
    /// Полная очистка всех данных CoreData (для отладки)
    func deleteAllCoreDataRecords() {
        let context = self.viewContext
        
        // Удаляем все Person записи
        let personRequest: NSFetchRequest<NSFetchRequestResult> = Person.fetchRequest()
        let personDeleteRequest = NSBatchDeleteRequest(fetchRequest: personRequest)
        
        // Удаляем все Education записи
        let educationRequest: NSFetchRequest<NSFetchRequestResult> = Education.fetchRequest()
        let educationDeleteRequest = NSBatchDeleteRequest(fetchRequest: educationRequest)
        
        // Удаляем все Work записи
        let workRequest: NSFetchRequest<NSFetchRequestResult> = Work.fetchRequest()
        let workDeleteRequest = NSBatchDeleteRequest(fetchRequest: workRequest)
        
        // Удаляем все Summary записи
        let summaryRequest: NSFetchRequest<NSFetchRequestResult> = Summary.fetchRequest()
        let summaryDeleteRequest = NSBatchDeleteRequest(fetchRequest: summaryRequest)
        
        // Удаляем все Photo записи
        let photoRequest: NSFetchRequest<NSFetchRequestResult> = Photo.fetchRequest()
        let photoDeleteRequest = NSBatchDeleteRequest(fetchRequest: photoRequest)
        
        do {
            try context.execute(personDeleteRequest)
            try context.execute(educationDeleteRequest)
            try context.execute(workDeleteRequest)
            try context.execute(summaryDeleteRequest)
            try context.execute(photoDeleteRequest)
            try context.save()
            
            print("🗑️ ВСЕ ДАННЫЕ COREDATA УДАЛЕНЫ!")
            
            // Очищаем формы
            formData = SurveyFormData()
            
        } catch {
            print("❌ Ошибка удаления данных CoreData: \(error)")
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
    
    // Опыт работы
    @Published var works: [WorkData] = []
    
    // Summary
    @Published var summaryData: SummaryData = SummaryData()
    
    // Photos
    @Published var photos: [PhotoData] = []
    
    // Additional Skills
    @Published var additionalSkills = AdditionalSkillsData()
}

// MARK: - EducationData класс для временного хранения образования
class EducationData: ObservableObject, Identifiable {
    let id = UUID()
    @Published var isCurrentlyStudying = false
    @Published var schoolName = ""
    @Published var whenFinished = ""
    @Published var whenStart = ""
    @Published var educationalDetails = ""
    
    init() {}
    
    // Конструктор из CoreData объекта Education
    init(from education: Education) {
        self.isCurrentlyStudying = education.isCurrentlyStudying
        self.schoolName = education.schoolName ?? ""
        self.whenFinished = education.whenFinished ?? ""
        self.whenStart = education.whenStart ?? ""
        self.educationalDetails = education.educationalDetails ?? ""
    }
    
    // Валидация данных
    var isValid: Bool {
        return !schoolName.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

class WorkData : ObservableObject, Identifiable {
    let id = UUID()
    @Published var companyName = ""
    @Published var position = ""
    @Published var whenStart = ""
    @Published var whenFinished = ""
    @Published var companiLocation = ""
    @Published var isCurentlyWork = false
    @Published var responsibilities = ""
    
    init() {}
    
    init(from work: Work) {
        self.isCurentlyWork = work.isCurentlyWork
        self.companyName = work.companyName ?? ""
        self.position = work.yourPosition ?? ""
        self.whenStart = work.workAt ?? ""
        self.whenFinished = work.workTo ?? ""
        self.companiLocation = work.companiLocation ?? ""
        self.responsibilities = work.responsibilities ?? ""
    }
    
    // Валидация данных
    var isValid: Bool {
        return !companyName.trimmingCharacters(in: .whitespaces).isEmpty &&
               !position.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

// MARK: - SummaryData класс для временного хранения summary
class SummaryData: ObservableObject, Identifiable {
    let id = UUID()
    @Published var summaryText = ""
    
    init() {}
    
    // Конструктор из CoreData объекта Summary
    init(from summary: Summary) {
        self.summaryText = summary.summaryText ?? ""
    }
    
    // Валидация данных
    var isValid: Bool {
        return !summaryText.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

// MARK: - PhotoData класс для временного хранения фотографий
class PhotoData: ObservableObject, Identifiable {
    let id = UUID()
    @Published var image: UIImage?
    @Published var fileName: String = ""
    @Published var createdAt: Date = Date()
    
    init() {}
    
    // Конструктор из CoreData объекта Photo
    init(from photo: Photo) {
        if let imageData = photo.imageData {
            self.image = UIImage(data: imageData)
        }
        self.fileName = photo.fileName ?? ""
        self.createdAt = photo.createdAt ?? Date()
    }
    
    // Валидация данных
    var isValid: Bool {
        return image != nil
    }
}

// MARK: - Additional Skills Data
struct AdditionalSkillsData: Codable {
    var hardSkills: [AdditionalPoint]
    var softSkills: [AdditionalPoint]
    
    init() {
        self.hardSkills = Arrays.additionalHardSkillsArray
        self.softSkills = Arrays.additionalSoftSkillsArray
    }
}

// MARK: - UIImage Extension для сжатия изображений
extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}


 
