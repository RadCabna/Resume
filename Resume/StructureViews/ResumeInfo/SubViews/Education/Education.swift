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
    
    // Привязки к локальным переменным из MainView (для NewEducation)
    @Binding var schoolName: String
    @Binding var whenStart: String
    @Binding var whenFinished: String
    @Binding var isCurrentlyStudying: Bool
    
    // Состояние подэкрана из MainView
    @Binding var showingNewEducation: Bool
    @Binding var justSavedEducation: Bool
    @Binding var editingEducationIndex: Int?
    
    var body: some View {
        ZStack {
            if showingNewEducation {
                NewEducation(
                    formData: formData,
                    schoolName: $schoolName,
                    whenStart: $whenStart,
                    whenFinished: $whenFinished,
                    isCurrentlyStudying: $isCurrentlyStudying,
                    editingEducationIndex: $editingEducationIndex
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
    
    return EducationView(
        formData: testFormData,
        schoolName: .constant(""),
        whenStart: .constant(""),
        whenFinished: .constant(""),
        isCurrentlyStudying: .constant(false),
        showingNewEducation: .constant(true),
        justSavedEducation: .constant(false),
        editingEducationIndex: .constant(nil)
    )
}



