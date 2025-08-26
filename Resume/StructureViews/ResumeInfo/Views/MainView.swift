//
//  MainView.swift
//  Resume
//
//  Created by Алкександр Степанов on 25.08.2025.
//

import SwiftUI

struct MainView: View {
    @AppStorage("stepNumber") var stepNumber = 0
    var body: some View {
        ZStack {
            Color(.bg)
            showList()
                .blur(radius: 0)
            Image(.buttonNext)
                .resizable()
                .scaledToFit()
                .frame(height: screenHeight*0.065)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, screenHeight*0.04)
                .onTapGesture {
                    if stepNumber < 7 {
                        stepNumber += 1
                    }
                }
            
            TopBar(stepNumber: $stepNumber)
        }
        .ignoresSafeArea()
    }
    
    func showList() -> AnyView {
        switch stepNumber {
        case 0:
            return AnyView(Intro())
        case 1:
            return AnyView(Contacts())
        default:
            return AnyView(Intro())
        }
    }
    
}

#Preview {
    MainView()
}
