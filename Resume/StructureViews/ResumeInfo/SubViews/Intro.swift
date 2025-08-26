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
    var body: some View {
        VStack(alignment: .leading) {
            Text(stepsTextArray[stepNumber][0])
                .font(Font.custom("Figtree-Bold", size: screenHeight*0.045))
                .foregroundStyle(Color.black)
            Text(stepsTextArray[stepNumber][1])
                .font(Font.custom("Figtree-Medium", size: screenHeight*0.027))
                .foregroundStyle(Color.black)
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .frame(maxWidth: screenWidth*0.9)
        .padding(.top, screenHeight*0.25)
    }
}

#Preview {
    Intro()
}
