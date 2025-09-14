//
//  NewWork.swift
//  Resume
//
//  Created by Алкександр Степанов on 01.09.2025.
//

import SwiftUI

struct NewWork: View {
    @State private var stepNumber = 3
    @State private var stepsTextArray = Arrays.stepsTextArray
    @ObservedObject var formData: SurveyFormData
    
    @StateObject private var keyboardObserver = KeyboardObserver()
    
    @Binding var companyName: String
    @Binding var position: String
    @Binding var whenStart: String
    @Binding var whenFinished: String
    @Binding var companiLocation: String
    @Binding var isCurentlyWork: Bool
    @Binding var editingWorkIndex: Int?
    @Binding var showingResponsibilities: Bool
    @Binding var currentWorkIndex: Int?
    
    func saveWorkData() {
        let newWork = WorkData()
        newWork.companyName = companyName
        newWork.position = position
        newWork.whenStart = whenStart
        newWork.whenFinished = whenFinished
        newWork.companiLocation = companiLocation
        newWork.isCurentlyWork = isCurentlyWork
        formData.works.append(newWork)
        
        // Переход к Responsibilities для этой работы
        currentWorkIndex = formData.works.count - 1
        showingResponsibilities = true
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
                        TextField("Example Co.", text: $companyName)
                            .font(Font.custom("Figtree-Regular", size: screenHeight*0.022))
                            .foregroundStyle(Color.black)
                            .padding(.horizontal, screenWidth*0.1)
                            .keyboardType(.default)
                            .autocapitalization(.words)
                            .disableAutocorrection(false)
                    }
                    Text(stepsTextArray[stepNumber][1])
                        .font(Font.custom("Figtree-Medium", size: screenHeight*0.025))
                        .foregroundStyle(Color.black)
                    ZStack {
                        Image(.textFieldFrame)
                            .resizable()
                            .scaledToFit()
                            .frame(width: screenWidth*0.9)
                        TextField("Astoria, NY", text: $companiLocation)
                            .font(Font.custom("Figtree-Regular", size: screenHeight*0.022))
                            .foregroundStyle(Color.black)
                            .padding(.horizontal, screenWidth*0.1)
                            .keyboardType(.default)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    Text(stepsTextArray[stepNumber][2])
                        .font(Font.custom("Figtree-Medium", size: screenHeight*0.025))
                        .foregroundStyle(Color.black)
                    ZStack {
                        Image(.textFieldFrame)
                            .resizable()
                            .scaledToFit()
                            .frame(width: screenWidth*0.9)
                        TextField("Manager", text: $position)
                            .font(Font.custom("Figtree-Regular", size: screenHeight*0.022))
                            .foregroundStyle(Color.black)
                            .padding(.horizontal, screenWidth*0.1)
                            .keyboardType(.default)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    Text(stepsTextArray[stepNumber][3])
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
                    Text(stepsTextArray[stepNumber][4])
                        .font(Font.custom("Figtree-Medium", size: screenHeight*0.014))
                        .foregroundStyle(Color.onboardingColor2)
                        .padding(.bottom)
                    Text(stepsTextArray[stepNumber][5])
                        .font(Font.custom("Figtree-Medium", size: screenHeight*0.025))
                        .foregroundStyle(Color.black)
                    if !isCurentlyWork {
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
                    Text(stepsTextArray[stepNumber][6])
                        .font(Font.custom("Figtree-Medium", size: screenHeight*0.014))
                        .foregroundStyle(Color.onboardingColor2)
                        .padding(.bottom)
                    HStack {
                        Toggle("", isOn: $isCurentlyWork)
                            .toggleStyle(CustomToggle())
                        Text("Present")
                            .font(Font.custom("Figtree-Regular", size: screenHeight*0.02))
                            .foregroundStyle(Color.black)
                    }
                    .padding(.bottom)
                    Text(stepsTextArray[stepNumber][7])
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
            if let editIndex = editingWorkIndex, editIndex < formData.works.count {
                let work = formData.works[editIndex]
                companyName = work.companyName
                position = work.position
                whenStart = work.whenStart
                whenFinished = work.whenFinished
                companiLocation = work.companiLocation
                isCurentlyWork = work.isCurentlyWork
                print("🔄 NewWork: загружены данные для редактирования - \(work.companyName)")
            } else {
                print("🆕 NewWork: режим создания новой работы")
            }
        }
    }
}

#Preview {
    let testFormData = SurveyFormData()
    // Оставляем массив пустым для тестирования NewWork
    return NewWork(
        formData: testFormData,
        companyName: .constant(""),
        position: .constant(""),
        whenStart: .constant(""),
        whenFinished: .constant(""),
        companiLocation: .constant(""),
        isCurentlyWork: .constant(false),
        editingWorkIndex: .constant(nil),
        showingResponsibilities: .constant(false),
        currentWorkIndex: .constant(nil)
    )
}


