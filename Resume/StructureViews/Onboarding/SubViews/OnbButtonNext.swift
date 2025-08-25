//
//  OnbButtonNext.swift
//  Resume
//
//  Created by Алкександр Степанов on 24.08.2025.
//

import SwiftUI

struct OnbButtonNext: View {
    @State private var sectorAngle: Double = 120
    let baseColor: Color = .blue
    let sectorColor: Color = Color(.onboardingColor1)
    var size: CGFloat = 1
    @Binding var viewNumber: Int
    var body: some View {
        ZStack {
            Image(.onboardingProgressFrame)
                .resizable()
                .scaledToFit()
                .frame(height: screenHeight*0.2*size)
            PieSlice(
                startAngle: .degrees(-90),
                endAngle: .degrees(-90 + sectorAngle)
            )
            .fill(sectorColor)
            .frame(width: screenHeight*0.2*size)
            .mask(
                Circle()
                    .overlay(
                        Circle()
                            .frame(width: screenHeight*0.184*size)
                            .blendMode(.destinationOut)
                    )
            )
            Image(.onboardingButtomNext)
                .resizable()
                .scaledToFit()
                .frame(height: screenHeight*0.185*size)
        }
        
        .onChange(of: viewNumber) { _ in
            progressAnimation()
        }
        
    }
    
    func progressAnimation() {
        withAnimation(Animation.easeInOut(duration: 1)) {
            switch viewNumber {
            case 0:
                sectorAngle = 120
            case 1:
                sectorAngle = 240
            case 2:
                sectorAngle = 360
            default:
                break
            }
        }
    }
    
}

#Preview {
    OnbButtonNext(viewNumber: .constant(0))
}

struct PieSlice: Shape {
    let startAngle: Angle
    var endAngle: Angle
    
    var animatableData: Double {
        get { endAngle.degrees }
        set { endAngle = .degrees(newValue) }
    }
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        var path = Path()
        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        path.closeSubpath()
        
        return path
    }
}
