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
    
    @Binding var companyName: String
    @Binding var position: String
    @Binding var whenStart: String
    @Binding var whenFinished: String
    @Binding var companiLocation: String
    @Binding var isCurentlyWork: Bool
    @Binding var showingNewWork: Bool
    @Binding var justSavedWork: Bool
    @Binding var editingWorkIndex: Int?
    
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
                        editingWorkIndex: $editingWorkIndex
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
   return WorkView(formData: testFormData,
             companyName: .constant(""),
             position: .constant(""),
             whenStart: .constant(""),
             whenFinished: .constant(""),
             companiLocation: .constant(""),
             isCurentlyWork: .constant(false),
             showingNewWork: .constant(false),
             justSavedWork: .constant(false),
             editingWorkIndex: .constant(nil)
    )
}
