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
            Image(.buttonNext)
                .resizable()
                .scaledToFit()
                .frame(height: screenHeight*0.065)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, screenHeight*0.04)
                .onTapGesture {
                    if surveyManager.stepNumber < 7 {
                        surveyManager.nextStep()
                        /*stepNumber = surveyManager.stepNumber*/ // Синхронизируем с @AppStorage
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
    
    private func blurText() {
        withAnimation(Animation.easeInOut(duration: 0.3)) {
            if stepMenuPresented {
                blurRadius = 1.5
            } else {
                blurRadius = 0
            }
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
