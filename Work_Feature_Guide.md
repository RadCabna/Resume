# Work Experience Feature - Руководство

## 🎯 Что реализовано:

### **1. Core Data модель:**
- **WorkExperience entity** с атрибутами:
  - `companyName` (String) - Название компании
  - `companyLocation` (String) - Местоположение компании  
  - `position` (String) - Должность
  - `startDate` (Date) - Дата начала работы
  - `endDate` (Date) - Дата окончания (nullable)
  - `isPresent` (Bool) - Работаю до сих пор
  - `createdAt` (Date) - Время создания записи

- **Связь с Person:**
  - Person → workExperiences (One-to-Many)
  - WorkExperience → person (Many-to-One)

### **2. Обновленный SurveyManager:**
- **WorkExperienceData** класс для временного хранения
- **Автосохранение** в черновики при переходах
- **Валидация** - минимум одно место работы с заполненными обязательными полями
- **Загрузка/восстановление** данных из CoreData

### **3. Work.swift View:**
- **Динамический список** мест работы
- **Добавление/удаление** записей
- **Toggle "Present"** для текущей работы
- **DatePicker** для дат начала/окончания
- **Валидация полей** в реальном времени

## 📱 Пользовательский интерфейс:

### **Основные элементы:**
- **Заголовок** в стиле других экранов
- **Карточки работы** с полями:
  - Company or Organization Name *
  - Company Location
  - Your Position *
  - Start Date
  - End Date (скрывается при включении Present)
  - Present Toggle
- **Кнопка "Add another work experience"**
- **Кнопка удаления** (только для 2+ места работы)

### **Валидация:**
- **Обязательные поля:** Company Name, Position
- **Автоматическое добавление** первого места работы
- **Подтверждение удаления** с alert диалогом

## 🔧 Техническая реализация:

### **Модель данных:**
```swift
class WorkExperienceData: ObservableObject, Identifiable {
    @Published var companyName = ""
    @Published var companyLocation = ""
    @Published var position = ""
    @Published var startDate = Date()
    @Published var endDate = Date()
    @Published var isPresent = false
    
    var isValid: Bool {
        return !companyName.isEmpty && !position.isEmpty
    }
}
```

### **Интеграция с SurveyFormData:**
```swift
class SurveyFormData: ObservableObject {
    @Published var workExperiences: [WorkExperienceData] = []
}
```

### **Сохранение в CoreData:**
```swift
private func saveWorkExperiences(to person: Person) {
    // Удаляем старые записи
    // Создаем новые из formData.workExperiences
    // Связываем с Person
}
```

## 🚀 Использование:

### **1. Навигация:**
- Работает как **3-й экран** в последовательности (stepNumber = 2)
- Интегрирован в **TopBar меню**
- Доступен через кнопку **"Next"** с экрана Contacts

### **2. Добавление работы:**
- **Автоматически** создается первое место при входе
- **Кнопка "Add another"** для дополнительных мест
- **Без ограничений** на количество

### **3. Удаление:**
- **Первое место работы** нельзя удалить
- **Остальные** удаляются с подтверждением
- **Каскадное удаление** из CoreData при удалении Person

### **4. Валидация:**
- **Переход на следующий экран** возможен только при:
  - Минимум одном месте работы
  - Заполненных обязательных полях (Company, Position)

## 🎨 Дизайн особенности:

### **Стилистика:**
- **Следует дизайну** Intro и Contacts экранов
- **Figtree шрифты** для консистентности
- **textFieldFrame** изображения для полей
- **Цветовая схема** соответствует приложению

### **UX элементы:**
- **Карточки** для группировки полей одной работы
- **Smooth animations** при добавлении/удалении
- **Conditional rendering** для End Date
- **Visual feedback** для валидации

## 🔮 Возможные улучшения:

- **Drag & Drop** для сортировки мест работы
- **Job description** текстовое поле
- **Company logo** загрузка изображения
- **Employment type** (Full-time, Part-time, Contract)
- **Salary information** (опционально)
- **Auto-complete** для названий компаний
- **LinkedIn integration** для импорта данных

Экран Work готов к использованию и полностью интегрирован в существующую архитектуру приложения! 🎉 