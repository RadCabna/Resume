//
//  Contacts.swift
//  Resume
//
//  Created by Алкександр Степанов on 26.08.2025.
//

import SwiftUI

struct Contacts: View {
    @State private var stepNumber = 1
    @State private var stepsTextArray = Arrays.stepsTextArray
    @ObservedObject var formData: SurveyFormData
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                Text(stepsTextArray[stepNumber][0])
                    .font(Font.custom("Figtree-Bold", size: screenHeight*0.03))
                    .foregroundStyle(Color.black)
                    .lineSpacing(0)
                Text(stepsTextArray[stepNumber][1])
                    .font(Font.custom("Figtree-Medium", size: screenHeight*0.017))
                    .foregroundStyle(Color.onboardingColor2)
                    .padding(.bottom, screenHeight*0.04)
                Text(stepsTextArray[stepNumber][2])
                    .font(Font.custom("Figtree-Medium", size: screenHeight*0.025))
                    .foregroundStyle(Color.black)
                ZStack {
                    Image(.textFieldFrame)
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenWidth*0.9)
                    TextField("JakeParker@gmail.com", text: $formData.email)
                        .font(Font.custom("Figtree-Regular", size: screenHeight*0.022))
                        .foregroundStyle(Color.black)
                        .padding(.horizontal, screenWidth*0.1)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .textContentType(.emailAddress)
                }
                Text(stepsTextArray[stepNumber][3])
                    .font(Font.custom("Figtree-Medium", size: screenHeight*0.025))
                    .foregroundStyle(Color.black)
                ZStack {
                    Image(.textFieldFrame)
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenWidth*0.9)
                    TextField("(415) 555-7293", text: $formData.phone)
                        .font(Font.custom("Figtree-Medium", size: screenHeight*0.022))
                        .foregroundStyle(Color.black)
                        .padding(.horizontal, screenWidth*0.1)
                        .keyboardType(.phonePad)
                }
                Text(stepsTextArray[stepNumber][4])
                    .font(Font.custom("Figtree-Medium", size: screenHeight*0.025))
                    .foregroundStyle(Color.black)
                ZStack {
                    Image(.textFieldFrame)
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenWidth*0.9)
                    TextField("www.example.com", text: $formData.website)
                        .font(Font.custom("Figtree-Medium", size: screenHeight*0.022))
                        .foregroundStyle(Color.black)
                        .padding(.horizontal, screenWidth*0.1)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }
                Text(stepsTextArray[stepNumber][5])
                    .font(Font.custom("Figtree-Medium", size: screenHeight*0.025))
                    .foregroundStyle(Color.black)
                ZStack {
                    Image(.textFieldFrame)
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenWidth*0.9)
                    TextField("1 First Avenue", text: $formData.address)
                        .font(Font.custom("Figtree-Medium", size: screenHeight*0.022))
                        .foregroundStyle(Color.black)
                        .padding(.horizontal, screenWidth*0.1)
                }
                ZStack {
                    Image(.textFieldFrame)
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenWidth*0.9)
                    TextField("Astoria, NY 11102", text: $formData.adress_1)
                        .font(Font.custom("Figtree-Medium", size: screenHeight*0.022))
                        .foregroundStyle(Color.black)
                        .padding(.horizontal, screenWidth*0.1)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .frame(maxWidth: screenWidth*0.9)
            .padding(.top, screenHeight*0.25)
            .padding(.bottom, screenHeight*0.15)
        }
    }
}

#Preview {
    // Создаем тестовые данные для превью
    let testFormData = SurveyFormData()
//    testFormData.email = "test@example.com"
//    testFormData.phone = "+7 123 456 78 90"
//    testFormData.website = "https://example.com"
//    testFormData.address = "Москва, Красная площадь, 1"
    
    return Contacts(formData: testFormData)
}
