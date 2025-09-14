//
//  Work.swift
//  Resume
//
//  Created by Алкександр Степанов on 01.09.2025.
//

import SwiftUI

struct WorkView: View {
    @State private var stepNumber = 3
    @State private var stepsTextArray = Arrays.stepsTextArray
    @ObservedObject var formData: SurveyFormData
    @ObservedObject var surveyManager: SurveyManager
    
    @Binding var companyName: String
    @Binding var position: String
    @Binding var whenStart: String
    @Binding var whenFinished: String
    @Binding var companiLocation: String
    @Binding var isCurentlyWork: Bool
    @Binding var showingNewWork: Bool
    @Binding var justSavedWork: Bool
    @Binding var editingWorkIndex: Int?
    
    // Состояния для навигации через Responsibilities (теперь Binding из MainView)
    @Binding var showingResponsibilities: Bool
    @Binding var currentWorkIndex: Int?
    
    var body: some View {
        ZStack {
            if showingNewWork {
                NewWork(formData: formData,
                        companyName: $companyName,
                        position: $position,
                        whenStart: $whenStart,
                        whenFinished: $whenFinished,
                        companiLocation: $companiLocation,
                        isCurentlyWork: $isCurentlyWork,
                        editingWorkIndex: $editingWorkIndex,
                        showingResponsibilities: $showingResponsibilities,
                        currentWorkIndex: $currentWorkIndex
                )
            } else if showingResponsibilities {
                Responsibilities(formData: formData,
                               surveyManager: surveyManager,
                               currentWorkIndex: $currentWorkIndex,
                               showingResponsibilities: $showingResponsibilities,
                               showingNewWork: $showingNewWork
                )
            } else {
                WorkList(formData: formData,
                         showingNewWork: $showingNewWork,
                         justSavedWork: $justSavedWork,
                         editingWorkIndex: $editingWorkIndex
                )
            }
        }
    }
}

#Preview {
    let testFormData = SurveyFormData()
    let work = WorkData()
    work.companyName = "Company"
    work.whenStart = "10/2010"
    work.whenFinished = "10/2013"
    testFormData.works = [work, work]
    let testSurveyManager = SurveyManager(context: PersistenceController.preview.container.viewContext)
    return WorkView(formData: testFormData,
             surveyManager: testSurveyManager,
             companyName: .constant(""),
             position: .constant(""),
             whenStart: .constant(""),
             whenFinished: .constant(""),
             companiLocation: .constant(""),
             isCurentlyWork: .constant(false),
             showingNewWork: .constant(false),
             justSavedWork: .constant(false),
             editingWorkIndex: .constant(nil),
             showingResponsibilities: .constant(false),
             currentWorkIndex: .constant(nil)
    )
}
