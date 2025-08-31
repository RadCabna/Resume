//
//  EducationList.swift
//  Resume
//
//  Created by Алкександр Степанов on 31.08.2025.
//

import SwiftUI

struct EducationList: View {
    @State private var stepNumber = 2
    @State private var stepsTextArray = Arrays.stepsTextArray
    @ObservedObject var formData: SurveyFormData
    
    // Прямое управление состоянием подэкрана
    @Binding var showingNewEducation: Bool
    
    private func addNewEducation() {
        showingNewEducation = true // Переходим к NewEducation
    }
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                Text("Education History")
                    .font(Font.custom("Figtree-Bold", size: screenHeight*0.03))
                    .foregroundStyle(Color.black)
                    .lineSpacing(0)
                ForEach(Array(formData.educations.enumerated()), id: \.element.id) { index, education in
                    Image(.educationFrame)
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenWidth*0.9)
                        .overlay(
                            VStack(alignment: .leading, spacing: screenHeight*0.015) {
                                Text(formData.educations[index].schoolName)
                                    .font(Font.custom("Figtree-Medium", size: screenHeight*0.025))
                                    .foregroundStyle(Color.onboardingColor2)
                                HStack {
                                    Text(formData.educations[index].whenStart)
                                        .font(Font.custom("Figtree-Medium", size: screenHeight*0.02))
                                        .foregroundStyle(Color.onboardingColor2)
                                    Text("- \(formData.educations[index].isCurrentlyStudying ? "Present" : formData.educations[index].whenFinished)")
                                        .font(Font.custom("Figtree-Medium", size: screenHeight*0.02))
                                        .foregroundStyle(Color.onboardingColor2)
                                }
                                HStack {
                                    Image(.editButton)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: screenHeight*0.025)
                                    Image(.deleteButton)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: screenHeight*0.025)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                                .padding()
                            }
                                .padding()
                        )
                }
                Spacer()
                Button(action: addNewEducation) {
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
       
       // Создаем первое образование с данными
       let education1 = EducationData()
       education1.schoolName = "Stanford University"
       education1.whenStart = "09/2018"
       education1.whenFinished = "06/2022"
       education1.isCurrentlyStudying = false
       
       // Создаем второе образование (текущее)
       let education2 = EducationData()
       education2.schoolName = "MIT"
       education2.whenStart = "09/2022"
       education2.whenFinished = "Present"
       education2.isCurrentlyStudying = true
    
    let education3 = EducationData()
    education3.schoolName = "MIT"
    education3.whenStart = "09/2022"
    education3.whenFinished = "present"
    education3.isCurrentlyStudying = true
       
       // Добавляем в массив
       testFormData.educations = [education1, education2, education3, education2]
       
       return EducationList(formData: testFormData, showingNewEducation: .constant(false))}
