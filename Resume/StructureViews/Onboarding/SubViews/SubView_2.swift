//
//  SubView_2.swift
//  Resume
//
//  Created by Алкександр Степанов on 25.08.2025.
//

import SwiftUI

struct SubView_2: View {
    @State private var textXOffset_1:CGFloat = 0
    @State private var textXOffset_2:CGFloat = 0
    @State private var textXOffset_3:CGFloat = 0
    @State private var textXOffset_4:CGFloat = 0
    @State private var offsetYArray: [CGFloat] = [0,0,0,0]
    @State private var rotateArray: [CGFloat] = [0,0,0,0]
    @Binding var viewNumber: Int
    var body: some View {
        ZStack {
            Image(.sub2Text1)
                .resizable()
                .scaledToFit()
                .frame(height: screenHeight*0.04)
                .offset(y: offsetYArray[0])
                .rotationEffect(Angle(degrees: rotateArray[0]))
                .offset(x: textXOffset_1)
            Image(.sub2Text2)
                .resizable()
                .scaledToFit()
                .frame(height: screenHeight*0.04)
                .offset(y: offsetYArray[1])
                .rotationEffect(Angle(degrees: rotateArray[1]))
                .offset(x: textXOffset_2)
            Image(.sub2Text3)
                .resizable()
                .scaledToFit()
                .frame(height: screenHeight*0.04)
                .offset(y: offsetYArray[2])
                .rotationEffect(Angle(degrees: rotateArray[2]))
                .offset(x: textXOffset_3)
            Image(.sub2Text4)
                .resizable()
                .scaledToFit()
                .frame(height: screenHeight*0.04)
                .offset(y: offsetYArray[3])
                .rotationEffect(Angle(degrees: rotateArray[3]))
                .offset(x: textXOffset_4)
        }
        .offset(y: screenHeight*0.15)
        
        .onChange(of: viewNumber) { _ in
            if viewNumber == 1 {
                animateText()
            } else {
                hideText()
            }
        }
        
        .onAppear {
            offsetYArray[1] = screenHeight*0.05
            offsetYArray[2] = screenHeight*0.1
            offsetYArray[3] = screenHeight*0.145
            textXOffset_2 = screenHeight*0.02
            textXOffset_3 = -screenHeight*0.04
            textXOffset_4 = screenHeight*0.03
//            animateText()
        }
    }
    
    func animateText() {
        var delay = 0.5
        var rotate: CGFloat = -2
        for i in 0..<offsetYArray.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(Animation.easeInOut(duration: 0.4)) {
                    offsetYArray[i] -= screenHeight*0.225
                    rotateArray[i] += rotate
                }
                rotate *= -1
            }
            delay += 0.04
            
        }
    }
    
    func hideText() {
        var delay = 0.0
        for i in 0..<offsetYArray.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(Animation.easeInOut(duration: 0.4)) {
                    offsetYArray[offsetYArray.count-i-1] = 0
                    rotateArray[i] = 0
                }
            }
            delay += 0.04
        }
    }
    
}

#Preview {
    SubView_2(viewNumber: .constant(1))
}
