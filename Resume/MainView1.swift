//
//  MainView.swift
//  Resume
//
//  Created by Алкександр Степанов on 24.08.2025.
//

import SwiftUI
import CoreData

struct MainView1: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // Менеджер опроса с черновиками - основной контроллер
    @StateObject private var surveyManager: SurveyManager
    
    // Инициализация с контекстом CoreData
    init() {
        // Создаем SurveyManager с контекстом CoreData
        _surveyManager = StateObject(wrappedValue: SurveyManager(context: PersistenceController.shared.container.viewContext))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Прогресс-бар вверху экрана
            progressHeader
            
            // Основной контент - текущий экран в зависимости от stepNumber
            currentScreen
            
            // Навигационные кнопки внизу
            navigationButtons
        }
        .onAppear {
            print("MainView появился, текущий экран: \(surveyManager.stepNumber)")
        }
    }
    
    // MARK: - Прогресс-бар
    
    private var progressHeader: some View {
        VStack(spacing: 10) {
            // Заголовок с номером шага
            HStack {
                Text("Шаг \(surveyManager.stepNumber + 1) из 8")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int((Double(surveyManager.stepNumber + 1) / 8.0) * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Прогресс-бар
            ProgressView(value: Double(surveyManager.stepNumber + 1), total: 8)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Отображение текущего экрана
    
    @ViewBuilder
    private var currentScreen: some View {
        // Переключаем экраны в зависимости от stepNumber
        // Передаем formData в каждый экран для работы с данными
        switch surveyManager.stepNumber {
        case 0:
            Intro1(formData: surveyManager.formData)
        case 1:
            Contacts1(formData: surveyManager.formData)
        // Добавьте здесь остальные экраны по мере их создания
        // case 2: Experience(formData: surveyManager.formData)
        // case 3: Education(formData: surveyManager.formData)
        // case 4: Skills(formData: surveyManager.formData)
        // case 5: Projects(formData: surveyManager.formData)
        // case 6: References(formData: surveyManager.formData)
        // case 7: Summary(formData: surveyManager.formData)
        default:
            // Временный экран для еще не созданных экранов
            VStack {
                Text("Экран \(surveyManager.stepNumber + 1)")
                    .font(.title)
                Text("Этот экран еще не создан")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Навигационные кнопки
    
    private var navigationButtons: some View {
        VStack(spacing: 15) {
            // Кнопка "Далее" или "Завершить"
            Button(action: {
                if surveyManager.stepNumber == 7 {
                    // Последний экран - завершаем опрос
                    if surveyManager.completeSurvey() {
                        print("Опрос успешно завершен!")
                        // Здесь можно добавить переход к экрану успеха
                    }
                } else {
                    // Переходим к следующему экрану
                    surveyManager.nextStep()
                }
            }) {
                HStack {
                    Text(surveyManager.stepNumber == 7 ? "Завершить опрос" : "Далее")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    if surveyManager.stepNumber != 7 {
                        Image(systemName: "arrow.right")
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(surveyManager.isCurrentStepValid() ? 
                           (surveyManager.stepNumber == 7 ? Color.green : Color.blue) : 
                           Color.gray)
                .cornerRadius(12)
            }
            .disabled(!surveyManager.isCurrentStepValid())
            
            // Кнопка "Назад" (только если не первый экран)
            if surveyManager.stepNumber > 0 {
                Button(action: {
                    surveyManager.previousStep()
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.blue)
                        
                        Text("Назад")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            
            // Информация о валидности данных (для отладки)
            if !surveyManager.isCurrentStepValid() {
                Text("Заполните обязательные поля")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
} 
