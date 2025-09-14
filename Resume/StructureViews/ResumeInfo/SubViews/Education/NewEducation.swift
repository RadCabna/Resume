//
//  NewEducation.swift
//  Resume
//
//  Created by Алкександр Степанов on 31.08.2025.
//

import SwiftUI

struct NewEducation: View {
    @State private var stepNumber = 2
    @State private var stepsTextArray = Arrays.stepsTextArray
    @ObservedObject var formData: SurveyFormData
    
    // Привязки к переменным из MainView через EducationView
    @Binding var schoolName: String
    @Binding var whenStart: String
    @Binding var whenFinished: String
    @Binding var isCurrentlyStudying: Bool
    @Binding var editingEducationIndex: Int?
    @Binding var showingEducationalDetails: Bool
    @Binding var currentEducationIndex: Int?
    
    // Отслеживание клавиатуры
    @StateObject private var keyboardObserver = KeyboardObserver()
    
    func saveEducationData() {
        // Создаем новое образование из локальных данных
        let newEducation = EducationData()
        newEducation.schoolName = schoolName
        newEducation.whenStart = whenStart
        newEducation.whenFinished = isCurrentlyStudying ? "Present" : whenFinished
        newEducation.isCurrentlyStudying = isCurrentlyStudying
        
        // Добавляем в массив
        formData.educations.append(newEducation)
        
        // Переход к EducationalDetails для этого образования
        currentEducationIndex = formData.educations.count - 1
        showingEducationalDetails = true
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    Text(stepsTextArray[stepNumber][0])
                        .font(Font.custom("Figtree-Medium", size: screenHeight*0.025))
                        .foregroundStyle(Color.black)
                    ZStack {
                        Image(.textFieldFrame)
                            .resizable()
                            .scaledToFit()
                            .frame(width: screenWidth*0.9)
                        TextField("Stanford University", text: $schoolName)
                            .font(Font.custom("Figtree-Regular", size: screenHeight*0.022))
                            .foregroundStyle(Color.black)
                            .padding(.horizontal, screenWidth*0.1)
                            .keyboardType(.default)
                            .autocapitalization(.words)
                            .disableAutocorrection(false)
                    }
                    Text("When did you start?")
                        .font(Font.custom("Figtree-Medium", size: screenHeight*0.025))
                        .foregroundStyle(Color.black)
                    ZStack {
                        Image(.textFieldFrame)
                            .resizable()
                            .scaledToFit()
                            .frame(width: screenWidth*0.9)
                        TextField("mm  /  yyyy", text: $whenStart)
                            .font(Font.custom("Figtree-Regular", size: screenHeight*0.022))
                            .foregroundStyle(Color.black)
                            .padding(.horizontal, screenWidth*0.1)
                            .keyboardType(.numbersAndPunctuation)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    Text(stepsTextArray[stepNumber][2])
                        .font(Font.custom("Figtree-Medium", size: screenHeight*0.014))
                        .foregroundStyle(Color.onboardingColor2)
                        .padding(.bottom)
                    Text("When did you finish?")
                        .font(Font.custom("Figtree-Medium", size: screenHeight*0.025))
                        .foregroundStyle(Color.black)
                    if !isCurrentlyStudying {
                        ZStack {
                            Image(.textFieldFrame)
                                .resizable()
                                .scaledToFit()
                                .frame(width: screenWidth*0.9)
                            TextField("mm  /  yyyy", text: $whenFinished)
                                .font(Font.custom("Figtree-Regular", size: screenHeight*0.022))
                                .foregroundStyle(Color.black)
                                .padding(.horizontal, screenWidth*0.1)
                                .keyboardType(.numbersAndPunctuation)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                    } else {
                        ZStack {
                            Image(.textFieldFrame)
                                .resizable()
                                .scaledToFit()
                                .frame(width: screenWidth*0.9)
                            Text("Present")
                                .font(Font.custom("Figtree-Regular", size: screenHeight*0.022))
                                .foregroundStyle(Color.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, screenWidth*0.1)
                        }
                        .frame(minHeight: screenHeight*0.03)
                    }
                    Text(stepsTextArray[stepNumber][4])
                        .font(Font.custom("Figtree-Medium", size: screenHeight*0.014))
                        .foregroundStyle(Color.onboardingColor2)
                        .padding(.bottom)
                    HStack {
                        Toggle("", isOn: $isCurrentlyStudying)
                            .toggleStyle(CustomToggle())
                        Text("Present")
                            .font(Font.custom("Figtree-Regular", size: screenHeight*0.02))
                            .foregroundStyle(Color.black)
                    }
                    .padding(.bottom)
                    Text(stepsTextArray[stepNumber][5])
                        .font(Font.custom("Figtree-Medium", size: screenHeight*0.014))
                        .foregroundStyle(Color.onboardingColor2)
                        .padding(.bottom)
                    


                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .frame(maxWidth: screenWidth*0.9)
                .padding(.top, screenHeight*0.25)
                .padding(.bottom, keyboardObserver.isKeyboardVisible ? screenHeight*0.35 : screenHeight*0.15)
                .animation(.easeInOut(duration: 0.3), value: keyboardObserver.isKeyboardVisible)
        }
        .onAppear {
            // Загружаем данные при редактировании
            if let editIndex = editingEducationIndex, editIndex < formData.educations.count {
                let education = formData.educations[editIndex]
                schoolName = education.schoolName
                whenStart = education.whenStart
                whenFinished = education.whenFinished
                isCurrentlyStudying = education.isCurrentlyStudying
                print("🔄 NewEducation: загружены данные для редактирования - \(education.schoolName), educationalDetails: '\(education.educationalDetails)'")
            }
        }
    }
}

#Preview {
    let testFormData = SurveyFormData()
    // Оставляем массив пустым для тестирования NewEducation
    return NewEducation(
        formData: testFormData,
        schoolName: .constant(""),
        whenStart: .constant(""),
        whenFinished: .constant(""),
        isCurrentlyStudying: .constant(false),
        editingEducationIndex: .constant(nil),
        showingEducationalDetails: .constant(false),
        currentEducationIndex: .constant(nil)
    )
}

struct CustomToggle: ToggleStyle {
    var screenHeight = UIScreen.main.bounds.height
    var screenWidth = UIScreen.main.bounds.width
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Image(configuration.isOn ? "toggleBackOn" : "toggleBackOff")
                .resizable()
                .scaledToFit()
                .frame(height: screenHeight * 0.04)
            Image(configuration.isOn ? "toggleOn" : "toggleOff")
                .resizable()
                .scaledToFit()
                .frame(height: screenHeight*0.024)
                .offset(x: configuration.isOn ? screenHeight * 0.018 : -screenHeight * 0.018)
                .animation(.easeInOut(duration: 0.2), value: configuration.isOn)
        }
        .onTapGesture {
            configuration.isOn.toggle()
        }
    }
}
