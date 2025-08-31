//
//  MainView.swift
//  Resume
//
//  Created by Алкександр Степанов on 25.08.2025.
//

import SwiftUI

struct MainView: View {
//    @AppStorage("stepNumber") var stepNumber = 0
    @Environment(\.managedObjectContext) private var viewContext
    // Менеджер опроса с черновиками - основной контроллер
    @StateObject private var surveyManager: SurveyManager
    @State private var stepMenuPresented = false
    @State private var blurRadius: CGFloat = 0
    
    // Локальные переменные для Education (если показывается NewEducation)
    @State private var educationSchoolName = ""
    @State private var educationWhenStart = ""
    @State private var educationWhenFinished = ""
    @State private var educationIsCurrentlyStudying = false
    
    // Состояние подэкрана Education: true = NewEducation, false = EducationList  
    @State private var showingNewEducation = true
    // Инициализация с контекстом CoreData
    init() {
        // Создаем SurveyManager с контекстом CoreData
        _surveyManager = StateObject(wrappedValue: SurveyManager(context: PersistenceController.shared.container.viewContext))
    }
    var body: some View {
        ZStack {
            Color(.bg)
//            showList()
            currentScreen
                .blur(radius: blurRadius)
            Image(.whiteGradient)
                .resizable()
                .frame(width: screenWidth, height: screenHeight*0.2)
                .frame(maxHeight: .infinity, alignment: .bottom)
            Image(.buttonNext)
                .resizable()
                .scaledToFit()
                .frame(height: screenHeight*0.065)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, screenHeight*0.04)
                .onTapGesture {
                    if surveyManager.stepNumber < 7 {
                        // Сохраняем данные текущего шага
                        saveCurrentStepData()
                        
                        // Проверяем, можно ли переходить к следующему экрану
                        if canProceedToNextStep() {
                            surveyManager.nextStep()
                            
                            // Сбрасываем состояние для новых экранов
                            if surveyManager.stepNumber == 2 {
                                // При возврате к Education определяем состояние
                                showingNewEducation = surveyManager.formData.educations.isEmpty
                            }
                            /*stepNumber = surveyManager.stepNumber*/ // Синхронизируем с @AppStorage
                        }
                    }
                }
            
            TopBar(formData: surveyManager.formData, stepMenuPresented: $stepMenuPresented, stepNumber: $surveyManager.stepNumber)
        }
//        .onAppear {
//            // Синхронизируем stepNumber при появлении
//            surveyManager.stepNumber = stepNumber
//        }
//        .onChange(of: stepNumber) { newValue in
//            // Синхронизируем изменения stepNumber из TopBar в SurveyManager
//            surveyManager.stepNumber = newValue
//        }
        .ignoresSafeArea()
        
        .onChange(of: stepMenuPresented) { _ in
            blurText()
        }
    }
    
    @ViewBuilder
    private var currentScreen: some View {
        // Переключаем экраны в зависимости от stepNumber
        // Передаем formData в каждый экран для работы с данными
        switch surveyManager.stepNumber {
        case 0:
            Intro(formData: surveyManager.formData)
        case 1:
            Contacts(formData: surveyManager.formData)
        case 2:
            EducationView(
                formData: surveyManager.formData,
                schoolName: $educationSchoolName,
                whenStart: $educationWhenStart,
                whenFinished: $educationWhenFinished,
                isCurrentlyStudying: $educationIsCurrentlyStudying,
                showingNewEducation: $showingNewEducation
            )
        // Добавьте здесь остальные экраны по мере их создания
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
    
    private func blurText() {
        withAnimation(Animation.easeInOut(duration: 0.3)) {
            if stepMenuPresented {
                blurRadius = 1.5
            } else {
                blurRadius = 0
            }
        }
    }
    
    private func saveCurrentStepData() {
        switch surveyManager.stepNumber {
        case 0:
            // Intro - данные сохраняются автоматически через onDisappear
            print("💾 Сохранение данных Intro")
        case 1:
            // Contacts - данные сохраняются автоматически через onDisappear
            print("💾 Сохранение данных Contacts")
        case 2:
            // Education - специальная логика
            saveEducationData()
        default:
            print("💾 Шаг \(surveyManager.stepNumber) - сохранение не настроено")
        }
    }
    
    private func saveEducationData() {
        if showingNewEducation {
            // Показывается NewEducation - сохраняем локальные данные
            if !educationSchoolName.trimmingCharacters(in: .whitespaces).isEmpty {
                let newEducation = EducationData()
                newEducation.schoolName = educationSchoolName
                newEducation.whenStart = educationWhenStart
                newEducation.whenFinished = educationIsCurrentlyStudying ? "Present" : educationWhenFinished
                newEducation.isCurrentlyStudying = educationIsCurrentlyStudying
                
                surveyManager.formData.educations.append(newEducation)
                print("💾 Education: сохранено новое образование - \(educationSchoolName)")
                
                // Очищаем локальные переменные для следующего использования
                educationSchoolName = ""
                educationWhenStart = ""
                educationWhenFinished = ""
                educationIsCurrentlyStudying = false
                
                // Переключаемся на EducationList
                showingNewEducation = false
                print("🔄 Education: переключились на EducationList")
            } else {
                print("💾 Education: нет данных для сохранения")
            }
        } else {
            // Показывается EducationList - можно переходить к следующему экрану
            print("💾 Education: переход к следующему экрану")
        }
    }
    
    private func canProceedToNextStep() -> Bool {
        switch surveyManager.stepNumber {
        case 2: // Education
            // Можно переходить только если показывается EducationList
            return !showingNewEducation
        default:
            // Для остальных экранов - всегда можно переходить
            return true
        }
    }
    
//    func showList() -> AnyView {
//        switch stepNumber {
//        case 0:
//            return AnyView(Intro())
//        case 1:
//            return AnyView(Contacts())
//        default:
//            return AnyView(Intro())
//        }
//    }
    
}

#Preview {
    MainView()
}
