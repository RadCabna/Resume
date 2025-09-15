//
//  MainView.swift
//  Resume
//
//  Created by Алкександр Степанов on 25.08.2025.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var coordinator: Coordinator
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
    
    // Новые состояния для EducationalDetails
    @State private var showingEducationalDetails: Bool = false
    @State private var currentEducationIndex: Int? = nil
    
    @State private var companyName: String = ""
    @State private var position: String = ""
    @State private var whenStart: String = ""
    @State private var whenFinished: String = ""
    @State private var companiLocation: String = ""
    @State private var isCurentlyWork: Bool = false
    @State private var showingNewWork: Bool = true
    @State private var justSavedWork: Bool = false
    @State private var editingWorkIndex: Int? = nil
    
    // Новые состояния для Responsibilities
    @State private var showingResponsibilities: Bool = false
    @State private var currentWorkIndex: Int? = nil
    @State private var responsibilitiesViewRef: Responsibilities? = nil
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
                surveyManager: surveyManager,
                schoolName: $educationSchoolName,
                whenStart: $educationWhenStart,
                whenFinished: $educationWhenFinished,
                isCurrentlyStudying: $educationIsCurrentlyStudying,
                showingNewEducation: $showingNewEducation,
                justSavedEducation: $justSavedEducation,
                editingEducationIndex: $editingEducationIndex,
                showingEducationalDetails: $showingEducationalDetails,
                currentEducationIndex: $currentEducationIndex
            )
        case 3:
            WorkView(formData: surveyManager.formData,
                     surveyManager: surveyManager,
                     companyName: $companyName,
                     position: $position,
                     whenStart: $whenStart,
                     whenFinished: $whenFinished,
                     companiLocation: $companiLocation,
                     isCurentlyWork: $isCurentlyWork,
                     showingNewWork: $showingNewWork,
                     justSavedWork: $justSavedWork,
                     editingWorkIndex: $editingWorkIndex,
                     showingResponsibilities: $showingResponsibilities,
                     currentWorkIndex: $currentWorkIndex
            )
        case 4:
            ClearSummary(formData: surveyManager.formData)
        case 5:
            Additional(surveyManager: surveyManager)
        case 7:
            Finish(formData: surveyManager.formData, surveyManager: surveyManager)
       
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
                    
                    // Обновляем только основные поля, educationalDetails синхронизируется отдельно
                    education.schoolName = educationSchoolName
                    education.whenStart = educationWhenStart
                    education.whenFinished = educationIsCurrentlyStudying ? "Present" : educationWhenFinished
                    education.isCurrentlyStudying = educationIsCurrentlyStudying
                    
                    print("✏️ Education: отредактировано образование - \(educationSchoolName)")
                    print("💾 educationalDetails будут синхронизированы из CoreData")
                    
                    // После редактирования переходим к EducationalDetails для этого образования
                    print("🎯 ПЕРЕД установкой currentEducationIndex: editIndex=\(editIndex), educations.count=\(surveyManager.formData.educations.count)")
                    if editIndex < surveyManager.formData.educations.count {
                        let targetEducation = surveyManager.formData.educations[editIndex]
                        print("🎓 Целевое образование ПЕРЕД синхронизацией: \(targetEducation.schoolName), educationalDetails: '\(targetEducation.educationalDetails)'")
                    }
                    
                    // Синхронизируем данные из CoreData для этого образования
                    surveyManager.syncEducationWithCoreData(at: editIndex)
                    
                    if editIndex < surveyManager.formData.educations.count {
                        let targetEducation = surveyManager.formData.educations[editIndex]
                        print("🎓 Целевое образование ПОСЛЕ синхронизации: \(targetEducation.schoolName), educationalDetails: '\(targetEducation.educationalDetails)'")
                    }
                    
                    currentEducationIndex = editIndex
                    showingEducationalDetails = true
                    print("🔄 Education: переход к EducationalDetails для редактированного образования")
                } else {
                    // Режим добавления нового - создаем новое образование
                    let newEducation = EducationData()
                    newEducation.schoolName = educationSchoolName
                    newEducation.whenStart = educationWhenStart
                    newEducation.whenFinished = educationIsCurrentlyStudying ? "Present" : educationWhenFinished
                    newEducation.isCurrentlyStudying = educationIsCurrentlyStudying
                    
                    surveyManager.formData.educations.append(newEducation)
                    print("💾 Education: сохранено новое образование - \(educationSchoolName)")
                    
                    // Переходим к EducationalDetails для нового образования
                    currentEducationIndex = surveyManager.formData.educations.count - 1
                    showingEducationalDetails = true
                    print("🔄 Education: переход к EducationalDetails для нового образования")
                }
                
                // Очищаем локальные переменные и состояние
                educationSchoolName = ""
                educationWhenStart = ""
                educationWhenFinished = ""
                educationIsCurrentlyStudying = false
                editingEducationIndex = nil
                
                // НЕ переключаемся на EducationList, а остаемся в NewEducation до завершения EducationalDetails
                showingNewEducation = false // Скрываем NewEducation, но не показываем EducationList
                justSavedEducation = true // Предотвращаем сразу переход к следующему экрану
            } else {
                print("💾 Education: нет данных для сохранения")
            }
        } else if showingEducationalDetails {
            // Показывается EducationalDetails - вызываем completeEducationalDetails
            print("💾 Education: завершение EducationalDetails")
            completeEducationalDetailsFromMainView()
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
                    
                    // Сохраняем базовые поля работы в CoreData
                    surveyManager.saveDraft()
                    
                    // Синхронизируем responsibilities из CoreData в formData
                    surveyManager.syncWorkWithCoreData(at: editIndex)
                    
                    // После редактирования переходим к Responsibilities для этой работы
                    currentWorkIndex = editIndex
                    showingResponsibilities = true
                    print("🔄 Work: переход к Responsibilities для редактированной работы")
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
                    
                    // Сохраняем новую работу в CoreData перед переходом к Responsibilities
                    surveyManager.saveDraft()
                    
                    // Переходим к Responsibilities для новой работы
                    currentWorkIndex = surveyManager.formData.works.count - 1
                    showingResponsibilities = true
                    print("🔄 Work: переход к Responsibilities для новой работы")
                }
                
                // Очищаем локальные переменные и состояние
                companyName = ""
                position = ""
                whenStart = ""
                whenFinished = ""
                companiLocation = ""
                isCurentlyWork = false
                editingWorkIndex = nil
                
                // НЕ переключаемся на WorkList, а остаемся в NewWork до завершения Responsibilities
                showingNewWork = false // Скрываем NewWork, но не показываем WorkList
                justSavedWork = true // Предотвращаем сразу переход к следующему экрану
            } else {
                print("💾 Work: нет данных для сохранения")
            }
        } else if showingResponsibilities {
            // Показывается Responsibilities - вызываем completeResponsibilities
            print("💾 Work: завершение Responsibilities")
            completeResponsibilitiesFromMainView()
        } else {
            // Показывается WorkList - можно переходить к следующему экрану
            print("💾 Work: переход к следующему экрану")
        }
    }
    
    private func completeEducationalDetailsFromMainView() {
        // Сохраняем данные ПЕРЕД сбросом индекса
        if let educationIndex = currentEducationIndex, educationIndex < surveyManager.formData.educations.count {
            print("💾 EducationalDetails: завершение для образования \(surveyManager.formData.educations[educationIndex].schoolName)")
            
            // Принудительно сохраняем educationalDetails в CoreData перед сбросом индекса
            surveyManager.saveEducationToCoreData(at: educationIndex)
            
            // Завершаем EducationalDetails и переходим к EducationList
            showingEducationalDetails = false
            showingNewEducation = false // Переход к EducationList
            currentEducationIndex = nil
            justSavedEducation = true // Предотвращаем сразу переход к следующему экрану
            
            print("🔄 EducationalDetails: переход к EducationList")
        }
    }
    
    private func completeResponsibilitiesFromMainView() {
        // Сохраняем responsibilities в CoreData перед завершением
        if let workIndex = currentWorkIndex, workIndex < surveyManager.formData.works.count {
            print("💾 Responsibilities: завершение для работы \(surveyManager.formData.works[workIndex].companyName)")
            
            // Сохраняем responsibilities в CoreData
            surveyManager.saveWorkToCoreData(at: workIndex)
            
            // Завершаем Responsibilities и переходим к WorkList
            showingResponsibilities = false
            showingNewWork = false // Переход к WorkList
            currentWorkIndex = nil
            justSavedWork = true // Предотвращаем сразу переход к следующему экрану
            
            print("🔄 Responsibilities: переход к WorkList")
        }
    }
    
    private func canProceedToNextStep() -> Bool {
        switch surveyManager.stepNumber {
        case 2: // Education
            // Можно переходить только если показывается EducationList И это не первое нажатие после сохранения
            if !showingNewEducation && !showingEducationalDetails && !justSavedEducation {
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
            if !showingNewWork && !showingResponsibilities && !justSavedWork {
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
