//
//  MainView.swift
//  Resume
//
//  Created by Алкександр Степанов on 25.08.2025.
//

import SwiftUI

struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var surveyManager: SurveyManager
    @State private var stepMenuPresented = false
    @State private var blurRadius: CGFloat = 0
    
    @State private var educationSchoolName = ""
    @State private var educationWhenStart = ""
    @State private var educationWhenFinished = ""
    @State private var educationIsCurrentlyStudying = false
    @State private var showingNewEducation = true
    @State private var justSavedEducation = false
    @State private var editingEducationIndex: Int? = nil
    
    @State private var companyName: String = ""
    @State private var position: String = ""
    @State private var whenStart: String = ""
    @State private var whenFinished: String = ""
    @State private var companiLocation: String = ""
    @State private var isCurentlyWork: Bool = false
    @State private var showingNewWork: Bool = true
    @State private var justSavedWork: Bool = false
    @State private var editingWorkIndex: Int? = nil
    init() {
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
                .frame(width: screenWidth, height: screenHeight*0.15)
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
                            if surveyManager.stepNumber == 3 {
                                // При возврате к Work определяем состояние
                                showingNewWork = surveyManager.formData.works.isEmpty
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
                showingNewEducation: $showingNewEducation,
                justSavedEducation: $justSavedEducation,
                editingEducationIndex: $editingEducationIndex
            )
        case 3:
            WorkView(formData: surveyManager.formData,
                     companyName: $companyName,
                     position: $position,
                     whenStart: $whenStart,
                     whenFinished: $whenFinished,
                     companiLocation: $companiLocation,
                     isCurentlyWork: $isCurentlyWork,
                     showingNewWork: $showingNewWork,
                     justSavedWork: $justSavedWork,
                     editingWorkIndex: $editingWorkIndex
            )
        case 4:
            ClearSummary(formData: surveyManager.formData)
        case 7:
            Finish(formData: surveyManager.formData, surveyManager: surveyManager)
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
        case 3:
            // Work - специальная логика
            saveWorkData()
        default:
            print("💾 Шаг \(surveyManager.stepNumber) - сохранение не настроено")
        }
    }
    
    private func saveEducationData() {
        if showingNewEducation {
            // Показывается NewEducation - сохраняем локальные данные
            if !educationSchoolName.trimmingCharacters(in: .whitespaces).isEmpty {
                
                if let editIndex = editingEducationIndex, editIndex < surveyManager.formData.educations.count {
                    // Режим редактирования - обновляем существующее образование
                    let education = surveyManager.formData.educations[editIndex]
                    education.schoolName = educationSchoolName
                    education.whenStart = educationWhenStart
                    education.whenFinished = educationIsCurrentlyStudying ? "Present" : educationWhenFinished
                    education.isCurrentlyStudying = educationIsCurrentlyStudying
                    print("✏️ Education: отредактировано образование - \(educationSchoolName)")
                } else {
                    // Режим добавления нового - создаем новое образование
                    let newEducation = EducationData()
                    newEducation.schoolName = educationSchoolName
                    newEducation.whenStart = educationWhenStart
                    newEducation.whenFinished = educationIsCurrentlyStudying ? "Present" : educationWhenFinished
                    newEducation.isCurrentlyStudying = educationIsCurrentlyStudying
                    
                    surveyManager.formData.educations.append(newEducation)
                    print("💾 Education: сохранено новое образование - \(educationSchoolName)")
                }
                
                // Очищаем локальные переменные и состояние
                educationSchoolName = ""
                educationWhenStart = ""
                educationWhenFinished = ""
                educationIsCurrentlyStudying = false
                editingEducationIndex = nil
                
                // Переключаемся на EducationList
                showingNewEducation = false
                justSavedEducation = true // Предотвращаем сразу переход к следующему экрану
                print("🔄 Education: переключились на EducationList")
            } else {
                print("💾 Education: нет данных для сохранения")
            }
        } else {
            // Показывается EducationList - можно переходить к следующему экрану
            print("💾 Education: переход к следующему экрану")
        }
    }
    
    private func saveWorkData() {
        if showingNewWork {
            // Показывается NewWork - сохраняем локальные данные
            if !companyName.trimmingCharacters(in: .whitespaces).isEmpty {
                
                if let editIndex = editingWorkIndex, editIndex < surveyManager.formData.works.count {
                    // Режим редактирования - обновляем существующую работу
                    let work = surveyManager.formData.works[editIndex]
                    work.companyName = companyName
                    work.position = position
                    work.whenStart = whenStart
                    work.whenFinished = isCurentlyWork ? "Present" : whenFinished
                    work.companiLocation = companiLocation
                    work.isCurentlyWork = isCurentlyWork
                    print("✏️ Work: отредактирована работа - \(companyName)")
                } else {
                    // Режим добавления нового - создаем новую работу
                    let newWork = WorkData()
                    newWork.companyName = companyName
                    newWork.position = position
                    newWork.whenStart = whenStart
                    newWork.whenFinished = isCurentlyWork ? "Present" : whenFinished
                    newWork.companiLocation = companiLocation
                    newWork.isCurentlyWork = isCurentlyWork
                    
                    surveyManager.formData.works.append(newWork)
                    print("💾 Work: сохранена новая работа - \(companyName)")
                }
                
                // Очищаем локальные переменные и состояние
                companyName = ""
                position = ""
                whenStart = ""
                whenFinished = ""
                companiLocation = ""
                isCurentlyWork = false
                editingWorkIndex = nil
                
                // Переключаемся на WorkList
                showingNewWork = false
                justSavedWork = true // Предотвращаем сразу переход к следующему экрану
                print("🔄 Work: переключились на WorkList")
            } else {
                print("💾 Work: нет данных для сохранения")
            }
        } else {
            // Показывается WorkList - можно переходить к следующему экрану
            print("💾 Work: переход к следующему экрану")
        }
    }
    
    private func canProceedToNextStep() -> Bool {
        switch surveyManager.stepNumber {
        case 2: // Education
            // Можно переходить только если показывается EducationList И это не первое нажатие после сохранения
            if !showingNewEducation && !justSavedEducation {
                return true
            } else {
                // Сбрасываем флаг при первом нажатии после сохранения
                if justSavedEducation {
                    justSavedEducation = false
                }
                return false
            }
        case 3: // Work
            // Можно переходить только если показывается WorkList И это не первое нажатие после сохранения
            if !showingNewWork && !justSavedWork {
                return true
            } else {
                // Сбрасываем флаг при первом нажатии после сохранения
                if justSavedWork {
                    justSavedWork = false
                }
                return false
            }
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
