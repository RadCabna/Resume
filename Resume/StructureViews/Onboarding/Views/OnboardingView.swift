//
//  OnboardingView.swift
//  Resume
//
//  Created by Алкександр Степанов on 24.08.2025.
//

import SwiftUI

struct OnboardingView: View {
    @State private var viewNumber = 0
    @State private var bgNumber = 0
    @State private var onboardingBG = Arrays.onboardingBG
    @State private var onboardingBottomFrame = Arrays.onboardingBottomFrame
    @State private var onboardingDataArray = Arrays.onboardingDataArray
    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let width = geometry.size.width
            let isLandscape = width > height
            if !isLandscape {
                ZStack {
                    Image(onboardingBG[bgNumber])
                        .resizable()
                    //                        .scaledToFit()
                        .ignoresSafeArea()
                    VStack {
                        Text(onboardingDataArray[viewNumber][0])
                            .font(Font.custom("Figtree-Bold", size: height*0.05))
                            .foregroundStyle(Color.white)
                            .multilineTextAlignment(.center)
                            .shadow(color: .gray, radius: height*0.003)
                        Text(onboardingDataArray[viewNumber][1])
                            .font(Font.custom("Figtree-Regular", size: height*0.03))
                            .foregroundStyle(Color.white)
                            .multilineTextAlignment(.center)
                            .shadow(color: .gray, radius: height*0.003)
                    }
                    .offset(y: -height*0.33)
                    SubView_1(viewNumber: $viewNumber)
                    SubView_2(viewNumber: $viewNumber)
                    SubView_3(viewNumber: $viewNumber)
                        ZStack {
                            Image(onboardingBottomFrame[0])
                                .resizable()
                                .scaledToFit()
                                .offset(x: -width * CGFloat(viewNumber))
                            Image(onboardingBottomFrame[1])
                                .resizable()
                                .scaledToFit()
                                .offset(x: width - width * CGFloat(viewNumber))
                            Image(onboardingBottomFrame[2])
                                .resizable()
                                .scaledToFit()
                                .offset(x: width*2 - width * CGFloat(viewNumber))
                        }
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .ignoresSafeArea()
                    Text(onboardingDataArray[viewNumber][2])
                        .font(Font.custom("Figtree-Regular", size: height*0.025))
                        .foregroundStyle(Color.onboardingColor2)
                        .multilineTextAlignment(.center)
                        .offset(y: height*0.23)
                        OnbButtonNext(size: 0.6, viewNumber: $viewNumber)
                        .offset(y: height*0.4)
                            .onTapGesture {
                                nextView()
                            }
                }
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
        }
    }
    
    func nextView() {
        if viewNumber < 2 {
            withAnimation(.easeInOut(duration: 0.5)) {
                viewNumber += 1
                bgNumber += 1
            }
        } else {
            bgNumber = 0
            viewNumber = 0
        }
    }
    
}

#Preview {
    OnboardingView()
}
