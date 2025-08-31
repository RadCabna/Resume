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
//                    TextField("JakeParker@gmail.com", text: $formData.email)
//                        .font(Font.custom("Figtree-Regular", size: screenHeight*0.022))
//                        .foregroundStyle(Color.black)
//                        .padding(.horizontal, screenWidth*0.1)
//                        .keyboardType(.emailAddress)
//                        .autocapitalization(.none)
//                        .disableAutocorrection(true)
//                        .textContentType(.emailAddress)
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
    EducationView()
}
