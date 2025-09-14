//
//  EducationalDetails.swift
//  Resume
//
//  Created by Алкександр Степанов on 14.09.2025.
//

import SwiftUI

struct EducationalDetails: View {
    @State private var stepNumber = 2
    @State private var stepsTextArray = Arrays.stepsTextArray
    @State private var educationDetailsText = ""
    @State private var isTextEditorFocused = false
    @State private var isTextFieldFocused = false
    @ObservedObject var formData: SurveyFormData
    @StateObject private var keyboardObserver = KeyboardObserver()
    
    // Навигация
    @Binding var currentEducationIndex: Int?
    @Binding var showingEducationalDetails: Bool
    @Binding var showingNewEducation: Bool
    
    // Нужен доступ к SurveyManager для сохранения в CoreData
    @ObservedObject var surveyManager: SurveyManager
    
    // Функции для работы с данными (аналогично Responsibilities)
        private func saveEducationalDetails() {
        guard let educationIndex = currentEducationIndex, 
              educationIndex < formData.educations.count else { 
            print("❌ Educational Details: невозможно сохранить - неверный индекс")
            print("🔢 currentEducationIndex: \(currentEducationIndex?.description ?? "nil"), educations.count: \(formData.educations.count)")
            return 
        }
        
        let education = formData.educations[educationIndex]
        // Данные уже сохранены в formData через onChange, дублируем для безопасности
        education.educationalDetails = educationDetailsText
        print("📚 Educational Details сохранены в formData для образования: \(education.schoolName)")
        print("💾 Сохраненное содержимое: '\(educationDetailsText)'")
        
        // Сохраняем в CoreData немедленно
        surveyManager.saveEducationToCoreData(at: educationIndex)
    }
    
    private func loadEducationalDetails() {
        guard let educationIndex = currentEducationIndex,
              educationIndex < formData.educations.count else { 
            print("❌ Educational Details: неверный индекс или пустой массив образований")
            return 
        }
        
        let education = formData.educations[educationIndex]
        educationDetailsText = education.educationalDetails
        print("📚 Educational Details загружены для образования: \(education.schoolName)")
        print("📝 Educational Details содержимое: '\(education.educationalDetails)'")
        print("🔢 Current education index: \(educationIndex), total educations: \(formData.educations.count)")
    }
    
    func completeEducationalDetails() {
        saveEducationalDetails()
        showingEducationalDetails = false
        showingNewEducation = false // Переход к EducationList
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                Text(stepsTextArray[stepNumber][6])
                    .font(Font.custom("Figtree-Bold", size: screenHeight*0.03))
                    .foregroundStyle(Color.black)
                    .lineSpacing(0)
                Text(stepsTextArray[stepNumber][7])
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
                                if educationDetailsText.isEmpty {
                                    Text("Describe your courses, achievements, and key learning experiences...")
                                        .font(Font.custom("Figtree-Medium", size: screenHeight*0.016))
                                        .foregroundColor(.gray.opacity(0.6))
                                        .padding(.top, 8)
                                        .padding(.leading, 4)
                                        .allowsHitTesting(false)
                                }
                                
                                ClearTextEditor(text: $educationDetailsText, isFocused: $isTextFieldFocused)
                                    .onChange(of: educationDetailsText) { newValue in
                                        // Сохраняем изменения в formData в реальном времени
                                        if let educationIndex = currentEducationIndex, 
                                           educationIndex < formData.educations.count {
                                            formData.educations[educationIndex].educationalDetails = newValue
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
            loadEducationalDetails()
        }
        .onDisappear {
            saveEducationalDetails()
        }
    }
}

#Preview {
    let testFormData = SurveyFormData()
    // Добавляем тестовое образование
    let education = EducationData()
    education.schoolName = "Test University"
    testFormData.educations = [education]
    
    let testSurveyManager = SurveyManager(context: PersistenceController.preview.container.viewContext)
    testSurveyManager.formData = testFormData
    
    return EducationalDetails(formData: testFormData,
                            currentEducationIndex: .constant(0),
                            showingEducationalDetails: .constant(true),
                            showingNewEducation: .constant(false),
                            surveyManager: testSurveyManager)
}

