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
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                Text(stepsTextArray[stepNumber][0])
                    .font(Font.custom("Figtree-Bold", size: screenHeight*0.03))
                    .foregroundStyle(Color.black)
                    .lineSpacing(0)
                Text(stepsTextArray[stepNumber][1])
                    .font(Font.custom("Figtree-Medium", size: screenHeight*0.015))
                    .foregroundStyle(Color.onboardingColor2)
                    .padding(.bottom, screenHeight*0.04)
                Text(stepsTextArray[stepNumber][2])
                    .font(Font.custom("Figtree-Medium", size: screenHeight*0.025))
                    .foregroundStyle(Color.black)
                Image(.textFieldFrame)
                    .resizable()
                    .scaledToFit()
                    .frame(width: screenWidth*0.9)
                Text(stepsTextArray[stepNumber][3])
                    .font(Font.custom("Figtree-Medium", size: screenHeight*0.025))
                    .foregroundStyle(Color.black)
                Image(.textFieldFrame)
                    .resizable()
                    .scaledToFit()
                    .frame(width: screenWidth*0.9)
                Text(stepsTextArray[stepNumber][4])
                    .font(Font.custom("Figtree-Medium", size: screenHeight*0.025))
                    .foregroundStyle(Color.black)
                Image(.textFieldFrame)
                    .resizable()
                    .scaledToFit()
                    .frame(width: screenWidth*0.9)
                Text(stepsTextArray[stepNumber][5])
                    .font(Font.custom("Figtree-Medium", size: screenHeight*0.025))
                    .foregroundStyle(Color.black)
                Image(.textFieldFrame)
                    .resizable()
                    .scaledToFit()
                    .frame(width: screenWidth*0.9)
                Image(.textFieldFrame)
                    .resizable()
                    .scaledToFit()
                    .frame(width: screenWidth*0.9)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .frame(maxWidth: screenWidth*0.9)
            .padding(.top, screenHeight*0.25)
            .padding(.bottom, screenHeight*0.15)
        }
    }
}

#Preview {
    Contacts()
}
