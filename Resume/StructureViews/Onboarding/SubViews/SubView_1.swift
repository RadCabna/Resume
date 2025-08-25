//
//  SubView_1.swift
//  Resume
//
//  Created by Алкександр Степанов on 24.08.2025.
//

import SwiftUI

struct SubView_1: View {
    var size: CGFloat = 1
    @State private var listOffset: CGFloat = 0
    @State private var aiTextScale: CGFloat = 1
    @State private var aiTextRotation: CGFloat = 0
    @State private var blubScale: CGFloat = 1
    @State private var blubOffset: CGFloat = 0
    @State private var blubRotation: CGFloat = 0
    @State private var writeAIScale: CGFloat = 1
    @State private var writeAIOffset: CGFloat = 0
    @State private var writeAIRotation: CGFloat = 0
    @Binding var viewNumber: Int
    var body: some View {
        
        ZStack {
            Image(.onboardingPartList)
                .resizable()
                .scaledToFit()
                .frame(height: screenHeight*0.4*size)
            VStack {
                Text("Resume")
                    .font(Font.custom("Figtree-ExtraBold", size: screenHeight*0.06*size))
                    .foregroundStyle(Color.onboardingColor1)
                    .textCase(.uppercase)
                Image(.onboardingPartText)
                    .resizable()
                    .scaledToFit()
                    .frame(height: screenHeight*0.145*size)
            }
            Image(.onboardingPartBulb)
                .resizable()
                .scaledToFit()
                .frame(height: screenHeight*0.09*size)
                .offset(x: -screenHeight*0.04)
                .rotationEffect(Angle(degrees: aiTextRotation))
                .offset(x: screenHeight*0.04)
                .offset(x: -screenHeight*0.1 + blubOffset, y: screenHeight*0.03)
            Image(.onboardingPartAIText)
                .resizable()
                .scaledToFit()
                .frame(height: screenHeight*0.11*size)
                .scaleEffect(x: aiTextScale, y: aiTextScale)
                .offset(y: screenHeight*0.04)
            ZStack {
                Image(.onboardingPartStars)
                    .resizable()
                    .scaledToFit()
                    .frame(height: screenHeight*0.08*size)
                Image(.onboardingPartwriteAI)
                    .resizable()
                    .scaledToFit()
                    .frame(height: screenHeight*0.045*size)
                    .scaleEffect(x: writeAIScale, y: writeAIScale)
            }
            .offset(x: screenHeight*0.05, y: screenHeight*0.02)
            .offset(x: writeAIOffset)
        }
        .offset(y: listOffset + screenHeight*0.2)
        
        .onAppear {
            showAnimate()
        }
        .onChange(of: viewNumber) { _ in
            if viewNumber != 0 {
                hideAnimate()
            } else {
                showAnimate()
            }
        }
    }
    
    func showAnimate() {
        withAnimation(Animation.easeInOut(duration: 0.5)) {
            listOffset = -screenHeight*0.2
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(Animation.easeInOut(duration: 1)) {
                aiTextScale = 1.05
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(Animation.easeInOut(duration: 0.5)) {
                aiTextRotation = -10
                blubOffset = -screenHeight*0.05
                writeAIScale = 1.05
                writeAIOffset = screenHeight*0.03
            }
        }
    }
    
    func hideAnimate() {
        withAnimation(Animation.easeInOut(duration: 0.5)) {
            aiTextRotation = 0
            blubOffset = 0
            writeAIScale = 1
            writeAIOffset = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(Animation.easeInOut(duration: 0.5)) {
                listOffset = screenHeight*0.2
            }
        }
    }
    
}

#Preview {
    SubView_1(viewNumber: .constant(0))
}
