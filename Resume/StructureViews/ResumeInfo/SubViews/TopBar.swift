//
//  TopBar.swift
//  Resume
//
//  Created by Алкександр Степанов on 25.08.2025.
//

import SwiftUI

struct TopBar: View {
    @AppStorage("limits") var limits = 3
    @ObservedObject var formData: SurveyFormData
    @State private var stepMenuOffset: CGFloat = 0
    @State private var arrowScale: CGFloat = 1
    @State private var arrowSide: CGFloat = -1
    @State private var stepMenuArray = Arrays.stepMenuArray
    @Binding var stepMenuPresented: Bool
    @State private var shadowOpacity: CGFloat = 0
    @Binding var stepNumber: Int
    var body: some View {
        ZStack {
            Color.black.opacity(shadowOpacity)
            Image(.stepSubMenu)
                .resizable()
                .scaledToFit()
                .frame(width: screenHeight*0.464)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .overlay(
                    ZStack {
                        Image(sideFrameView())
                            .resizable()
                            .scaledToFit()
                            .frame(height: screenHeight*0.6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, screenHeight*0.025)
                        VStack(spacing: screenHeight*0.0275) {
                            ForEach(0..<stepMenuArray.count, id: \.self) { item in
                                ZStack {
                                    if item == stepNumber {
                                        Image(stepMenuArray[item].iconName)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: screenHeight*0.05)
                                            .padding(.bottom, item == 0 ? screenHeight*0.005 : 0)
                                        Image(.bluePoint)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: screenHeight*0.02)
                                            .offset(y: item == 7 ? -screenHeight*0.024 : screenHeight*0.024)
                                    }
                                    if item > stepNumber {
                                        Image(stepMenuArray[item].iconOff)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: screenHeight*0.03)
                                            .padding(.vertical, screenHeight*0.01)
                                    }
                                    if item < stepNumber {
                                        Image(.markDone)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: screenHeight*0.03)
                                            .padding(.vertical, screenHeight*0.01)
                                            .padding(.bottom, item == 0 ? screenHeight*0.005 : 0)
                                    }
                                    if item == stepNumber {
                                       
                                    }
                                }
                                .onTapGesture {
                                    stepNumber = item
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        showHideSideMenu()
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, screenHeight*0.025)
                       
                    }
                        .offset(y: screenHeight*0.01)
                )
                .offset(y: stepMenuOffset)
            Image(.topBarFrame)
                .resizable()
                .frame(width: screenWidth, height: screenHeight*0.1983)
//                .shadow(color: .gray, radius: screenHeight*0.01)
                .overlay(
                    VStack(spacing: screenHeight*0.00) {
                        Spacer()
                        HStack(spacing: screenHeight*0.02) {
                            Image(.appLogo)
                                .resizable()
                                .scaledToFit()
                                .frame(height: screenHeight*0.04)
                            Spacer()
                            Image(.limitsFrame)
                                .resizable()
                                .scaledToFit()
                                .frame(height: screenHeight*0.055)
                                .overlay(
                                    Text("\(limits)")
                                        .font(Font.custom("Figtree-Black", size: screenHeight*0.025))
                                        .foregroundStyle(Color.white)
                                        .multilineTextAlignment(.center)
                                        .offset(x: -screenHeight*0.039, y: -screenHeight*0.002)
                                        .shadow(color: .gray, radius: 3, y: 2)
                                )
                            Image(.menuButton)
                                .resizable()
                                .scaledToFit()
                                .frame(height: screenHeight*0.025)
                        }
                        .frame(maxWidth: screenWidth*0.9)
                        HStack(alignment: .bottom) {
                            Image(.arrowUp)
                                .resizable()
                                .scaledToFit()
                                .frame(height: screenHeight*0.03)
                                .scaleEffect(y: arrowScale)
                                .scaleEffect(y: arrowSide)
                                .onTapGesture {
                                    showHideSideMenu()
                                }
                            ZStack {
                                Image(.iconStroke)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: screenHeight*0.06)
                                    .shadow(color: Color.onboardingColor1 ,radius: 4, y: 4)
                                Image(stepMenuArray[stepNumber].iconName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: screenHeight*0.05)
                            }
                            .padding(.leading, screenHeight*0.02)
                            VStack(alignment: .leading) {
                                Text("Step \(stepMenuArray[stepNumber].stepNumber)")
                                    .font(Font.custom("Figtree-Regular", size: screenHeight*0.02))
                                    .foregroundStyle(Color.onboardingColor2)
                                    .multilineTextAlignment(.center)
                                Text((stepMenuArray[stepNumber].title))
                                    .font(Font.custom("Figtree-Medium", size: screenHeight*0.025))
                                    .foregroundStyle(Color.black)
                                    .multilineTextAlignment(.center)
                            }
                            Spacer()
                        }
                        .frame(maxWidth: screenWidth*0.85)
                    }
                        .padding(.bottom, screenHeight*0.01)
                )
                .frame(maxHeight: .infinity, alignment: .top)
        }
        .ignoresSafeArea()
        
        .onAppear {
            stepMenuOffset = -screenHeight*0.65
        }
        
        .onChange(of: stepMenuPresented) { _ in
            changeBackOpacity()
        }
        
    }
    
    func sideFrameView() -> String {
        switch stepNumber {
        case 0:
            return "sideStepa_1"
        case 1:
            return "sideStepa_2"
        case 2:
            return "sideStepa_3"
        case 3:
            return "sideStepa_4"
        case 4:
            return "sideStepa_5"
        case 5:
            return "sideStepa_6"
        case 6:
            return "sideStepa_7"
        case 7:
            return "sideStepa_8"
        default:
            return "sideStepa_1"
        }
    }
    
    func changeBackOpacity() {
        withAnimation(Animation.easeOut(duration: 0.3)) {
            if stepMenuPresented {
                shadowOpacity = 0.2
            } else {
                shadowOpacity = 0
            }
        }
    }
    
    func showHideSideMenu() {
        if stepMenuPresented {
            withAnimation(Animation.easeInOut(duration: 0.3)) {
                stepMenuOffset = -screenHeight*0.65
            }
            withAnimation(Animation.easeInOut(duration: 0.2)) {
                arrowScale = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                arrowSide = -1
                stepMenuPresented = false
                withAnimation(Animation.easeInOut(duration: 0.2)) {
                    arrowScale = 1
                }
            }
        } else {
            withAnimation(Animation.easeInOut(duration: 0.3)) {
                stepMenuOffset = 0
            }
            withAnimation(Animation.easeInOut(duration: 0.2)) {
                arrowScale = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                arrowSide = 1
                stepMenuPresented = true
                withAnimation(Animation.easeInOut(duration: 0.2)) {
                    arrowScale = 1
                }
            }
        }
    }
    
}

#Preview {
    let testFormData = SurveyFormData()
//    testFormData.name = "Алексей"
//    testFormData.surname = "Петров"
    
    TopBar(formData: testFormData, stepMenuPresented: .constant(false), stepNumber: .constant(0))
}
