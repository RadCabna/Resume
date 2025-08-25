//
//  BasicInfoView.swift
//  Resume
//
//  Created by Алкександр Степанов on 24.08.2025.
//

import SwiftUI

struct BasicInfoView: View {
    @ObservedObject var formData: PersonFormData
    @State private var showDetailedInfo = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Заголовок и прогресс
            VStack(spacing: 15) {
                Text("Создание резюме")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Шаг 1 из 2")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                ProgressView(value: 1, total: 2)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .frame(height: 8)
            }
            .padding(.top, 20)
            
            Spacer()
            
            // Основная форма
            VStack(spacing: 25) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Основная информация")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Введите ваше имя и фамилию")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 20) {
                    // Поле имени
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Имя")
                            .font(.headline)
                        
                        TextField("Введите ваше имя", text: $formData.name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.body)
                    }
                    
                    // Поле фамилии
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Фамилия")
                            .font(.headline)
                        
                        TextField("Введите вашу фамилию", text: $formData.surname)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.body)
                    }
                }
            }
            
            Spacer()
            
            // Кнопка "Далее"
            Button(action: {
                showDetailedInfo = true
            }) {
                HStack {
                    Text("Далее")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Image(systemName: "arrow.right")
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(formData.isBasicInfoValid ? Color.blue : Color.gray)
                .cornerRadius(12)
            }
            .disabled(!formData.isBasicInfoValid)
            .padding(.bottom, 30)
        }
        .padding(.horizontal, 20)
        .navigationDestination(isPresented: $showDetailedInfo) {
            DetailedInfoView(formData: formData)
        }
        .navigationBarBackButtonHidden(false)
    }
}

#Preview {
    NavigationStack {
        BasicInfoView(formData: PersonFormData())
    }
} 