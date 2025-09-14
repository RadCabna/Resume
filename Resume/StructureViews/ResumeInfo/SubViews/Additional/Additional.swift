//
//  Additional.swift
//  Resume
//
//  Created by Алкександр Степанов on 14.09.2025.
//

import SwiftUI

struct Additional: View {
    @ObservedObject var surveyManager: SurveyManager
    @StateObject private var keyboardObserver = KeyboardObserver()
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: screenHeight*0.02) {
                Text("Hard Skills")
                    .font(Font.custom("Figtree-Bold", size: screenHeight*0.025))
                    .foregroundStyle(Color.black)
                ForEach(Array(surveyManager.formData.additionalSkills.hardSkills.enumerated()), id: \.element.name) { index, skill in
                    Point(
                        point: skill,
                        onTap: {
                            surveyManager.toggleHardSkill(at: index)
                        }
                    )
                }
                
                Text("Soft Skills")
                    .font(Font.custom("Figtree-Bold", size: screenHeight*0.025))
                    .foregroundStyle(Color.black)
                    .padding(.top, screenHeight*0.02)
                ForEach(Array(surveyManager.formData.additionalSkills.softSkills.enumerated()), id: \.element.name) { index, skill in
                    Point(
                        point: skill,
                        onTap: {
                            surveyManager.toggleSoftSkill(at: index)
                        }
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .frame(maxWidth: screenWidth*0.9)
            .padding(.top, screenHeight*0.25)
            .padding(.bottom, keyboardObserver.isKeyboardVisible ? screenHeight*0.35 : screenHeight*0.15)
            .animation(.easeInOut(duration: 0.3), value: keyboardObserver.isKeyboardVisible)
        }
    }
}

#Preview {
    let testSurveyManager = SurveyManager(context: PersistenceController.preview.container.viewContext)
    return Additional(surveyManager: testSurveyManager)
}
