//
//  SubView_3.swift
//  Resume
//
//  Created by Алкександр Степанов on 25.08.2025.
//

import SwiftUI

struct SubView_3: View {
    @State private var listRotate: CGFloat = 0
    @State private var listOffset: CGFloat = 0
    @State private var star1Offset: CGFloat = 0
    @State private var star2Offset: CGFloat = 0
    @State private var star1Scale: CGFloat = 1
    @State private var star2Scale: CGFloat = 1
    @State private var star1Rotate: CGFloat = 0
    @State private var star2Rotate: CGFloat = 0
    @Binding var viewNumber: Int
    var body: some View {
        ZStack {
            Image(.sub3List)
                .resizable()
                .scaledToFit()
                .frame(height: screenHeight*0.4)
                .rotationEffect(Angle(degrees: listRotate))
            Image(.sub3Star)
                .resizable()
                .scaledToFit()
                .frame(height: screenHeight*0.06)
                .scaleEffect(x: star1Scale, y: star1Scale)
                .rotationEffect(Angle(degrees: 10))
                .offset(x: -screenHeight*0.04, y: -screenHeight*0.13)
                .offset(x: star1Offset)
            Image(.sub3Star)
                .resizable()
                .scaledToFit()
                .frame(height: screenHeight*0.1)
                .scaleEffect(x: star2Scale, y: star2Scale)
                .rotationEffect(Angle(degrees: -10))
                .offset(x: -screenHeight*0.12, y: -screenHeight*0.15)
                .offset(x: star1Offset)
                
        }
        .rotationEffect(Angle(degrees: listRotate))
        .offset(y: listOffset)
        
        .onAppear {
            listOffset = screenHeight*0.35
        }
        
        .onChange(of: viewNumber) { _ in
            if viewNumber == 2 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showList()
                }
            } else {
                hideList()
            }
        }
        
    }
    
    func showList() {
        withAnimation(Animation.easeInOut(duration: 0.5)) {
            listOffset = 0
            listRotate = 3
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(Animation.easeInOut(duration: 1)) {
                star1Scale = 1.1
                star2Scale = 1.1
            }
        }
    }
    
    func hideList() {
        withAnimation(Animation.easeInOut(duration: 0.5)) {
            listOffset = screenHeight*0.35
            listRotate = 0
        }
    }
    
}

#Preview {
    SubView_3(viewNumber: .constant(2))
}
