//
//  Point.swift
//  Resume
//
//  Created by Алкександр Степанов on 14.09.2025.
//

import SwiftUI

struct Point: View {
    @ObservedObject var point: AdditionalPoint
    var onTap: () -> Void = {}
    @State private var isPressed = false
    
    var body: some View {
        HStack {
            Image(point.active ? .pointOn : .pointOff)
                .resizable()
                .scaledToFit()
                .frame(height: screenHeight*0.03)
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isPressed)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: point.active)
            
            Text(point.name)
                .font(Font.custom("Figtree-Regular", size: screenHeight*0.018))
                .foregroundStyle(point.active ? Color.blue : Color.black)
                .animation(.easeInOut(duration: 0.2), value: point.active)
            
            Spacer()
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onTapGesture {
            // Тактильная отдача
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            // Визуальный feedback
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            
            // Вызываем callback
            onTap()
            
            // Сбрасываем состояние нажатия
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }
    }
}

#Preview {
    Point(point: AdditionalPoint(name: "Test Skill"))
}
