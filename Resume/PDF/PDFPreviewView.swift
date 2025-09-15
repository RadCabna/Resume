//
//  PDFPreviewView.swift
//  Resume
//
//  Created by Алкександр Степанов on 02.09.2025.
//

import SwiftUI
import PDFKit

// MARK: - PDF Preview View
/**
 * SwiftUI View для отображения сгенерированного PDF документа
 * Позволяет просматривать, масштабировать и взаимодействовать с PDF
 */
struct PDFPreviewView: View {
    
    // MARK: - Properties
    /// Данные формы для генерации PDF
    @ObservedObject var formData: SurveyFormData
    
    /// Фотография пользователя (опционально)
    var userPhoto: UIImage?
    
    /// Состояние генерации PDF
    @State private var pdfData: Data?
    @State private var isGenerating = false
    @State private var generationError: String?
    
    /// PDF Generator
    @StateObject private var pdfGenerator = PDF_1_Generator()
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack {
                if isGenerating {
                    // Индикатор загрузки
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Generating PDF...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                } else if let error = generationError {
                    // Отображение ошибки
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        
                        Text("Error generating PDF")
                            .font(.headline)
                        
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Try Again") {
                            generatePDF()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                } else if let data = pdfData {
                    // Отображение PDF
                    PDFKitView(data: data)
                        .navigationTitle("Resume Preview")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItemGroup(placement: .navigationBarTrailing) {
                                // Кнопка обновления PDF
                                Button(action: generatePDF) {
                                    Image(systemName: "arrow.clockwise")
                                }
                            }
                        }
                    
                } else {
                    // Начальное состояние
                    VStack(spacing: 20) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        
                        Text("PDF Preview")
                            .font(.headline)
                        
                        Text("Tap the button below to generate your resume PDF")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Generate PDF") {
                            generatePDF()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .onAppear {
            // Автоматически генерируем PDF при появлении view
            generatePDF()
        }
        .onChange(of: userPhoto) { _ in
            // Перегенерируем PDF при изменении фото
            generatePDF()
        }
    }
    
    // MARK: - PDF Generation
    /**
     * Генерирует PDF документ с использованием PDF_1_Generator
     */
    private func generatePDF() {
        isGenerating = true
        generationError = nil
        
        // Генерируем PDF в фоновом потоке
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let data = pdfGenerator.generatePDF(formData: formData, userPhoto: userPhoto)
                
                DispatchQueue.main.async {
                    if let pdfData = data {
                        self.pdfData = pdfData
                        print("✅ PDF успешно сгенерирован, размер: \(pdfData.count) байт")
                    } else {
                        self.generationError = "Failed to generate PDF data"
                        print("❌ Ошибка генерации PDF")
                    }
                    self.isGenerating = false
                }
            }
            
        }
    }
    
    // MARK: - PDF Sharing
    /**
     * Открывает системное меню для экспорта/отправки PDF
     */
    private func sharePDF() {
        guard let data = pdfData else { return }
        
        let activityController = UIActivityViewController(
            activityItems: [data],
            applicationActivities: nil
        )
        
        // Для iPad - задаем источник popover
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first,
           let rootViewController = window.rootViewController {
            
            if let popover = activityController.popoverPresentationController {
                popover.sourceView = window
                popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            rootViewController.present(activityController, animated: true)
        }
    }
}

// MARK: - PDFKit Integration
// Используем универсальный PDFKitView из PDFKitView.swift

// MARK: - Preview
/**
 * Preview для тестирования PDFPreviewView
 */
#Preview {
    // Создаем тестовые данные
    let testFormData = SurveyFormData()
    testFormData.name = "John"
    testFormData.surname = "Doe"
    testFormData.email = "john.doe@example.com"
    testFormData.phone = "+1 (555) 123-4567"
    testFormData.website = "www.johndoe.com"
    testFormData.address = "123 Main St, New York, NY"
    
    // Добавляем тестовое образование
    let education = EducationData()
    education.schoolName = "Harvard University"
    education.whenStart = "09/2018"
    education.whenFinished = "05/2022"
    education.isCurrentlyStudying = false
    testFormData.educations.append(education)
    
    // Добавляем вторую тестовую школу
    let education2 = EducationData()
    education2.schoolName = "MIT"
    education2.whenStart = "09/2022"
    education2.isCurrentlyStudying = true
    testFormData.educations.append(education2)
    
    // Добавляем тестовую работу
    let work = WorkData()
    work.companyName = "Apple Inc."
    work.position = "Software Engineer"
    work.companiLocation = "Cupertino, CA"
    work.whenStart = "06/2022"
    work.isCurentlyWork = true
    testFormData.works.append(work)
    
    // Добавляем вторую тестовую работу
    let work2 = WorkData()
    work2.companyName = "Google"
    work2.position = "Junior Developer"
    work2.companiLocation = "Mountain View, CA"
    work2.whenStart = "01/2021"
    work2.whenFinished = "05/2022"
    work2.isCurentlyWork = false
    testFormData.works.append(work2)
    
    let summaryData = SummaryData()
    summaryData.summaryText = "Result-driven Project Manager with over 3 years of experience in leading cross-functional teams, delivering digital products, and ensuring on-time, on-budget execution. Skilled in Agile and Scrum methodologies, stakeholder communication, and risk management. Passionate about optimizing workflows and achieving business goals through clear planning and proactive leadership."
    testFormData.summaryData = summaryData
    
    // Добавляем тестовые навыки
    testFormData.additionalSkills.hardSkills[0].active = true  // Data Analysis
    testFormData.additionalSkills.hardSkills[1].active = true  // Project Management  
    testFormData.additionalSkills.hardSkills[5].active = true  // Software Development
    testFormData.additionalSkills.hardSkills[9].active = true  // Python / Java / JavaScript
    
    testFormData.additionalSkills.softSkills[0].active = true  // Problem-Solving
    testFormData.additionalSkills.softSkills[2].active = true  // Communication
    testFormData.additionalSkills.softSkills[3].active = true  // Leadership
    testFormData.additionalSkills.softSkills[5].active = true  // Time Management
    
    return PDFPreviewView(formData: testFormData)
} 
 
