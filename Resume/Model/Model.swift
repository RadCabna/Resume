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
    
    static var stepsTextArray = [stepsTextScreen_1, stepsTextScreen_2, stepsTextScreen_3, stepsTextScreen_4, stepsTextScreen_5, stepsTextScreen_6, stepsTextScreen_7, stepsTextScreen_8]
    
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
    
    static var stepsTextScreen_3 = [
        "School Name",
        "When did you start?",
        "e.g. 09/2017 or Sep 2017",
        "When did you finish?",
        "Still in school? Just fill in the start date and toggle \n“Present.”",
        "💡 If the date matters, be sure to include both the month\nand year.\nKeep the same date format throughout your resume for \nconsistency.\nIncluding the month is optional."
    ]
    
    static var stepsTextScreen_4 = [
        "Company or organization name",
        "Company Location",
        "Your Position",
        "I worked at this position from:",
        "e.g. 09/2017 or Sep 2017",
        "To:",
        "Still working? Just enter the start date and click\n“Present”.",
        "💡 If the date matters, be sure to include both the month\nand year.\nKeep the same date format throughout your resume for \nconsistency.\nIncluding the month is optional."
]
    static var stepsTextScreen_5 = [
        "Professional Summary", "Your summary sits near the top of your resume, typically just below your contact details. It should briefly highlight your career direction or goals. Think of it as a quick headline that grabs attention and shows how you align with the role you're applying for.", "Write with AI", "You have 3 AI generations remaining in your free trial.", "Provide a brief overview of the key aspects and significant highlights of your experience below:", "Suggested Highlights"
        ]
    static var stepsTextScreen_6 = [
     ""
    ]
    static var stepsTextScreen_7 = [
        ""
        ]
    static var stepsTextScreen_8 = [
        ""
        ]
}
