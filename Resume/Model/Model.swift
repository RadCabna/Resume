//
//  File.swift
//  Resume
//
//  Created by Алкександр Степанов on 24.08.2025.
//

import Foundation

struct StepMenu {
    var stepNumber: Int
    var title: String
    var iconName: String
    var iconOff: String
}

class Arrays {
    static var onboardingBG = ["onboardingBG1", "onboardingBG2", "onboardingBG3"]
    static var onboardingBottomFrame = ["onboardingBottomFrame1", "onboardingBottomFrame2", "onboardingBottomFrame3"]
    static var onboardingDataArray = [
        ["Build Your Resume \nSmarter", "Craft a professional resume \nwith AI in minutes", "Answer simple questions and let AI help \nyou write impactful job descriptions, \nsummaries, and cover letters.", "Resume", "Write with AI"],
        ["Smart Suggestions, Tailored for You", "Polish every detail", "Get instant, personalized feedback to make your resume stand out. Edit with ease using AI-powered tools.", "Played a key role in team achievements", "Thrived in fast-changing environments", "Increased efficiency and output", "Improved operational effectiveness", ],
        ["Start Free. Upgrade Anytime", "3 free AI edits to get you started", "Try before you subscribe. Upgrade to unlock premium templates, unlimited AI writing, and DOCX export"]
        ]
    
    static var stepMenuArray: [StepMenu] = [
        StepMenu(stepNumber: 1, title: "Intro", iconName: "infoIcon", iconOff: "sideIconOff_1"),
        StepMenu(stepNumber: 2, title: "Contacts", iconName: "contactIcon", iconOff: "sideIconOff_2"),
        StepMenu(stepNumber: 3, title: "Education", iconName: "educationIcon", iconOff: "sideIconOff_3"),
        StepMenu(stepNumber: 4, title: "Work", iconName: "workIcon", iconOff: "sideIconOff_4"),
        StepMenu(stepNumber: 5, title: "Summary", iconName: "summaryIcon", iconOff: "sideIconOff_5"),
        StepMenu(stepNumber: 6, title: "Additional", iconName: "additionalIcon", iconOff: "sideIconOff_6"),
        StepMenu(stepNumber: 7, title: "Suggestions", iconName: "suggestionsIcon", iconOff: "sideIconOff_7"),
        StepMenu(stepNumber: 8, title: "Finish", iconName: "finishIcon", iconOff: "sideIconOff_8")
        ]
    
    static var stepsTextArray = [stepsTextScreen_1, stepsTextScreen_2]
    
    static var stepsTextScreen_1 = [
        "Hello!",
        "Ready to get started?",
        "Name",
        "Surname"
    ]
    
    static var stepsTextScreen_2 = [
        "How do you prefer your employer to contact you?",
        "Most employers use email for first contact, so it's important to provide an up-to-date email address.",
        "Email Address",
        "Phone Number",
        "Personal Website",
        "Adress"
    ]
}
