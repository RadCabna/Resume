//
//  DetailedInfoView.swift
//  Resume
//
//  Created by Алкександр Степанов on 24.08.2025.
//

import SwiftUI
import CoreData

struct DetailedInfoView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var formData: PersonFormData
    
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var isSaving = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Заголовок и прогресс
            VStack(spacing: 15) {
                Text("Создание резюме")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Шаг 2 из 2")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                ProgressView(value: 2, total: 2)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .frame(height: 8)
            }
            .padding(.top, 20)
            
            // Основная форма в ScrollView
            ScrollView {
                VStack(spacing: 25) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Контактная информация")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Заполните ваши контактные данные")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 20) {
                        // Email (обязательное поле)
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Email")
                                    .font(.headline)
                                Text("*")
                                    .foregroundColor(.red)
                                    .font(.headline)
                            }
                            
                            TextField("example@mail.com", text: $formData.email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .font(.body)
                        }
                        
                        // Телефон
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Телефон")
                                .font(.headline)
                            
                            TextField("+7 (123) 456-78-90", text: $formData.phone)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.phonePad)
                                .font(.body)
                        }
                        
                        // Веб-сайт
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Веб-сайт")
                                .font(.headline)
                            
                            TextField("https://your-website.com", text: $formData.website)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.URL)
                                .autocapitalization(.none)
                                .font(.body)
                        }
                        
                        // Адрес
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Адрес")
                                .font(.headline)
                            
                            TextField("Город, улица, дом", text: $formData.address)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.body)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
            
            // Кнопка "Сохранить"
            VStack(spacing: 15) {
                Button(action: {
                    savePersonData()
                }) {
                    HStack {
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Text("Сохранить резюме")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(formData.isDetailedInfoValid && !isSaving ? Color.green : Color.gray)
                    .cornerRadius(12)
                }
                .disabled(!formData.isDetailedInfoValid || isSaving)
                
                Text("* Обязательные поля")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Успешно сохранено!", isPresented: $showSuccessAlert) {
            Button("OK") {
                // Возвращаемся к началу и очищаем форму
                formData.reset()
                dismiss()
            }
        } message: {
            Text("Резюме \(formData.name) \(formData.surname) успешно создано!")
        }
        .alert("Ошибка сохранения", isPresented: $showErrorAlert) {
            Button("OK") { }
        } message: {
            Text("Произошла ошибка при сохранении резюме. Попробуйте еще раз.")
        }
    }
    
    // MARK: - Функции
    
    private func savePersonData() {
        isSaving = true
        
        // Небольшая задержка для демонстрации процесса сохранения
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let success = formData.saveToCoreData(context: viewContext)
            
            isSaving = false
            
            if success {
                showSuccessAlert = true
            } else {
                showErrorAlert = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        DetailedInfoView(formData: PersonFormData())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
} 