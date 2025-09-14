//
//  Responsibilities.swift
//  Resume
//
//  Created by Алкександр Степанов on 14.09.2025.
//

import SwiftUI

struct Responsibilities: View {
    @State private var stepNumber = 3
    @State private var stepsTextArray = Arrays.stepsTextArray
    @State private var responsibilityText = ""
    @State private var isTextEditorFocused = false
    @State private var isTextFieldFocused = false
    @ObservedObject var formData: SurveyFormData
    @ObservedObject var surveyManager: SurveyManager
    @StateObject private var keyboardObserver = KeyboardObserver()
    
    @Binding var currentWorkIndex: Int?
    @Binding var showingResponsibilities: Bool
    @Binding var showingNewWork: Bool
    
    // Функции для работы с данными (аналогично ClearSummary)
    private func saveResponsibilities() {
        guard let workIndex = currentWorkIndex, 
              workIndex < formData.works.count else { 
            print("❌ Невозможно сохранить responsibilities: неверный индекс")
            return 
        }
        
        print("💼 Сохраняемый текст responsibilities: '\(responsibilityText)'")
        formData.works[workIndex].responsibilities = responsibilityText
        print("💼 Responsibilities сохранены для работы: \(formData.works[workIndex].companyName)")
        print("💼 Значение в formData после сохранения: '\(formData.works[workIndex].responsibilities)'")
        
        // Сохраняем в CoreData
        surveyManager.saveWorkToCoreData(at: workIndex)
    }
    
    private func loadResponsibilities() {
        guard let workIndex = currentWorkIndex,
              workIndex < formData.works.count else { 
            print("❌ Невозможно загрузить responsibilities: неверный индекс")
            return 
        }
        
        responsibilityText = formData.works[workIndex].responsibilities
        print("💼 Responsibilities загружены для работы: \(formData.works[workIndex].companyName)")
        print("💼 Загруженный текст responsibilities: '\(responsibilityText)'")
    }
    
    func completeResponsibilities() {
        saveResponsibilities()
        showingResponsibilities = false
        showingNewWork = false // Переход к WorkList
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    Text(stepsTextArray[stepNumber][8])
                        .font(Font.custom("Figtree-Bold", size: screenHeight*0.03))
                        .foregroundStyle(Color.black)
                        .lineSpacing(0)
                    Text(stepsTextArray[stepNumber][9])
                        .font(Font.custom("Figtree-Medium", size: screenHeight*0.017))
                        .foregroundStyle(Color.onboardingColor2)
                        .padding(.bottom, screenHeight*0.04)
                Image(.summaryFrame)
                    .resizable()
                    .scaledToFit()
                    .frame(height: screenHeight*0.28)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .overlay(
                        ZStack {
                            // Область для ввода текста
                            ZStack(alignment: .topLeading) {
                                // Placeholder текст
                                if responsibilityText.isEmpty {
                                    Text("Describe your key responsibilities and achievements at this position...")
                                        .font(Font.custom("Figtree-Medium", size: screenHeight*0.016))
                                        .foregroundColor(.gray.opacity(0.6))
                                        .padding(.top, 8)
                                        .padding(.leading, 4)
                                        .allowsHitTesting(false)
                                }
                                
                                ClearTextEditor(text: $responsibilityText, isFocused: $isTextFieldFocused)
                                    .onChange(of: responsibilityText) { newValue in
                                        // Обновляем formData в реальном времени
                                        if let workIndex = currentWorkIndex, workIndex < formData.works.count {
                                            formData.works[workIndex].responsibilities = newValue
                                            print("💼 Responsibilities обновлены в реальном времени: '\(newValue)'")
                                        }
                                    }
                            }
                                .font(Font.custom("Figtree-Medium", size: screenHeight*0.016))
                            .frame(maxWidth: screenHeight*0.35)
                            .frame(height: screenHeight*0.16)
                            .frame(maxHeight: .infinity, alignment: .top)
                            .padding(.top, screenHeight*0.03)
                            .padding(.horizontal, screenHeight*0.01)
                            
                            // Кнопки внизу
                            HStack {
                                Button(action: {
                                    // Действие для AI генерации
                                }) {
                                    Image(.writeAIButton)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: screenHeight*0.032)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    // Переключаем состояние клавиатуры (открываем/закрываем)
                                    isTextFieldFocused.toggle()
                                }) {
                                    Image(.openKeyBoardButton)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: screenHeight*0.035)
                                }
                            }
                            .frame(maxWidth: screenHeight*0.36)
                            .frame(maxHeight: .infinity, alignment: .bottom)
                            .padding(.bottom, screenHeight*0.03)
                        }
                    )
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .frame(maxWidth: screenWidth*0.9)
            .padding(.top, screenHeight*0.25)
            .padding(.bottom, keyboardObserver.isKeyboardVisible ? screenHeight*0.4 : screenHeight*0.15)
            .animation(.easeInOut(duration: 0.3), value: keyboardObserver.isKeyboardVisible)
        }
        .onTapGesture {
            // Скрываем клавиатуру при нажатии вне области ввода
            isTextFieldFocused = false
        }
        .onAppear {
            loadResponsibilities()
        }
        .onDisappear {
            saveResponsibilities()
        }
    }
}

#Preview {
    let testFormData = SurveyFormData()
    // Добавляем тестовую работу
    let work = WorkData()
    work.companyName = "Test Company"
    work.position = "Test Position"
    testFormData.works = [work]
    
    let testSurveyManager = SurveyManager(context: PersistenceController.preview.container.viewContext)
    return Responsibilities(formData: testFormData,
                          surveyManager: testSurveyManager,
                          currentWorkIndex: .constant(0),
                          showingResponsibilities: .constant(true),
                          showingNewWork: .constant(false))
}


