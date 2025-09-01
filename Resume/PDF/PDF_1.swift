//
//  PDF_1.swift
//  Resume
//
//  Created by Алкександр Степанов on 02.09.2025.
//

import SwiftUI
import PDFKit
import UIKit

// MARK: - PDF Generator Class
class PDF_1_Generator: ObservableObject {
    
    // MARK: - Page Configuration
    /// Размер страницы A4 в точках (595x842)
    private let pageSize = CGSize(width: 2480, height: 3508)
    
    /// Размеры прямоугольников фона (каждый прямоугольник занимает половину ширины)
    private let rectangleWidth: CGFloat = 297.5  // pageSize.width / 2 = 595 / 2
    private let rectangleHeight: CGFloat = 280.67  // pageSize.height / 3 = 842 / 3
    private let rectangleWidthArray: [CGFloat] = [817, 1663, 817, 1663, 817, 1663,]
    private let rectangleHeightArray: [CGFloat] = [817, 817, 1534, 1534, 1159, 1159]
    private let rectangleCoordinates: [(CGFloat, CGFloat)] = [(0,0), (817,0), (0,817), (817,817), (0,2351), (817,2351)]
    
    // MARK: - Font Configuration
    /// Настройки шрифтов для разных элементов
    private struct FontConfig {
        static let nameFont = UIFont(name: "Figtree-ExtraBold", size: 150) ?? UIFont.boldSystemFont(ofSize: 28)
        static let surnameFont = UIFont(name: "Figtree-ExtraBold", size: 150) ?? UIFont.boldSystemFont(ofSize: 28)
        static let positionFont = UIFont(name: "Figtree-Medium", size: 80) ?? UIFont.systemFont(ofSize: 16)
        static let sectionTitleFont = UIFont(name: "Figtree-Medium", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .medium)
        static let contentFont = UIFont(name: "Figtree-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
        static let smallFont = UIFont(name: "Figtree-Regular", size: 10) ?? UIFont.systemFont(ofSize: 10)
    }
    
    // MARK: - Color Configuration
    /// Настройки цветов
    private struct ColorConfig {
        static let nameColor = UIColor.blue
        static let surnameColor = UIColor.blue
        static let positionColor = UIColor.onboardingColor2 // Светло-голубой
        static let sectionTitleColor = UIColor.white
        static let contentColor = UIColor.black
        static let contactColor = UIColor.white
    }
    
    // MARK: - Layout Configuration
    /// Настройки отступов и позиционирования
    private struct LayoutConfig {
        // Отступы внутри прямоугольников
        static let rectanglePadding: CGFloat = 20
        
        // Отступы между элементами
        static let smallSpacing: CGFloat = 5
        static let mediumSpacing: CGFloat = 10
        static let largeSpacing: CGFloat = 15
        
        // Размеры фото
        static let photoSize: CGFloat = 120
        static let photoCornerRadius: CGFloat = 10
        
        // Отступы от краев прямоугольников
        static let photoTopMargin: CGFloat = 30
        static let photoLeftMargin: CGFloat = 30
        
        // Позиции текста во втором прямоугольнике
        static let nameTopMargin: CGFloat = 150
        static let nameLeftMargin: CGFloat = 200
        
        // Отступы для секций в нижних прямоугольниках
        static let sectionTopMargin: CGFloat = 25
        static let sectionLeftMargin: CGFloat = 25
        static let contentLeftIndent: CGFloat = 10  // Отступ для содержимого от заголовка
    }
    
    // MARK: - Main PDF Generation Method
    /**
     * Основной метод генерации PDF документа
     * @param formData - все данные пользователя из формы
     * @param userPhoto - фотография пользователя (опционально)
     * @return Data? - готовый PDF в виде данных
     */
    func generatePDF(formData: SurveyFormData, userPhoto: UIImage? = nil) -> Data? {
        
        // Создаем метаданные PDF документа
        let pdfMetaData = [
            kCGPDFContextCreator: "Resume App",
            kCGPDFContextAuthor: "\(formData.name) \(formData.surname)",
            kCGPDFContextTitle: "Resume - \(formData.name) \(formData.surname)"
        ]
        
        // Настраиваем формат PDF
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        // Создаем PDF renderer с размером A4
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize), format: format)
        
