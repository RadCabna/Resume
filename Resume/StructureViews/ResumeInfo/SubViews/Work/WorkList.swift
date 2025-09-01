//
//  WorkList.swift
//  Resume
//
//  Created by Алкександр Степанов on 01.09.2025.
//

import SwiftUI

struct WorkList: View {
    @ObservedObject var formData: SurveyFormData
    @Binding var showingNewWork: Bool
    @Binding var justSavedWork: Bool
    @Binding var editingWorkIndex: Int?
    
    private func addNewWork() {
        editingWorkIndex = nil
        showingNewWork = true
        justSavedWork = false
    }
    
    private func editWork(at index: Int) {
        editingWorkIndex = index
        showingNewWork = true
        justSavedWork = false
    }
    
    private func deleteWork(at index: Int) {
        formData.works.remove(at: index)
    }
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                Text("Employment History")
                    .font(Font.custom("Figtree-Bold", size: screenHeight*0.03))
                    .foregroundStyle(Color.black)
                    .lineSpacing(0)
                ForEach(Array(formData.works.enumerated()), id: \.element.id) { index, work in
                    Image(.employmentFrame)
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenWidth*0.9)
                        .overlay(
                            VStack(alignment: .leading, spacing: screenHeight*0.015) {
                                Text(formData.works[index].companyName)
                                    .font(Font.custom("Figtree-Medium", size: screenHeight*0.025))
                                    .foregroundStyle(Color.onboardingColor2)
                                HStack {
                                    Text(formData.works[index].whenStart)
                                        .font(Font.custom("Figtree-Medium", size: screenHeight*0.02))
                                        .foregroundStyle(Color.onboardingColor2)
                                    Text("- \(formData.works[index].isCurentlyWork ? "Present" : formData.works[index].whenFinished)")
                                        .font(Font.custom("Figtree-Medium", size: screenHeight*0.02))
                                        .foregroundStyle(Color.onboardingColor2)
                                }
                                HStack {
                                    Image(.editButton)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: screenHeight*0.025)
                                        .onTapGesture {
                                            editWork(at: index)
                                        }
                                    Image(.deleteButton)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: screenHeight*0.025)
                                        .onTapGesture {
                                            deleteWork(at: index)
                                        }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                            }
                                .padding(screenHeight*0.025)
                        )
                }
                Spacer()
                Button(action: addNewWork) {
                    Text("+ Add Another Institution")
                        .font(Font.custom("Figtree-Bold", size: screenHeight*0.025))
                        .foregroundStyle(Color.onboardingColor1)
                        .lineSpacing(0)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .frame(minHeight: screenHeight*0.6)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .frame(maxWidth: screenWidth*0.9)
            .padding(.top, screenHeight*0.25)
            .padding(.bottom, screenHeight*0.15)
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
    return WorkList(formData: testFormData, showingNewWork: .constant(false), justSavedWork: .constant(false), editingWorkIndex: .constant(nil))
}
