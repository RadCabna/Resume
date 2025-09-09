//
//  ClearSummary.swift
//  Resume
//
//  Created by Алкександр Степанов on 09.09.2025.
//

import SwiftUI
import UIKit

struct ClearSummary: View {
    @State private var stepNumber = 4
    @State private var stepsTextArray = Arrays.stepsTextArray
    @ObservedObject var formData: SurveyFormData
    @StateObject private var keyboardObserver = KeyboardObserver()
    @State private var isTextEditorFocused = false
    @State private var isTextFieldFocused = false
    
    // Локальная переменная для ввода summary
    @State private var summaryText = ""

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                Text(stepsTextArray[stepNumber][0])
                    .font(Font.custom("Figtree-Bold", size: screenHeight*0.03))
                    .foregroundStyle(Color.black)
                    .lineSpacing(0)
                Text(stepsTextArray[stepNumber][1])
                    .font(Font.custom("Figtree-Medium", size: screenHeight*0.017))
                    .foregroundStyle(Color.onboardingColor2)
                    .padding(.bottom, screenHeight*0.04)
                Image(.summaryFrame)
                    .resizable()
                    .scaledToFit()
                    .frame(height: screenHeight*0.28)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .overlay(
                        ZStack {
                            // Область для ввода текста
                            ZStack(alignment: .topLeading) {
                                // Placeholder текст
                                if summaryText.isEmpty {
                                    Text("Write a brief summary about yourself...")
                                        .font(Font.custom("Figtree-Medium", size: screenHeight*0.016))
                                        .foregroundColor(.gray.opacity(0.6))
                                        .padding(.top, 8)
                                        .padding(.leading, 4)
                                        .allowsHitTesting(false)
                                }
                                
                                ClearTextEditor(text: $summaryText, isFocused: $isTextFieldFocused)
                            }
                                .font(Font.custom("Figtree-Medium", size: screenHeight*0.016))
                            .frame(maxWidth: screenHeight*0.35)
                            .frame(height: screenHeight*0.16)
                            .frame(maxHeight: .infinity, alignment: .top)
                            .padding(.top, screenHeight*0.03)
                            .padding(.horizontal, screenHeight*0.01)
                            
                            // Кнопки внизу
                            HStack {
                                Button(action: {
                                    // Действие для AI генерации
                                }) {
                                    Image(.writeAIButton)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: screenHeight*0.032)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    isTextFieldFocused = true
                                }) {
                                    Image(.openKeyBoardButton)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: screenHeight*0.035)
                                }
                            }
                            .frame(maxWidth: screenHeight*0.36)
                            .frame(maxHeight: .infinity, alignment: .bottom)
                            .padding(.bottom, screenHeight*0.03)
                        }
                    )
//                    .shadow(radius: 10)
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .frame(maxWidth: screenWidth*0.9)
            .padding(.top, screenHeight*0.25)
            .padding(.bottom, keyboardObserver.isKeyboardVisible ? screenHeight*0.4 : screenHeight*0.15)
            .animation(.easeInOut(duration: 0.3), value: keyboardObserver.isKeyboardVisible)
        }
        .onTapGesture {
            // Скрываем клавиатуру при нажатии вне области ввода
            isTextFieldFocused = false
        }
        .onAppear {
            // Загружаем данные из formData в локальную переменную
            loadSummary()
        }
        .onDisappear {
            // Сохраняем данные из локальной переменной в formData
            saveSummary()
        }
        
    }
    
    func saveSummary() {
        formData.summaryData.summaryText = summaryText
    }
    
    func loadSummary() {
        summaryText = formData.summaryData.summaryText
    }
    
}

struct ClearTextEditor: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFocused: Bool
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.font = UIFont(name: "Figtree-Regular", size: screenHeight*0.017) ?? UIFont.systemFont(ofSize: 14)
        textView.textColor = .black
        textView.delegate = context.coordinator
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        if textView.text != text {
            textView.text = text
        }
        if isFocused && !textView.isFirstResponder {
            textView.becomeFirstResponder()
        } else if !isFocused && textView.isFirstResponder {
            textView.resignFirstResponder()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        let parent: ClearTextEditor
        
        init(_ parent: ClearTextEditor) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.text = textView.text
            }
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.isFocused = true
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.isFocused = false
            }
        }
    }
}

#Preview {
    let testFormData = SurveyFormData()
    return ClearSummary(formData: testFormData)
}
