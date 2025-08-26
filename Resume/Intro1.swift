//
//  Intro.swift
//  Resume
//
//  Created by Алкександр Степанов on 24.08.2025.
//

import SwiftUI

struct Intro1: View {
    // Получаем данные формы от MainView
    // ObservedObject автоматически обновляет UI при изменении данных
    @ObservedObject var formData: SurveyFormData
    
    var body: some View {
        VStack(spacing: 30) {
            // Заголовок экрана
            headerSection
            
            Spacer()
            
            // Основная форма с полями ввода
            formSection
            
            Spacer()
        }
        .padding()
        .onAppear {
            print("Intro экран загружен")
            print("Текущие данные: имя='\(formData.name)', фамилия='\(formData.surname)'")
        }
    }
    
    // MARK: - Заголовок экрана
    
    private var headerSection: some View {
        VStack(spacing: 15) {
            // Иконка
            Image(systemName: "person.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            // Заголовок
            Text("Расскажите о себе")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            // Описание
            Text("Введите ваше имя и фамилию для создания резюме")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }
    
    // MARK: - Форма ввода данных
    
    private var formSection: some View {
        VStack(spacing: 25) {
            // Поле для имени
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Имя")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    // Звездочка для обязательного поля
                    Text("*")
                        .foregroundColor(.red)
                        .font(.headline)
                }
                
                // TextField привязан к formData.name
                // При изменении текста автоматически обновляется formData
                TextField("Введите ваше имя", text: $formData.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.body)
                    .autocorrectionDisabled() // Отключаем автокоррекцию для имен
            }
            
            // Поле для фамилии
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Фамилия")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    // Звездочка для обязательного поля
                    Text("*")
                        .foregroundColor(.red)
                        .font(.headline)
                }
                
                // TextField привязан к formData.surname
                TextField("Введите вашу фамилию", text: $formData.surname)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.body)
                    .autocorrectionDisabled() // Отключаем автокоррекцию для фамилий
            }
            
            // Информация об обязательных полях
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                    .font(.caption)
                
                Text("* Обязательные поля")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
        }
    }
}

// MARK: - Превью для разработки
#Preview {
    // Создаем тестовые данные для превью
    let testFormData = SurveyFormData()
    testFormData.name = "Алексей"
    testFormData.surname = "Петров"
    
    return Intro1(formData: testFormData)
} 