        // Генерируем PDF данные
        return renderer.pdfData { context in
            // Начинаем новую страницу
            context.beginPage()
            
            let cgContext = context.cgContext
            
            // 1. Рисуем фон из 6 прямоугольников
            drawBackgroundRectangles(in: cgContext)
            
            drawBackgroundStar(in: cgContext)
            
            drawAboutMeFrame(in: cgContext)
            
            // 2. Добавляем фото пользователя (1-й прямоугольник)
            drawUserPhoto(userPhoto, in: cgContext)
            
            // 3. Добавляем имя, фамилию и должность (2-й прямоугольник)
            drawPersonalInfo(formData: formData, in: cgContext)
            
            // 4. Добавляем контактную информацию (3-й прямоугольник)
            drawContactInfo(formData: formData, in: cgContext)
            
            // 5. Добавляем образование (4-й прямоугольник)
            drawEducation(formData: formData, in: cgContext)
            
            // 6. Добавляем опыт работы (5-й прямоугольник)
            drawWorkExperience(formData: formData, in: cgContext)
            
            // 7. Дополнительная информация (6-й прямоугольник)
            drawAdditionalInfo(formData: formData, in: cgContext)
        }
    }
    
    // MARK: - Background Drawing
    /**
     * Рисует фон из 6 прямоугольников в макете 2x3
     * Прямоугольники располагаются без промежутков между собой
     */
    private func drawBackgroundRectangles(in context: CGContext) {
        // Массив имен изображений прямоугольников фона
        let rectangleNames = [
            "pdf_1_rect_1", "pdf_1_rect_2",  // Верхний ряд
            "pdf_1_rect_3", "pdf_1_rect_4",  // Средний ряд
            "pdf_1_rect_5", "pdf_1_rect_6"   // Нижний ряд
        ]
        
        // Проходим по всем прямоугольникам
        for (index, imageName) in rectangleNames.enumerated() {
            // Вычисляем позицию прямоугольника
           
            
            // Создаем прямоугольник точно по размерам
            let rect = CGRect(x: rectangleCoordinates[index].0, y: rectangleCoordinates[index].1, width: rectangleWidthArray[index], height: rectangleHeightArray[index])
            
            // Загружаем изображение из Assets
            if let image = UIImage(named: imageName) {
                // Рисуем изображение точно в границах прямоугольника
                image.draw(in: rect)
//                print("✅ Отрисован прямоугольник \(imageName) в позиции (\(x), \(y)) размером \(rectangleWidth)x\(rectangleHeight)")
            } else {
                // Если изображение не найдено, рисуем цветной прямоугольник
                context.setFillColor(UIColor.systemBlue.cgColor)
                context.fill(rect)
                print("⚠️ Изображение \(imageName) не найдено, используется синий прямоугольник")
            }
        }
    }
    
    private func drawBackgroundStar(in context: CGContext) {
        let starName = "pdf_1_star"
        
        let starRect = CGRect(x: 1500, y: 700, width: 1500, height: 1500)
        
        if let starImage = UIImage(named: starName) {
            context.saveGState()
            let centerX = starRect.midX  // 1500 + 1500/2 = 2250
            let centerY = starRect.midY  // 700 + 1500/2 = 1450
            
            context.translateBy(x: centerX, y: centerY)
            context.rotate(by: CGFloat.pi / 5)
            let drawRect = CGRect(x: -starRect.width/2, y: -starRect.height/2,
                                  width: starRect.width, height: starRect.height)
            context.draw(starImage.cgImage!, in: drawRect)
            context.restoreGState()
        }
        
    }
    
    private func drawAboutMeFrame(in context: CGContext) {
        
        let aboutMeFrameName = "pdf_1_aboutMeFrame"
        
        let aboutMeFrameRect = CGRect(x: 940, y: 460, width: 1418, height: 400)
        
        if let aboutMeFrameImage = UIImage(named: aboutMeFrameName) {
            aboutMeFrameImage.draw(in: aboutMeFrameRect)
        }
    }
    
    // MARK: - User Photo Drawing
    /**
     * Рисует фотографию пользователя в первом прямоугольнике
     * Фото центрируется в прямоугольнике с заданными отступами
     */
    private func drawUserPhoto(_ photo: UIImage?, in context: CGContext) {
        // Позиция первого прямоугольника (левый верхний)
        let rect1 = CGRect(x: 0, y: 0, width: rectangleWidth, height: rectangleHeight)
        
        // Вычисляем позицию фото с отступами
        let photoX = rect1.minX + LayoutConfig.photoLeftMargin
        let photoY = rect1.minY + LayoutConfig.photoTopMargin
        let photoRect = CGRect(x: photoX, y: photoY, 
                              width: LayoutConfig.photoSize, 
                              height: LayoutConfig.photoSize)
        
        if let userPhoto = photo {
            // Создаем круглую маску для фото
            let path = UIBezierPath(roundedRect: photoRect, cornerRadius: LayoutConfig.photoCornerRadius)
            path.addClip()
            
            // Рисуем фото
            userPhoto.draw(in: photoRect)
            print("📸 Фото пользователя отрисовано в позиции (\(photoX), \(photoY)) размером \(LayoutConfig.photoSize)x\(LayoutConfig.photoSize)")
        } else {
            // Если фото нет, рисуем placeholder
            context.setFillColor(UIColor.lightGray.cgColor)
            context.fillEllipse(in: photoRect)
            
            // Добавляем текст "Фото"
            let placeholderText = "Фото"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: FontConfig.contentFont,
                .foregroundColor: UIColor.darkGray
            ]
            let attributedString = NSAttributedString(string: placeholderText, attributes: attributes)
            let textSize = attributedString.size()
            let textX = photoRect.midX - textSize.width / 2
            let textY = photoRect.midY - textSize.height / 2
            attributedString.draw(at: CGPoint(x: textX, y: textY))
            
            print("🖼️ Placeholder фото отрисован в позиции (\(photoX), \(photoY))")
        }
    }
    
    // MARK: - Personal Info Drawing
    /**
     * Рисует персональную информацию во втором прямоугольнике
     * Включает имя, фамилию и текущую должность
     */
    private func drawPersonalInfo(formData: SurveyFormData, in context: CGContext) {
        // Позиция второго прямоугольника (правый верхний)
        let rect2 = CGRect(x: rectangleCoordinates[1].0, y: 0, width: rectangleWidth, height: rectangleHeight)
        
        // Начальная позиция для текста с отступами
        var currentY = rect2.minY + LayoutConfig.nameTopMargin
        let textX = rect2.minX + LayoutConfig.nameLeftMargin
        
        // Рисуем имя
        let nameAttributes: [NSAttributedString.Key: Any] = [
            .font: FontConfig.nameFont,
            .foregroundColor: ColorConfig.nameColor
        ]
        let nameString = NSAttributedString(string: formData.name.uppercased() + " " + formData.surname.uppercased(), attributes: nameAttributes)
        nameString.draw(at: CGPoint(x: textX, y: currentY))
        currentY += nameString.size().height + LayoutConfig.smallSpacing
        print("👤 Имя '\(formData.name)' отрисовано в позиции (\(textX), \(currentY - nameString.size().height)) шрифтом \(FontConfig.nameFont.fontName) размером \(FontConfig.nameFont.pointSize)")
        
        // Рисуем фамилию
//        let surnameAttributes: [NSAttributedString.Key: Any] = [
//            .font: FontConfig.surnameFont,
//            .foregroundColor: ColorConfig.surnameColor
//        ]
//        let surnameString = NSAttributedString(string: formData.surname.uppercased(), attributes: surnameAttributes)
//        surnameString.draw(at: CGPoint(x: textX, y: currentY))
//        currentY += surnameString.size().height + LayoutConfig.mediumSpacing
//        print("👤 Фамилия '\(formData.surname)' отрисована в позиции (\(textX), \(currentY - surnameString.size().height)) шрифтом \(FontConfig.surnameFont.fontName) размером \(FontConfig.surnameFont.pointSize)")
        
        // Рисуем должность (берем из первой работы, если есть)
        if !formData.works.isEmpty {
            let position = formData.works[0].position
            let positionAttributes: [NSAttributedString.Key: Any] = [
                .font: FontConfig.positionFont,
                .foregroundColor: ColorConfig.positionColor
            ]
            let positionString = NSAttributedString(string: position, attributes: positionAttributes)
            positionString.draw(at: CGPoint(x: textX, y: currentY))
            print("💼 Должность '\(position)' отрисована в позиции (\(textX), \(currentY)) шрифтом \(FontConfig.positionFont.fontName) размером \(FontConfig.positionFont.pointSize)")
        }
    }
    
    // MARK: - Contact Info Drawing
    /**
     * Рисует контактную информацию в третьем прямоугольнике
     * Включает email, телефон, веб-сайт и адрес
     */
    private func drawContactInfo(formData: SurveyFormData, in context: CGContext) {
        // Позиция третьего прямоугольника (левый средний)
        let rect3 = CGRect(x: 0, y: rectangleHeight, width: rectangleWidth, height: rectangleHeight)
        
        // Начальная позиция для контента
        var currentY = rect3.minY + LayoutConfig.sectionTopMargin
        let textX = rect3.minX + LayoutConfig.sectionLeftMargin
        
        // Заголовок секции
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: FontConfig.sectionTitleFont,
            .foregroundColor: ColorConfig.sectionTitleColor
        ]
        let titleString = NSAttributedString(string: "Contacts", attributes: titleAttributes)
        titleString.draw(at: CGPoint(x: textX, y: currentY))
        currentY += titleString.size().height + LayoutConfig.largeSpacing
        print("📞 Заголовок 'Contacts' отрисован в позиции (\(textX), \(currentY - titleString.size().height)) шрифтом \(FontConfig.sectionTitleFont.fontName) размером \(FontConfig.sectionTitleFont.pointSize)")
        
        // Контент - email, телефон и т.д.
        let contentX = textX + LayoutConfig.contentLeftIndent
        let contentAttributes: [NSAttributedString.Key: Any] = [
            .font: FontConfig.contentFont,
            .foregroundColor: ColorConfig.contactColor
        ]
        
        // Email
        if !formData.email.isEmpty {
            let emailString = NSAttributedString(string: "📧 \(formData.email)", attributes: contentAttributes)
            emailString.draw(at: CGPoint(x: contentX, y: currentY))
            currentY += emailString.size().height + LayoutConfig.mediumSpacing
            print("📧 Email '\(formData.email)' отрисован в позиции (\(contentX), \(currentY - emailString.size().height))")
        }
        
        // Телефон
        if !formData.phone.isEmpty {
            let phoneString = NSAttributedString(string: "📱 \(formData.phone)", attributes: contentAttributes)
            phoneString.draw(at: CGPoint(x: contentX, y: currentY))
            currentY += phoneString.size().height + LayoutConfig.mediumSpacing
            print("📱 Телефон '\(formData.phone)' отрисован в позиции (\(contentX), \(currentY - phoneString.size().height))")
        }
        
        // Веб-сайт
        if !formData.website.isEmpty {
            let websiteString = NSAttributedString(string: "🌐 \(formData.website)", attributes: contentAttributes)
            websiteString.draw(at: CGPoint(x: contentX, y: currentY))
            currentY += websiteString.size().height + LayoutConfig.mediumSpacing
            print("🌐 Веб-сайт '\(formData.website)' отрисован в позиции (\(contentX), \(currentY - websiteString.size().height))")
        }
        
        // Адрес
        if !formData.address.isEmpty {
            let addressString = NSAttributedString(string: "📍 \(formData.address)", attributes: contentAttributes)
            addressString.draw(at: CGPoint(x: contentX, y: currentY))
            print("📍 Адрес '\(formData.address)' отрисован в позиции (\(contentX), \(currentY))")
        }
    }
    
    // MARK: - Education Drawing
    /**
     * Рисует информацию об образовании в четвертом прямоугольнике
     * Каждое образование отображается отдельным блоком
     */
    private func drawEducation(formData: SurveyFormData, in context: CGContext) {
        // Позиция четвертого прямоугольника (правый средний)
        let rect4 = CGRect(x: rectangleWidth, y: rectangleHeight, width: rectangleWidth, height: rectangleHeight)
        
        // Начальная позиция для контента
        var currentY = rect4.minY + LayoutConfig.sectionTopMargin
        let textX = rect4.minX + LayoutConfig.sectionLeftMargin
        
        // Заголовок секции
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: FontConfig.sectionTitleFont,
            .foregroundColor: ColorConfig.sectionTitleColor
        ]
        let titleString = NSAttributedString(string: "Education", attributes: titleAttributes)
        titleString.draw(at: CGPoint(x: textX, y: currentY))
        currentY += titleString.size().height + LayoutConfig.largeSpacing
        print("🎓 Заголовок 'Education' отрисован в позиции (\(textX), \(currentY - titleString.size().height))")
        
        // Контент - список образований
        let contentX = textX + LayoutConfig.contentLeftIndent
        let schoolNameAttributes: [NSAttributedString.Key: Any] = [
            .font: FontConfig.contentFont,
            .foregroundColor: ColorConfig.contentColor
        ]
        let periodAttributes: [NSAttributedString.Key: Any] = [
            .font: FontConfig.smallFont,
            .foregroundColor: ColorConfig.contentColor
        ]
        
        // Проходим по всем образованиям
        for (index, education) in formData.educations.enumerated() {
            // Название учебного заведения
            let schoolString = NSAttributedString(string: education.schoolName, attributes: schoolNameAttributes)
            schoolString.draw(at: CGPoint(x: contentX, y: currentY))
            currentY += schoolString.size().height + LayoutConfig.smallSpacing
            print("🏫 Образование #\(index + 1): '\(education.schoolName)' отрисовано в позиции (\(contentX), \(currentY - schoolString.size().height))")
            
            // Период обучения
            let periodText = education.isCurrentlyStudying ? 
                "\(education.whenStart) - Present" : 
                "\(education.whenStart) - \(education.whenFinished)"
            let periodString = NSAttributedString(string: periodText, attributes: periodAttributes)
            periodString.draw(at: CGPoint(x: contentX, y: currentY))
            currentY += periodString.size().height + LayoutConfig.largeSpacing
            print("📅 Период обучения '\(periodText)' отрисован в позиции (\(contentX), \(currentY - periodString.size().height))")
        }
    }
    
    // MARK: - Work Experience Drawing
    /**
     * Рисует опыт работы в пятом прямоугольнике
     * Каждая работа отображается отдельным блоком
     */
    private func drawWorkExperience(formData: SurveyFormData, in context: CGContext) {
        // Позиция пятого прямоугольника (левый нижний)
        let rect5 = CGRect(x: 0, y: rectangleHeight * 2, width: rectangleWidth, height: rectangleHeight)
        
        // Начальная позиция для контента
        var currentY = rect5.minY + LayoutConfig.sectionTopMargin
        let textX = rect5.minX + LayoutConfig.sectionLeftMargin
        
        // Заголовок секции
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: FontConfig.sectionTitleFont,
            .foregroundColor: ColorConfig.sectionTitleColor
        ]
        let titleString = NSAttributedString(string: "Work Experience", attributes: titleAttributes)
        titleString.draw(at: CGPoint(x: textX, y: currentY))
        currentY += titleString.size().height + LayoutConfig.largeSpacing
        print("💼 Заголовок 'Work Experience' отрисован в позиции (\(textX), \(currentY - titleString.size().height))")
        
        // Контент - список работ
        let contentX = textX + LayoutConfig.contentLeftIndent
        let companyNameAttributes: [NSAttributedString.Key: Any] = [
            .font: FontConfig.contentFont,
            .foregroundColor: ColorConfig.contentColor
        ]
        let positionAttributes: [NSAttributedString.Key: Any] = [
            .font: FontConfig.smallFont,
            .foregroundColor: ColorConfig.contentColor
        ]
        
        // Проходим по всем работам
        for (index, work) in formData.works.enumerated() {
            // Название компании
            let companyString = NSAttributedString(string: work.companyName, attributes: companyNameAttributes)
            companyString.draw(at: CGPoint(x: contentX, y: currentY))
            currentY += companyString.size().height + LayoutConfig.smallSpacing
            print("🏢 Работа #\(index + 1): '\(work.companyName)' отрисована в позиции (\(contentX), \(currentY - companyString.size().height))")
            
            // Должность
            let positionString = NSAttributedString(string: work.position, attributes: positionAttributes)
            positionString.draw(at: CGPoint(x: contentX, y: currentY))
            currentY += positionString.size().height + LayoutConfig.smallSpacing
            print("💼 Должность '\(work.position)' отрисована в позиции (\(contentX), \(currentY - positionString.size().height))")
            
            // Период работы
            let periodText = work.isCurentlyWork ? 
                "\(work.whenStart) - Present" : 
                "\(work.whenStart) - \(work.whenFinished)"
            let periodString = NSAttributedString(string: periodText, attributes: positionAttributes)
            periodString.draw(at: CGPoint(x: contentX, y: currentY))
            currentY += periodString.size().height + LayoutConfig.largeSpacing
            print("📅 Период работы '\(periodText)' отрисован в позиции (\(contentX), \(currentY - periodString.size().height))")
        }
    }
    
    // MARK: - Additional Info Drawing
    /**
     * Рисует дополнительную информацию в шестом прямоугольнике
     * Может включать навыки, достижения, хобби и т.д.
     */
    private func drawAdditionalInfo(formData: SurveyFormData, in context: CGContext) {
        // Позиция шестого прямоугольника (правый нижний)
        let rect6 = CGRect(x: rectangleWidth, y: rectangleHeight * 2, width: rectangleWidth, height: rectangleHeight)
        
        // Начальная позиция для контента
        var currentY = rect6.minY + LayoutConfig.sectionTopMargin
        let textX = rect6.minX + LayoutConfig.sectionLeftMargin
        
        // Заголовок секции
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: FontConfig.sectionTitleFont,
            .foregroundColor: ColorConfig.sectionTitleColor
        ]
        let titleString = NSAttributedString(string: "Additional Info", attributes: titleAttributes)
        titleString.draw(at: CGPoint(x: textX, y: currentY))
        currentY += titleString.size().height + LayoutConfig.largeSpacing
        print("ℹ️ Заголовок 'Additional Info' отрисован в позиции (\(textX), \(currentY - titleString.size().height))")
        
        // Контент - дополнительная информация
        let contentX = textX + LayoutConfig.contentLeftIndent
        let contentAttributes: [NSAttributedString.Key: Any] = [
            .font: FontConfig.contentFont,
            .foregroundColor: ColorConfig.contentColor
        ]
        
        // Пример дополнительной информации
        let additionalInfo = [
            "• Languages: English, Russian",
            "• Skills: iOS Development",
            "• Interests: Technology, Design"
        ]
        
        for info in additionalInfo {
            let infoString = NSAttributedString(string: info, attributes: contentAttributes)
            infoString.draw(at: CGPoint(x: contentX, y: currentY))
            currentY += infoString.size().height + LayoutConfig.mediumSpacing
            print("📝 Дополнительная информация '\(info)' отрисована в позиции (\(contentX), \(currentY - infoString.size().height))")
        }
    }
} 
