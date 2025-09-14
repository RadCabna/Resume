//
//  Education.swift
//  Resume
//
//  Created by Алкександр Степанов on 31.08.2025.
//

import SwiftUI

struct EducationView: View {
    @State private var stepNumber = 2
    @State private var stepsTextArray = Arrays.stepsTextArray
    @ObservedObject var formData: SurveyFormData
    @ObservedObject var surveyManager: SurveyManager
    
    // Привязки к локальным переменным из MainView (для NewEducation)
    @Binding var schoolName: String
    @Binding var whenStart: String
    @Binding var whenFinished: String
    @Binding var isCurrentlyStudying: Bool
    
    // Состояние подэкрана из MainView
    @Binding var showingNewEducation: Bool
    @Binding var justSavedEducation: Bool
    @Binding var editingEducationIndex: Int?
    
    // Состояния для навигации через EducationalDetails (Binding из MainView)
    @Binding var showingEducationalDetails: Bool
    @Binding var currentEducationIndex: Int?
    
    var body: some View {
        ZStack {
            if showingNewEducation {
                NewEducation(
                    formData: formData,
                    schoolName: $schoolName,
                    whenStart: $whenStart,
                    whenFinished: $whenFinished,
                    isCurrentlyStudying: $isCurrentlyStudying,
                    editingEducationIndex: $editingEducationIndex,
                    showingEducationalDetails: $showingEducationalDetails,
                    currentEducationIndex: $currentEducationIndex
                )
            } else if showingEducationalDetails {
                EducationalDetails(formData: formData,
                                 currentEducationIndex: $currentEducationIndex,
                                 showingEducationalDetails: $showingEducationalDetails,
                                 showingNewEducation: $showingNewEducation,
                                 surveyManager: surveyManager
                )
            } else {
                EducationList(
                    formData: formData,
                    showingNewEducation: $showingNewEducation,
                    justSavedEducation: $justSavedEducation,
                    editingEducationIndex: $editingEducationIndex
                )
            }
        }
    }
}

#Preview {
    let testFormData = SurveyFormData()
    // Для тестирования NewEducation - оставьте массив пустым
    // testFormData.educations = []
    
    // Для тестирования EducationList - раскомментируйте строки ниже:
    let education1 = EducationData()
    education1.schoolName = "Stanford University"
    education1.whenStart = "09/2018"
    education1.whenFinished = "06/2022"
    education1.isCurrentlyStudying = false
    testFormData.educations = [education1]
    
    let testSurveyManager = SurveyManager(context: PersistenceController.preview.container.viewContext)
    testSurveyManager.formData = testFormData
    
    return EducationView(
        formData: testFormData,
        surveyManager: testSurveyManager,
        schoolName: .constant(""),
        whenStart: .constant(""),
        whenFinished: .constant(""),
        isCurrentlyStudying: .constant(false),
        showingNewEducation: .constant(true),
        justSavedEducation: .constant(false),
        editingEducationIndex: .constant(nil),
        showingEducationalDetails: .constant(false),
        currentEducationIndex: .constant(nil)
    )
}



