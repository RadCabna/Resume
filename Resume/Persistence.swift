//
//  Persistence.swift
//  Resume
//
//  Created by Алкександр Степанов on 24.08.2025.
//

import CoreData
//import CoreTransferable

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Создаем примеры Item
//        for _ in 0..<10 {
//            let newItem = Item(context: viewContext)
//            newItem.timestamp = Date()
//        }
        
//         Создаем примеры Person для превью
//        let samplePerson1 = Person(context: viewContext)
//        samplePerson1.name = "Алексей"
//        samplePerson1.surname = "Петров"
//        samplePerson1.email = "alex.petrov@example.com"
//        samplePerson1.phone = "+7 (999) 123-45-67"
//        samplePerson1.website = "https://alex-petrov.dev"
//        samplePerson1.address = "Санкт-Петербург, Невский пр., д. 100"
//        samplePerson1.isDraft = false
//        samplePerson1.isComplete = true
//        
//        let samplePerson2 = Person(context: viewContext)
//        samplePerson2.name = "Мария"
//        samplePerson2.surname = "Сидорова"
//        samplePerson2.email = "maria.sidorova@example.com"
//        samplePerson2.phone = "+7 (888) 987-65-43"
//        samplePerson2.website = "https://maria-sidorova.com"
//        samplePerson2.address = "Москва, ул. Тверская, д. 50"
//        samplePerson2.isDraft = false
//        samplePerson2.isComplete = true
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Resume")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
