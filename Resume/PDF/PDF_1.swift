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
        static let sectionTitleFont = UIFont(name: "Figtree-Bold", size: 70) ?? UIFont.systemFont(ofSize: 18, weight: .medium)
        static let contentFont = UIFont(name: "Figtree-Regular", size: 50) ?? UIFont.systemFont(ofSize: 12)
        static let smallFont = UIFont(name: "Figtree-Regular", size: 48) ?? UIFont.systemFont(ofSize: 10)
        static let infoFont = UIFont(name: "Figtree-Medium", size: 40) ?? UIFont.systemFont(ofSize: 10)
        static let summaryFont = UIFont(name: "Figtree-Regular", size: 36) ?? UIFont.systemFont(ofSize: 10)
    }
    
    // MARK: - Color Configuration
    /// Настройки цветов
    private struct ColorConfig {
        static let nameColor = UIColor.blue
        static let surnameColor = UIColor.blue
        static let positionColor = UIColor.onboardingColor2
        static let sectionTitleColor = UIColor.black
        static let contentColor = UIColor.black
        static let contactColor = UIColor.white
        static let periodColor = UIColor.pdFpediod
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
            
            drawAboutMeFrame(formData: formData, in: cgContext)
            
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
    
    private func drawAboutMeFrame(formData: SurveyFormData, in context: CGContext) {
        
        let aboutMeFrameName = "pdf_1_aboutMeFrame"
        
        let aboutMeFrameRect = CGRect(x: 940, y: 460, width: 1418, height: 400)
        
        // Рисуем рамку
        if let aboutMeFrameImage = UIImage(named: aboutMeFrameName) {
            aboutMeFrameImage.draw(in: aboutMeFrameRect)
        }
        
        // Определяем базовые параметры для текста внутри рамки
        let padding: CGFloat = 40
        let titleSpacing: CGFloat = 20 // Отступ между заголовком и текстом
        var currentY = aboutMeFrameRect.minY + padding
        let textX = aboutMeFrameRect.minX + padding
        let textWidth = aboutMeFrameRect.width - (padding * 2)
        
        // Рисуем заголовок "About me"
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: FontConfig.sectionTitleFont,
            .foregroundColor: ColorConfig.sectionTitleColor
        ]
        let titleString = NSAttributedString(string: "About me".uppercased(), attributes: titleAttributes)
        titleString.draw(at: CGPoint(x: textX, y: currentY))
        currentY += titleString.size().height + titleSpacing
        print("📝 Заголовок 'About me' отрисован в позиции (\(textX), \(currentY - titleString.size().height - titleSpacing))")
        
        // Рисуем текст summary
        let summaryText = formData.summaryData.summaryText
        if !summaryText.trimmingCharacters(in: .whitespaces).isEmpty {
            
            // Настройки шрифта и цвета для summary
            let summaryAttributes: [NSAttributedString.Key: Any] = [
                .font: FontConfig.summaryFont,
                .foregroundColor: ColorConfig.contentColor
            ]
            
            // Создаем атрибутированную строку
            let summaryString = NSAttributedString(string: summaryText, attributes: summaryAttributes)
            
            // Определяем область для summary текста (учитываем заголовок)
            let summaryRect = CGRect(
                x: textX,
                y: currentY,
                width: textWidth,
                height: aboutMeFrameRect.maxY - currentY - padding
            )
            
            // Рисуем текст с переносом строк
            summaryString.draw(with: summaryRect, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
            
            print("📝 Summary текст отрисован в позиции (\(textX), \(currentY)): '\(summaryText)'")
        }
    }
    
    // MARK: - User Photo Drawing
    /**
     * Рисует фотографию пользователя в первом прямоугольнике
     * Фото центрируется в прямоугольнике с заданными отступами
     */
    private func drawUserPhoto(_ photo: UIImage?, in context: CGContext) {
        // Позиция первого прямоугольника (левый верхний)
        let rect1 = CGRect(x: 0, y: 0, width: rectangleWidthArray[0], height: rectangleHeightArray[0])
        
        // Новые размеры фото: 517x517
        let photoSize: CGFloat = 517
        let borderThickness: CGFloat = 11  // Толщина рамки с каждой стороны
        
        // Центрируем фото в первом прямоугольнике
        let photoX = rect1.midX - photoSize/2
        let photoY = rect1.midY - photoSize/2
        let photoRect = CGRect(x: photoX, y: photoY, width: photoSize, height: photoSize)
        
        // Синий прямоугольник-рамка: на 22px шире и выше (11px с каждой стороны)
        let borderRect = CGRect(x: photoX - borderThickness, 
                               y: photoY - borderThickness, 
                               width: photoSize + borderThickness * 2, 
                               height: photoSize + borderThickness * 2)
        
        if let userPhoto = photo {
            // 1. СНАЧАЛА рисуем синий прямоугольник-рамку ПОД фото
            context.setFillColor(UIColor.blue.cgColor)
            context.fill(borderRect)
            
            // СОХРАНЯЕМ графический контекст перед применением маски
            context.saveGState()
            
            // 2. Создаем прямоугольную маску для обрезки фото (без скруглений)
            let clipPath = UIBezierPath(rect: photoRect)
            clipPath.addClip()
            
            // 3. Вычисляем размеры для scaledToFill (фото заполняет всю область без сжатия)
            let imageSize = userPhoto.size
            let targetSize = CGSize(width: photoSize, height: photoSize)
            
            // Вычисляем коэффициент масштабирования для заполнения всей области
            let scaleX = targetSize.width / imageSize.width
            let scaleY = targetSize.height / imageSize.height
            let scale = max(scaleX, scaleY) // Используем больший масштаб для заполнения
            
            // Вычисляем итоговые размеры изображения
            let scaledWidth = imageSize.width * scale
            let scaledHeight = imageSize.height * scale
            
            // Центрируем изображение в области фото
            let imageX = photoX + (photoSize - scaledWidth) / 2
            let imageY = photoY + (photoSize - scaledHeight) / 2
            let imageRect = CGRect(x: imageX, y: imageY, width: scaledWidth, height: scaledHeight)
            
            // 4. Рисуем фото (будет обрезано по маске)
            userPhoto.draw(in: imageRect)
            
            // ВОССТАНАВЛИВАЕМ графический контекст после отрисовки фото
            context.restoreGState()
            
            print("📸 Фото пользователя отрисовано в позиции (\(photoX), \(photoY)) размером \(photoSize)x\(photoSize) с синей рамкой \(borderThickness)px")
        } else {
            // Если фото нет, рисуем placeholder с такой же синей рамкой
            
            // 1. Рисуем синий прямоугольник-рамку ПОД placeholder
            context.setFillColor(UIColor.blue.cgColor)
            context.fill(borderRect)
            
            // 2. Рисуем серый прямоугольник вместо фото
            context.setFillColor(UIColor.lightGray.cgColor)
            context.fill(photoRect)
            
            // 3. Добавляем текст "PHOTO"
            let placeholderText = "PHOTO"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: FontConfig.contentFont,
                .foregroundColor: UIColor.darkGray
            ]
            let attributedString = NSAttributedString(string: placeholderText, attributes: attributes)
            let textSize = attributedString.size()
            let textX = photoRect.midX - textSize.width / 2
            let textY = photoRect.midY - textSize.height / 2
            attributedString.draw(at: CGPoint(x: textX, y: textY))
            
            print("🖼️ Placeholder фото отрисован в позиции (\(photoX), \(photoY)) размером \(photoSize)x\(photoSize) с синей рамкой \(borderThickness)px")
        }
    }
    
    // MARK: - Personal Info Drawing
    /**
     * Рисует персональную информацию во втором прямоугольнике
     * Включает имя, фамилию и текущую должность
     */
    private func drawPersonalInfo(formData: SurveyFormData, in context: CGContext) {
        // Позиция второго прямоугольника (правый верхний)
        let rect2 = CGRect(x: rectangleCoordinates[1].0, y: rectangleCoordinates[1].1, width: rectangleWidth, height: rectangleHeight)
        
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
    
    private func drawEducationInfo(formData: SurveyFormData, in context: CGContext) {
        
        let rect = CGRect(x: rectangleCoordinates[3].0, y: rectangleCoordinates[3].1, width: rectangleWidth, height: rectangleHeight)
        
        // Начальная позиция для текста с отступами
        var currentY = rect.minY + LayoutConfig.nameTopMargin
        let textX = rect.minX + LayoutConfig.nameLeftMargin
    }
    
    // MARK: - Contact Info Drawing
    /**
     * Рисует контактную информацию в третьем прямоугольнике
     * Включает email, телефон, веб-сайт и адрес
     */
    private func drawContactInfo(formData: SurveyFormData, in context: CGContext) {
        // Позиция третьего прямоугольника (левый средний)
        let rect3 = CGRect(x: rectangleCoordinates[4].0, y: rectangleCoordinates[4].1, width: rectangleWidth, height: rectangleHeight)
        
        var currentY = rect3.minY + LayoutConfig.sectionTopMargin + 80
        let textX = rect3.minX + LayoutConfig.sectionLeftMargin + 100
        
        // Заголовок секции
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: FontConfig.sectionTitleFont,
            .foregroundColor: ColorConfig.sectionTitleColor
        ]
//
        // Контент - email, телефон и т.д.
        let contentX = textX + LayoutConfig.contentLeftIndent
        let contentAttributes: [NSAttributedString.Key: Any] = [
            .font: FontConfig.infoFont,
            .foregroundColor: ColorConfig.contactColor
        ]
        
        // Адрес
        if !formData.address.isEmpty {
            // Рисуем иконку адреса
            if let addressIcon = UIImage(named: "adressIcon") {
                let iconSize: CGFloat = 40
                let iconY = currentY + (FontConfig.contentFont.lineHeight - iconSize) / 2
                let iconRect = CGRect(x: contentX - iconSize - 20, y: iconY, width: iconSize, height: iconSize)
                addressIcon.draw(in: iconRect)
                print("📍 Иконка adressIcon отрисована в позиции (\(contentX - iconSize - 20), \(iconY))")
            }
            
            let addressString = NSAttributedString(string: "\(formData.address)", attributes: contentAttributes)
            addressString.draw(at: CGPoint(x: contentX, y: currentY))
            currentY += addressString.size().height + LayoutConfig.mediumSpacing + 30
            print("📍 Адрес '\(formData.address)' отрисован в позиции (\(contentX), \(currentY))")
        
        // Email
        if !formData.email.isEmpty {
            // Рисуем иконку email
            if let mailIcon = UIImage(named: "mailIcon") {
                let iconSize: CGFloat = 40
                let iconY = currentY + (FontConfig.contentFont.lineHeight - iconSize) / 2
                let iconRect = CGRect(x: contentX - iconSize - 20, y: iconY, width: iconSize, height: iconSize)
                mailIcon.draw(in: iconRect)
                print("📧 Иконка mailIcon отрисована в позиции (\(contentX - iconSize - 20), \(iconY))")
            }
            
            let emailString = NSAttributedString(string: "\(formData.email)", attributes: contentAttributes)
            emailString.draw(at: CGPoint(x: contentX, y: currentY))
            currentY += emailString.size().height + LayoutConfig.mediumSpacing + 30
            print("📧 Email '\(formData.email)' отрисован в позиции (\(contentX), \(currentY - emailString.size().height))")
        }
        
        // Телефон
        if !formData.phone.isEmpty {
            // Рисуем иконку телефона
            if let phoneIcon = UIImage(named: "phoneIcon") {
                let iconSize: CGFloat = 40
                let iconY = currentY + (FontConfig.contentFont.lineHeight - iconSize) / 2
                let iconRect = CGRect(x: contentX - iconSize - 20, y: iconY, width: iconSize, height: iconSize)
                phoneIcon.draw(in: iconRect)
                print("📱 Иконка phoneIcon отрисована в позиции (\(contentX - iconSize - 20), \(iconY))")
            }
            
            let phoneString = NSAttributedString(string: "\(formData.phone)", attributes: contentAttributes)
            phoneString.draw(at: CGPoint(x: contentX, y: currentY))
            currentY += phoneString.size().height + LayoutConfig.mediumSpacing + 30
            print("📱 Телефон '\(formData.phone)' отрисован в позиции (\(contentX), \(currentY - phoneString.size().height))")
        }
        
        // Веб-сайт
        if !formData.website.isEmpty {
            let websiteString = NSAttributedString(string: "\(formData.website)", attributes: contentAttributes)
            websiteString.draw(at: CGPoint(x: contentX, y: currentY))
            currentY += websiteString.size().height + LayoutConfig.mediumSpacing + 30
            print("🌐 Веб-сайт '\(formData.website)' отрисован в позиции (\(contentX), \(currentY - websiteString.size().height))")
        }
        
       
        }
    }
    
    // MARK: - Education Drawing
    /**
     * Рисует информацию об образовании в четвертом прямоугольнике
     * Каждое образование отображается отдельным блоком с кружками и соединительными линиями
     */
    private func drawEducation(formData: SurveyFormData, in context: CGContext) {
        // Позиция четвертого прямоугольника (правый средний)
        let rect4 = CGRect(x: rectangleCoordinates[3].0, y: rectangleCoordinates[3].1, width: rectangleWidthArray[3], height: rectangleHeightArray[3])
        
        // Начальная позиция для текста с отступами
        var currentY = rect4.minY + LayoutConfig.nameTopMargin
        let textX = rect4.minX + LayoutConfig.nameLeftMargin
        
        // Заголовок секции
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: FontConfig.sectionTitleFont,
            .foregroundColor: ColorConfig.sectionTitleColor
        ]
        let titleString = NSAttributedString(string: "Education".uppercased(), attributes: titleAttributes)
        titleString.draw(at: CGPoint(x: textX, y: currentY))
        currentY += titleString.size().height + LayoutConfig.largeSpacing + 50
        print("🎓 Заголовок 'Education' отрисован в позиции (\(textX), \(currentY - titleString.size().height))")
        
        // Контент - список образований
        let contentX = textX + LayoutConfig.contentLeftIndent + 150
        let schoolNameAttributes: [NSAttributedString.Key: Any] = [
            .font: FontConfig.contentFont,
            .foregroundColor: ColorConfig.contentColor
        ]
        let periodAttributes: [NSAttributedString.Key: Any] = [
            .font: FontConfig.smallFont,
            .foregroundColor: ColorConfig.periodColor
        ]
        
        // Настройки для кружков и линий
        let circleRadius: CGFloat = 30
        let circleX = contentX - 130  // Позиция кружков левее текста
        let lineWidth: CGFloat = 2
        let lineColor = UIColor.white
        let circleColor = UIColor.white
        
        // Массив для хранения Y-координат кружков (для соединительных линий)
        var circleYPositions: [CGFloat] = []
        
        // Проходим по всем образованиям
        for (index, education) in formData.educations.enumerated() {
            
            // 🔵 РИСУЕМ КРУЖОК
            let circleY = currentY + (FontConfig.smallFont.lineHeight / 2) - circleRadius
            let circleRect = CGRect(x: circleX - circleRadius, y: circleY, width: circleRadius * 2, height: circleRadius * 2)
            
            context.setFillColor(circleColor.cgColor)
            context.fillEllipse(in: circleRect)
            
            // Добавляем Y-координату в массив для линий
            circleYPositions.append(circleY + circleRadius) // Центр кружка
            
            print("⚪ Кружок #\(index + 1) отрисован в позиции (\(circleX), \(circleY))")
            
            // Период обучения
            let periodText = education.isCurrentlyStudying ?
                "\(extractYear(from: education.whenStart)) - Present" :
                "\(extractYear(from: education.whenStart)) - \(extractYear(from: education.whenFinished))"
            let periodString = NSAttributedString(string: periodText, attributes: periodAttributes)
            periodString.draw(at: CGPoint(x: contentX, y: currentY))
            currentY += periodString.size().height + LayoutConfig.smallSpacing
            print("📅 Период обучения '\(periodText)' отрисован в позиции (\(contentX), \(currentY - periodString.size().height))")
            
            // Название учебного заведения
            let schoolString = NSAttributedString(string: education.schoolName.uppercased(), attributes: schoolNameAttributes)
            schoolString.draw(at: CGPoint(x: contentX, y: currentY))
            currentY += schoolString.size().height + LayoutConfig.largeSpacing + 100
            print("🏫 Образование #\(index + 1): '\(education.schoolName)' отрисовано в позиции (\(contentX), \(currentY - schoolString.size().height))")
        }
        
        // 📏 РИСУЕМ СОЕДИНИТЕЛЬНЫЕ ЛИНИИ (если больше одного образования)
        if circleYPositions.count > 1 {
            context.setStrokeColor(lineColor.cgColor)
            context.setLineWidth(lineWidth)
            
            for i in 0..<(circleYPositions.count - 1) {
                let startY = circleYPositions[i]
                let endY = circleYPositions[i + 1]
                
                // Рисуем вертикальную линию между кружками
                context.move(to: CGPoint(x: circleX, y: startY))
                context.addLine(to: CGPoint(x: circleX, y: endY))
                context.strokePath()
                
                print("📏 Соединительная линия от (\(circleX), \(startY)) до (\(circleX), \(endY))")
            }
        }
    }
    
    // MARK: - Work Experience Drawing
    /**
     * Рисует опыт работы в пятом прямоугольнике
     * Каждая работа отображается отдельным блоком
     */
    private func drawWorkExperience(formData: SurveyFormData, in context: CGContext) {
        // Позиция пятого прямоугольника (левый нижний)
        let rect5 =  CGRect(x: rectangleCoordinates[5].0, y: rectangleCoordinates[5].1, width: rectangleWidth, height: rectangleHeight)
        
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
        let rect6 =  CGRect(x: rectangleCoordinates[2].0, y: rectangleCoordinates[2].1, width: rectangleWidth, height: rectangleHeight)
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
    
    private func extractYear(from dateString: String) -> String {
        // Ищем 4 цифры подряд (год)
        let regex = try? NSRegularExpression(pattern: "\\d{4}")
        let range = NSRange(location: 0, length: dateString.utf16.count)
        
        if let match = regex?.firstMatch(in: dateString, range: range) {
            let yearRange = Range(match.range, in: dateString)!
            return String(dateString[yearRange])
        }
        
        return dateString  // Если год не найден, возвращаем оригинал
    }
}
