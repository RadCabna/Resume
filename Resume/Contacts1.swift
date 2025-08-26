//
//  Contacts.swift
//  Resume
//
//  Created by Алкександр Степанов on 24.08.2025.
//

import SwiftUI

struct Contacts1: View {
    // Получаем данные формы от MainView
    // ObservedObject автоматически обновляет UI при изменении данных
    @ObservedObject var formData: SurveyFormData
    
    var body: some View {
        VStack(spacing: 20) {
            // Заголовок экрана
            headerSection
            
            // Основная форма в ScrollView для длинного контента
            ScrollView {
                formSection
            }
        }
        .padding()
        .onAppear {
            print("Contacts экран загружен")
            print("Текущие данные: email='\(formData.email)', phone='\(formData.phone)'")
        }
    }
    
    // MARK: - Заголовок экрана
    
    private var headerSection: some View {
        VStack(spacing: 15) {
            // Иконка
            Image(systemName: "envelope.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            // Заголовок
            Text("Контактная информация")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            // Описание
            Text("Укажите способы связи с вами")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }
    
    // MARK: - Форма ввода контактных данных
    
    private var formSection: some View {
        VStack(spacing: 25) {
            // Email (обязательное поле)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Email")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    // Звездочка для обязательного поля
                    Text("*")
                        .foregroundColor(.red)
                        .font(.headline)
                }
                
                // TextField привязан к formData.email
                TextField("example@mail.com", text: $formData.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress) // Клавиатура для email
                    .autocapitalization(.none) // Отключаем автозаглавные для email
                    .autocorrectionDisabled() // Отключаем автокоррекцию
                    .font(.body)
            }
            
            // Телефон (опциональное поле)
            VStack(alignment: .leading, spacing: 8) {
                Text("Телефон")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                // TextField привязан к formData.phone
                TextField("+7 (123) 456-78-90", text: $formData.phone)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.phonePad) // Клавиатура для телефона
                    .font(.body)
            }
            
            // Веб-сайт (опциональное поле)
            VStack(alignment: .leading, spacing: 8) {
                Text("Веб-сайт")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                // TextField привязан к formData.website
                TextField("https://your-website.com", text: $formData.website)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.URL) // Клавиатура для URL
                    .autocapitalization(.none) // Отключаем автозаглавные для URL
                    .autocorrectionDisabled() // Отключаем автокоррекцию
                    .font(.body)
            }
            
            // Адрес (опциональное поле)
            VStack(alignment: .leading, spacing: 8) {
                Text("Адрес")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                // TextField привязан к formData.address
                TextField("Город, улица, дом", text: $formData.address)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.body)
            }
            
            // Информация об обязательных полях
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
                
                Text("* Обязательные поля")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding(.top, 10)
            
            // Показываем текущие данные для отладки (можно убрать в продакшене)
            if !formData.email.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Введенные данные:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if !formData.email.isEmpty {
                        Text("📧 \(formData.email)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if !formData.phone.isEmpty {
                        Text("📱 \(formData.phone)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if !formData.website.isEmpty {
                        Text("🌐 \(formData.website)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if !formData.address.isEmpty {
                        Text("📍 \(formData.address)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Превью для разработки
#Preview {
    // Создаем тестовые данные для превью
    let testFormData = SurveyFormData()
    testFormData.email = "test@example.com"
    testFormData.phone = "+7 123 456 78 90"
    testFormData.website = "https://example.com"
    testFormData.address = "Москва, Красная площадь, 1"
    
    return Contacts1(formData: testFormData)
} 
