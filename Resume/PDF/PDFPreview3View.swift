//
//  PDFPreview3View.swift
//  Resume
//
//  Created by Алкександр Степанов on 15.09.2025.
//

import SwiftUI
import PDFKit

struct PDFPreview3View: View {
    let formData: SurveyFormData
    let userPhoto: UIImage?
    
    @State private var pdfDocument: PDFDocument?
    @State private var isLoading = true
    
    init(formData: SurveyFormData, userPhoto: UIImage? = nil) {
        self.formData = formData
        self.userPhoto = userPhoto
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Generating PDF...")
                        .scaleEffect(1.2)
                } else if let pdfDocument = pdfDocument {
                    PDFKitView(document: pdfDocument)
                        .edgesIgnoringSafeArea(.all)
                } else {
                    Text("Failed to generate PDF")
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("PDF Template 3")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                generatePDF()
            }
        }
    }
    
    private func generatePDF() {
        DispatchQueue.global(qos: .userInitiated).async {
            let generator = PDF_3_Generator()
            
            if let pdfData = generator.generatePDF(formData: formData, userPhoto: userPhoto) {
                let document = PDFDocument(data: pdfData)
                
                DispatchQueue.main.async {
                    self.pdfDocument = document
                    self.isLoading = false
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - Preview
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
    education.educationalDetails = "Bachelor of Science in Computer Science with magna cum laude honors."
    testFormData.educations.append(education)
    
    // Добавляем тестовые места работы
    let work1 = WorkData()
    work1.companyName = "Apple Inc."
    work1.position = "Senior Software Engineer"
    work1.companiLocation = "Cupertino, CA"
    work1.whenStart = "06/2022"
    work1.isCurentlyWork = true
    work1.responsibilities = "Lead development of iOS applications using Swift and SwiftUI. Collaborated with cross-functional teams to deliver high-quality mobile solutions."
    testFormData.works.append(work1)
    
    let work2 = WorkData()
    work2.companyName = "Google LLC"
    work2.position = "Full Stack Developer"
    work2.companiLocation = "Mountain View, CA"
    work2.whenStart = "01/2020"
    work2.whenFinished = "05/2022"
    work2.isCurentlyWork = false
    work2.responsibilities = "Developed and maintained web applications using React, Node.js, and Python. Implemented RESTful APIs and worked with various databases."
    testFormData.works.append(work2)
    
    let work3 = WorkData()
    work3.companyName = "Microsoft Corporation"
    work3.position = "Software Development Engineer"
    work3.companiLocation = "Seattle, WA"
    work3.whenStart = "08/2017"
    work3.whenFinished = "12/2019"
    work3.isCurentlyWork = false
    work3.responsibilities = "Built cloud-based solutions using Azure services and .NET framework. Participated in agile development processes."
    testFormData.works.append(work3)
    
    let summaryData = SummaryData()
    summaryData.summaryText = "Result-driven Project Manager with over 3 years of experience in leading cross-functional teams, delivering digital products, and ensuring on-time, on-budget execution. Skilled in Agile and Scrum methodologies."
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
    
    return PDFPreview3View(formData: testFormData)
} 