# Руководство по работе с Core Data - Entity Person

## Обзор

В вашем приложении Resume теперь создана Entity `Person` с следующими атрибутами:
- `name` (String) - Имя
- `surname` (String) - Фамилия  
- `email` (String) - Электронная почта
- `phone` (String) - Телефон
- `website` (String) - Веб-сайт
- `address` (String) - Адрес

## Структура файлов

1. **Resume.xcdatamodeld/Resume.xcdatamodel/contents** - Модель данных Core Data
2. **PersonDataManager.swift** - Класс для управления данными Person
3. **PersonView.swift** - Пример SwiftUI интерфейса
4. **Persistence.swift** - Настройка Core Data (обновлен с примерами)

## Основные операции с данными

### 1. Создание нового Person

```swift
let dataManager = PersonDataManager()

dataManager.createPerson(
    name: "Иван",
    surname: "Иванов",
    email: "ivan@example.com",
    phone: "+7 123 456 78 90",
    website: "https://ivan.dev",
    address: "Москва, ул. Примерная, д. 1"
)
```

### 2. Получение всех Person

```swift
let dataManager = PersonDataManager()
let allPersons = dataManager.fetchAllPersons()

for person in allPersons {
    print("Имя: \(person.name ?? "")")
    print("Фамилия: \(person.surname ?? "")")
    // ... другие поля
}
```

### 3. Поиск Person по имени

```swift
let dataManager = PersonDataManager()
if let person = dataManager.fetchPersonByName("Иван") {
    print("Найден: \(person.name ?? "") \(person.surname ?? "")")
}
```

### 4. Обновление данных Person

```swift
let dataManager = PersonDataManager()
if let person = dataManager.fetchPersonByName("Иван") {
    dataManager.updatePerson(
        person,
        name: "Иван",
        surname: "Петров", // изменили фамилию
        email: "ivan.petrov@example.com", // изменили email
        phone: nil, // остальные поля не изменяем
        website: nil,
        address: nil
    )
}
```

### 5. Удаление Person

```swift
let dataManager = PersonDataManager()
if let person = dataManager.fetchPersonByName("Иван") {
    dataManager.deletePerson(person)
}
```

### 6. Удаление всех Person

```swift
let dataManager = PersonDataManager()
dataManager.deleteAllPersons()
```

## Использование в SwiftUI

### FetchRequest для автоматического обновления UI

```swift
struct PersonListView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Person.name, ascending: true)],
        animation: .default
    ) private var persons: FetchedResults<Person>
    
    var body: some View {
        List(persons) { person in
            Text("\(person.name ?? "") \(person.surname ?? "")")
        }
    }
}
```

### Создание Person в SwiftUI

```swift
struct CreatePersonView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var name = ""
    @State private var surname = ""
    
    var body: some View {
        VStack {
            TextField("Имя", text: $name)
            TextField("Фамилия", text: $surname)
            
            Button("Создать") {
                let newPerson = Person(context: viewContext)
                newPerson.name = name
                newPerson.surname = surname
                
                try? viewContext.save()
            }
        }
    }
}
```

## Продвинутые возможности

### Фильтрация с помощью NSPredicate

```swift
// Поиск по частичному совпадению имени
let request: NSFetchRequest<Person> = Person.fetchRequest()
request.predicate = NSPredicate(format: "name CONTAINS[c] %@", "Ив")

// Поиск по email домену
request.predicate = NSPredicate(format: "email ENDSWITH %@", "@gmail.com")

// Комбинированный поиск
request.predicate = NSPredicate(format: "name == %@ AND surname == %@", "Иван", "Иванов")
```

### Сортировка

```swift
let request: NSFetchRequest<Person> = Person.fetchRequest()
request.sortDescriptors = [
    NSSortDescriptor(keyPath: \Person.surname, ascending: true),
    NSSortDescriptor(keyPath: \Person.name, ascending: true)
]
```

### Лимиты и пагинация

```swift
let request: NSFetchRequest<Person> = Person.fetchRequest()
request.fetchLimit = 10 // максимум 10 записей
request.fetchOffset = 20 // пропустить первые 20 записей
```

## Обработка ошибок

Всегда оборачивайте операции Core Data в `do-catch` блоки:

```swift
do {
    try viewContext.save()
    print("Данные успешно сохранены")
} catch {
    print("Ошибка сохранения: \(error.localizedDescription)")
    
    // Для более детальной информации об ошибке
    if let nsError = error as NSError? {
        print("Код ошибки: \(nsError.code)")
        print("Описание: \(nsError.localizedDescription)")
        print("Дополнительная информация: \(nsError.userInfo)")
    }
}
```

## Лучшие практики

1. **Используйте фоновые контексты** для тяжелых операций:
```swift
let backgroundContext = persistenceController.container.newBackgroundContext()
backgroundContext.perform {
    // Тяжелые операции с данными
    try? backgroundContext.save()
}
```

2. **Валидация данных** перед сохранением:
```swift
func createPerson(name: String, surname: String, email: String) {
    guard !name.isEmpty && !surname.isEmpty else {
        print("Имя и фамилия обязательны")
        return
    }
    
    guard email.contains("@") else {
        print("Неверный формат email")
        return
    }
    
    // Создание Person...
}
```

3. **Использование computed properties** для удобства:
```swift
extension Person {
    var fullName: String {
        return "\(name ?? "") \(surname ?? "")".trimmingCharacters(in: .whitespaces)
    }
    
    var isComplete: Bool {
        return name != nil && surname != nil && email != nil
    }
}
```

## Запуск приложения

Для тестирования функциональности:

1. Замените ContentView в ResumeApp.swift на PersonView
2. Или добавьте PersonView как дополнительную вкладку
3. Запустите приложение и протестируйте создание, просмотр и удаление Person

Приложение поддерживает iOS 16.0+ и автоматически создает примеры данных в режиме превью. 