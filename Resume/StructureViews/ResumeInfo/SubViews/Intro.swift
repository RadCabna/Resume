//
//  Intro.swift
//  Resume
//
//  Created by Алкександр Степанов on 26.08.2025.
//

import SwiftUI

struct Intro: View {
    @State private var stepNumber = 0
    @State private var stepsTextArray = Arrays.stepsTextArray
    @ObservedObject var formData: SurveyFormData
    
    // Локальные переменные для ввода данных
    @State private var name = ""
    @State private var surname = ""
    
    // Отслеживание клавиатуры
    @StateObject private var keyboardObserver = KeyboardObserver()
    
    func saveIntroData() {
        formData.name = name
        formData.surname = surname
    }
    var body: some View {
        VStack(alignment: .leading) {
            Text(stepsTextArray[stepNumber][0])
                .font(Font.custom("Figtree-Bold", size: screenHeight*0.045))
                .foregroundStyle(Color.black)
            Text(stepsTextArray[stepNumber][1])
                .font(Font.custom("Figtree-Medium", size: screenHeight*0.029))
                .foregroundStyle(Color.black)
                .padding(.bottom, screenHeight*0.04)
            Text(stepsTextArray[stepNumber][2])
                .font(Font.custom("Figtree-Medium", size: screenHeight*0.022))
                .foregroundStyle(Color.black)
            ZStack {
                Image(.textFieldFrame)
                    .resizable()
                    .scaledToFit()
                    .frame(width: screenWidth*0.9)
                TextField("Jake", text: $name)
                    .font(Font.custom("Figtree-Regular", size: screenHeight*0.022))
                    .foregroundStyle(Color.black)
                    .padding(.horizontal, screenWidth*0.1)
            }
            Text(stepsTextArray[stepNumber][3])
                .font(Font.custom("Figtree-Medium", size: screenHeight*0.022))
                .foregroundStyle(Color.black)
            ZStack {
                Image(.textFieldFrame)
                    .resizable()
                    .scaledToFit()
                    .frame(width: screenWidth*0.9)
                TextField("Parker", text: $surname)
                    .font(Font.custom("Figtree-Medium", size: screenHeight*0.022))
                    .foregroundStyle(Color.black)
                    .padding(.horizontal, screenWidth*0.1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .frame(maxWidth: screenWidth*0.9)
        .padding(.top, screenHeight*0.25)
//        .padding(.bottom, keyboardObserver.isKeyboardVisible ? screenHeight*0.3 : 0)
        .animation(.easeInOut(duration: 0.3), value: keyboardObserver.isKeyboardVisible)
        .onAppear {
            // Загружаем данные из formData в локальные переменные
            name = formData.name
            surname = formData.surname
        }
        .onDisappear {
            // Сохраняем данные из локальных переменных в formData
            saveIntroData()
        }
    }
}

#Preview {
    // Создаем тестовые данные для превью
    let testFormData = SurveyFormData()
//    testFormData.name = "Алексей"
//    testFormData.surname = "Петров"
    
    return Intro(formData: testFormData)
}
