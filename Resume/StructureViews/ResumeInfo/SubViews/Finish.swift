//
//  Finish.swift
//  Resume
//
//  Created by Алкександр Степанов on 01.09.2025.
//

import SwiftUI

struct Finish: View {
    @ObservedObject var formData: SurveyFormData
    @State private var stepNumber = 1
    @State private var stepsTextArray = Arrays.stepsTextArray
    @StateObject private var keyboardObserver = KeyboardObserver()
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: screenHeight*0.02) {
                Image(.personFinishFrame)
                    .resizable()
                    .scaledToFit()
                    .overlay(
                        HStack {
                            Image(.noPhoto)
                                .resizable()
                                .scaledToFit()
                                .frame(height: screenHeight*0.18)
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(formData.name)
                                        .font(Font.custom("Figtree-SemiBold", size: screenHeight*0.03))
                                        .foregroundStyle(Color.white)
                                    Text(formData.surname)
                                        .font(Font.custom("Figtree-SemiBold", size: screenHeight*0.03))
                                        .foregroundStyle(Color.white)
                                }
                                Text(formData.works[0].position)
                                    .font(Font.custom("Figtree-Regular", size: screenHeight*0.016))
                                    .foregroundStyle(Color.onboardingColor2)
                                Rectangle()
                                    .fill(Color.onboardingColor2)
                                    .frame(height: screenHeight*0.001)
                                HStack {
                                    Image(.at)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: screenHeight*0.02)
                                    Text(formData.email)
                                        .font(Font.custom("Figtree-Regular", size: screenHeight*0.016))
                                        .foregroundStyle(Color.white)
                                }
                                HStack {
                                    Image(.phone)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: screenHeight*0.02)
                                    Text(formData.phone)
                                        .font(Font.custom("Figtree-Regular", size: screenHeight*0.016))
                                        .foregroundStyle(Color.white)
                                }
                            }
                            Spacer()
                        }
                            .padding()
                    )
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
//            .frame(maxWidth: screenWidth*0.9)
            .padding(.top, screenHeight*0.2)
            .padding(.bottom, keyboardObserver.isKeyboardVisible ? screenHeight*0.4 : screenHeight*0.15)
            .animation(.easeInOut(duration: 0.3), value: keyboardObserver.isKeyboardVisible)
        }
    }
    
    // 👤 Personal Information Card
    @ViewBuilder
    private func PersonalInfoCard() -> some View {
        VStack(alignment: .leading, spacing: screenHeight*0.01) {
            Text("Personal Information")
                .font(Font.custom("Figtree-Medium", size: screenHeight*0.025))
                .foregroundStyle(Color.black)
            
            ZStack {
                Image(.textFieldFrame)
                    .resizable()
                    .scaledToFit()
                    .frame(width: screenWidth*0.9)
                
                VStack(alignment: .leading, spacing: screenHeight*0.008) {
                    // Имя и фамилия
                    HStack {
                        Text("Name:")
                            .font(Font.custom("Figtree-Medium", size: screenHeight*0.02))
                            .foregroundStyle(Color.gray)
                        Text("\(formData.name) \(formData.surname)")
                            .font(Font.custom("Figtree-Regular", size: screenHeight*0.02))
                            .foregroundStyle(Color.black)
                    }
                    
                    // Email
                    if !formData.email.isEmpty {
                        HStack {
                            Text("Email:")
                                .font(Font.custom("Figtree-Medium", size: screenHeight*0.02))
                                .foregroundStyle(Color.gray)
                            Text(formData.email)
                                .font(Font.custom("Figtree-Regular", size: screenHeight*0.02))
                                .foregroundStyle(Color.black)
                        }
                    }
                    
                    // Phone
                    if !formData.phone.isEmpty {
                        HStack {
                            Text("Phone:")
                                .font(Font.custom("Figtree-Medium", size: screenHeight*0.02))
                                .foregroundStyle(Color.gray)
                            Text(formData.phone)
                                .font(Font.custom("Figtree-Regular", size: screenHeight*0.02))
                                .foregroundStyle(Color.black)
                        }
                    }
                    
                    // Website
                    if !formData.website.isEmpty {
                        HStack {
                            Text("Website:")
                                .font(Font.custom("Figtree-Medium", size: screenHeight*0.02))
                                .foregroundStyle(Color.gray)
                            Text(formData.website)
                                .font(Font.custom("Figtree-Regular", size: screenHeight*0.02))
                                .foregroundStyle(Color.blue)
                        }
                    }
                    
                    // Address
                    if !formData.address.isEmpty {
                        HStack {
                            Text("Address:")
                                .font(Font.custom("Figtree-Medium", size: screenHeight*0.02))
                                .foregroundStyle(Color.gray)
                            Text(formData.address)
                                .font(Font.custom("Figtree-Regular", size: screenHeight*0.02))
                                .foregroundStyle(Color.black)
                        }
                    }
                }
                .padding(.horizontal, screenWidth*0.1)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    // 🎓 Education Card
    @ViewBuilder
    private func EducationCard() -> some View {
        VStack(alignment: .leading, spacing: screenHeight*0.01) {
            Text("Education")
                .font(Font.custom("Figtree-Medium", size: screenHeight*0.025))
                .foregroundStyle(Color.black)
            
            ForEach(Array(formData.educations.enumerated()), id: \.element.id) { index, education in
                ZStack {
                    Image(.educationFrame)
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenWidth*0.9)
                    
                    VStack(alignment: .leading, spacing: screenHeight*0.008) {
                        // School Name
                        Text(education.schoolName)
                            .font(Font.custom("Figtree-Medium", size: screenHeight*0.022))
                            .foregroundStyle(Color.black)
                        
                        // Period
                        HStack {
                            Text("Period:")
                                .font(Font.custom("Figtree-Regular", size: screenHeight*0.018))
                                .foregroundStyle(Color.gray)
                            
                            if education.isCurrentlyStudying {
                                Text("\(education.whenStart) - Present")
                                    .font(Font.custom("Figtree-Regular", size: screenHeight*0.018))
                                    .foregroundStyle(Color.black)
                            } else {
                                Text("\(education.whenStart) - \(education.whenFinished)")
                                    .font(Font.custom("Figtree-Regular", size: screenHeight*0.018))
                                    .foregroundStyle(Color.black)
                            }
                        }
                    }
                    .padding(.horizontal, screenWidth*0.1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
    
    // 💼 Work Experience Card
    @ViewBuilder
    private func WorkExperienceCard() -> some View {
        VStack(alignment: .leading, spacing: screenHeight*0.01) {
            Text("Work Experience")
                .font(Font.custom("Figtree-Medium", size: screenHeight*0.025))
                .foregroundStyle(Color.black)
            
            ForEach(Array(formData.works.enumerated()), id: \.element.id) { index, work in
                ZStack {
                    Image(.educationFrame)
                        .resizable()
                        .scaledToFit()
                        .frame(width: screenWidth*0.9)
                    
                    VStack(alignment: .leading, spacing: screenHeight*0.008) {
                        // Company Name
                        Text(work.companyName)
                            .font(Font.custom("Figtree-Medium", size: screenHeight*0.022))
                            .foregroundStyle(Color.black)
                        
                        // Position
                        Text(work.position)
                            .font(Font.custom("Figtree-Regular", size: screenHeight*0.02))
                            .foregroundStyle(Color.blue)
                        
                        // Location
                        if !work.companiLocation.isEmpty {
                            Text(work.companiLocation)
                                .font(Font.custom("Figtree-Regular", size: screenHeight*0.018))
                                .foregroundStyle(Color.gray)
                        }
                        
                        // Period
                        HStack {
                            Text("Period:")
                                .font(Font.custom("Figtree-Regular", size: screenHeight*0.018))
                                .foregroundStyle(Color.gray)
                            
                            if work.isCurentlyWork {
                                Text("\(work.whenStart) - Present")
                                    .font(Font.custom("Figtree-Regular", size: screenHeight*0.018))
                                    .foregroundStyle(Color.black)
                            } else {
                                Text("\(work.whenStart) - \(work.whenFinished)")
                                    .font(Font.custom("Figtree-Regular", size: screenHeight*0.018))
                                    .foregroundStyle(Color.black)
                            }
                        }
                    }
                    .padding(.horizontal, screenWidth*0.1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

#Preview {
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
    
    // Добавляем тестовую работу
    let work = WorkData()
    work.companyName = "Apple Inc."
    work.position = "Software Engineer"
    work.companiLocation = "Cupertino, CA"
    work.whenStart = "06/2022"
    work.isCurentlyWork = true
    testFormData.works.append(work)
    
    return Finish(formData: testFormData)
}

