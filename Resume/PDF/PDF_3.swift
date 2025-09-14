//
//  PDF_3.swift
//  Resume
//
//  Created by Алкександр Степанов on 15.09.2025.
//

import SwiftUI
import PDFKit
import UIKit

// MARK: - PDF_3 Generator Class
class PDF_3_Generator: ObservableObject {
    
    // MARK: - Page Configuration
    private let pageSize = CGSize(width: 2480, height: 3508)
    
    // MARK: - Font Configuration
    private struct FontConfig {
        static let titleFont = UIFont(name: "Figtree-Bold", size: 80) ?? UIFont.boldSystemFont(ofSize: 80)
        static let sectionTitleFont = UIFont(name: "Figtree-Bold", size: 64) ?? UIFont.boldSystemFont(ofSize: 64)
        static let nameFont = UIFont(name: "Figtree-ExtraBold", size: 120) ?? UIFont.boldSystemFont(ofSize: 120)
        static let contentFont = UIFont(name: "Figtree-Medium", size: 40) ?? UIFont.systemFont(ofSize: 40)
        static let smallFont = UIFont(name: "Figtree-Regular", size: 36) ?? UIFont.systemFont(ofSize: 36)
    }
    
    // MARK: - Color Configuration
    private struct ColorConfig {
        static let primaryColor = UIColor.black
        static let secondaryColor = UIColor.gray
        static let accentColor = UIColor(named: "PDFpediodColor") ?? UIColor.blue
    }
    
    // MARK: - Layout Configuration
    private struct LayoutConfig {
        static let margin: CGFloat = 100
        static let sectionSpacing: CGFloat = 80
        static let itemSpacing: CGFloat = 40
    }
    
    /**
     * Основной метод генерации PDF документа
     * @param formData - все данные пользователя из формы
     * @param userPhoto - фотография пользователя (опционально)
     * @return Data? - готовый PDF в виде данных
     */
    func generatePDF(formData: SurveyFormData, userPhoto: UIImage? = nil) -> Data? {
        // Создаем метаданные PDF документа
        let documentInfo = [
            kCGPDFContextTitle: "\(formData.name) \(formData.surname) - Resume",
            kCGPDFContextAuthor: "\(formData.name) \(formData.surname)",
            kCGPDFContextSubject: "Professional Resume",
            kCGPDFContextCreator: "Resume App"
        ]
        
        // Создаем PDF renderer
        let format = UIGraphicsPDFRendererFormat()
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize), format: format)
        
        let pdfData = renderer.pdfData { context in
            // Начинаем новую страницу
            context.beginPage()
            let cgContext = context.cgContext
            
            // Отрисовываем фото пользователя
            drawUserPhoto(userPhoto: userPhoto, in: cgContext)
            
            // Отрисовываем информационный блок
            drawInfoBlock(formData: formData, in: cgContext)
            
            // Отрисовываем блок Experience
            let experienceEndY = drawExperienceBlock(formData: formData, in: cgContext)
            
            // Отрисовываем блок Education сразу после Experience
            let educationEndY = drawEducationBlock(formData: formData, startY: experienceEndY + 60, in: cgContext)
            
            // Отрисовываем блок Skills сразу после Education
            drawSkillsBlock(formData: formData, startY: educationEndY + 60, in: cgContext)
            
            // Отрисовываем декоративные изображения поверх всего
            drawDecorativeImages(in: cgContext)
            
            print("🎯 PDF_3 сгенерирован успешно")
        }
        
        return pdfData
    }
    
    /**
     * Отрисовывает фото пользователя или placeholder
     */
    private func drawUserPhoto(userPhoto: UIImage?, in context: CGContext) {
        // Параметры размещения фото
        let photoWidth: CGFloat = 707
        let photoHeight: CGFloat = 1059
        let leftMargin: CGFloat = 310
        let topMargin: CGFloat = 291
        
        // Создаем прямоугольник для фото
        let photoRect = CGRect(
            x: leftMargin,
            y: topMargin,
            width: photoWidth,
            height: photoHeight
        )
        
        if let photo = userPhoto {
            // Отрисовываем фото пользователя
            drawScaledPhoto(photo: photo, in: photoRect, context: context)
            print("📸 PDF_3: Фото пользователя отрисовано в позиции (\(leftMargin), \(topMargin))")
        } else {
            // Отрисовываем placeholder
            drawPhotoPlaceholder(in: photoRect, context: context)
            print("🖼️ PDF_3: Placeholder 'No Photo' отрисован в позиции (\(leftMargin), \(topMargin))")
        }
        
        // Рисуем черный прямоугольник справа от фото
        drawBlackRectangle(nextTo: photoRect, context: context)
    }
    
    /**
     * Отрисовывает масштабированное фото пользователя
     */
    private func drawScaledPhoto(photo: UIImage, in rect: CGRect, context: CGContext) {
        // Сохраняем состояние контекста
        context.saveGState()
        
        // Создаем маску обрезки по прямоугольнику
        let clipPath = UIBezierPath(rect: rect)
        context.addPath(clipPath.cgPath)
        context.clip()
        
        // Вычисляем масштабирование для сохранения пропорций (scaledToFill)
        let imageSize = photo.size
        let scaleX = rect.width / imageSize.width
        let scaleY = rect.height / imageSize.height
        let scale = max(scaleX, scaleY) // Берем больший масштаб для заполнения
        
        // Вычисляем размеры масштабированного изображения
        let scaledWidth = imageSize.width * scale
        let scaledHeight = imageSize.height * scale
        
        // Центрируем изображение в прямоугольнике
        let drawX = rect.minX + (rect.width - scaledWidth) / 2
        let drawY = rect.minY + (rect.height - scaledHeight) / 2
        
        let drawRect = CGRect(x: drawX, y: drawY, width: scaledWidth, height: scaledHeight)
        
        // Отрисовываем изображение
        photo.draw(in: drawRect)
        
        // Восстанавливаем состояние контекста
        context.restoreGState()
        
        print("📸 Фото масштабировано и обрезано: исходный размер \(imageSize), итоговый \(drawRect)")
    }
    
    /**
     * Отрисовывает placeholder "No Photo"
     */
    private func drawPhotoPlaceholder(in rect: CGRect, context: CGContext) {
        // Заливаем серым цветом
        context.setFillColor(UIColor.lightGray.cgColor)
        context.fill(rect)
        
        // Добавляем текст "No Photo"
        let placeholderText = "No Photo"
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: FontConfig.titleFont,
            .foregroundColor: UIColor.darkGray
        ]
        
        let attributedString = NSAttributedString(string: placeholderText, attributes: textAttributes)
        let textSize = attributedString.size()
        
        // Центрируем текст в прямоугольнике
        let textX = rect.minX + (rect.width - textSize.width) / 2
        let textY = rect.minY + (rect.height - textSize.height) / 2
        let textPosition = CGPoint(x: textX, y: textY)
        
        attributedString.draw(at: textPosition)
        
        print("🖼️ Placeholder 'No Photo' отрисован в центре прямоугольника")
    }
    
    /**
     * Отрисовывает черный прямоугольник справа от фото
     */
    private func drawBlackRectangle(nextTo photoRect: CGRect, context: CGContext) {
        // Параметры черного прямоугольника
        let rectangleWidth: CGFloat = 22
        let rectangleHeight = photoRect.height // Высота как у фото
        
        // Позиция: вплотную справа от фото
        let rectangleX = photoRect.maxX // Правый край фото
        let rectangleY = photoRect.minY // Тот же Y что и у фото
        
        let blackRect = CGRect(
            x: rectangleX,
            y: rectangleY,
            width: rectangleWidth,
            height: rectangleHeight
        )
        
        // Заливаем черным цветом
        context.setFillColor(UIColor.black.cgColor)
        context.fill(blackRect)
        
        print("⬛ Черный прямоугольник отрисован: (\(rectangleX), \(rectangleY)), размер \(rectangleWidth)x\(rectangleHeight)")
    }
    
    /**
     * Отрисовывает информационный блок с именем, должностью и summary
     */
    private func drawInfoBlock(formData: SurveyFormData, in context: CGContext) {
        // Параметры блока
        let blockWidth: CGFloat = 892
        let blockHeight: CGFloat = 1937
        let leftMargin: CGFloat = 162
        let bottomMargin: CGFloat = 74
        
        // Позиция блока (отступ снизу означает что Y считается от низа страницы)
        let blockX = leftMargin
        let blockY = pageSize.height - bottomMargin - blockHeight
        
        let blockRect = CGRect(
            x: blockX,
            y: blockY,
            width: blockWidth,
            height: blockHeight
        )
        
        print("📋 Информационный блок: (\(blockX), \(blockY)), размер \(blockWidth)x\(blockHeight)")
        
        // Отрисовываем содержимое блока
        var currentY = blockY
        
        // 1. Имя (I'M NAME SURNAME)
        currentY = drawNameSection(formData: formData, startX: blockX, startY: currentY, blockWidth: blockWidth, in: context)
        
        // 2. Должность
        currentY = drawPositionSection(formData: formData, startX: blockX, startY: currentY, blockWidth: blockWidth, in: context)
        
        // 3. Горизонтальное изображение
        currentY = drawHorizontalImage(startX: blockX, startY: currentY, in: context)
        
                // 4. Summary
        currentY = drawSummarySection(formData: formData, startX: blockX, startY: currentY, blockWidth: blockWidth, in: context)
        
        // 5. Contact
        drawContactSection(formData: formData, startX: blockX, startY: currentY, blockWidth: blockWidth, in: context)
    }
    
    /**
     * Отрисовывает секцию с именем (I'M NAME SURNAME)
     */
    private func drawNameSection(formData: SurveyFormData, startX: CGFloat, startY: CGFloat, blockWidth: CGFloat, in context: CGContext) -> CGFloat {
        // Шрифт Ruda-ExtraBold 220
        let nameFont = UIFont(name: "Ruda-ExtraBold", size: 220) ?? UIFont.boldSystemFont(ofSize: 220)
        
        // Цвет PDF_2_Color (предполагаем что это синий цвет из ColorConfig)
        let nameColor = UIColor(named: "PDF_2_Color") ?? UIColor.blue
        
        let nameAttributes: [NSAttributedString.Key: Any] = [
            .font: nameFont,
            .foregroundColor: nameColor
        ]
        
        // Формируем текст
        let nameText = "I'M\n\(formData.name.uppercased())\n\(formData.surname.uppercased())"
        let nameString = NSAttributedString(string: nameText, attributes: nameAttributes)
        
        // Вычисляем размер текста
        let textSize = nameString.boundingRect(
            with: CGSize(width: blockWidth, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        
        // Позиция: прижат к левому верхнему краю блока
        let textRect = CGRect(x: startX, y: startY, width: blockWidth, height: textSize.height)
        nameString.draw(in: textRect)
        
        print("👤 Имя отрисовано: '\(nameText)' в позиции (\(startX), \(startY))")
        
        return startY + textSize.height + 40 // Добавляем отступ для следующей секции
    }
    
    /**
     * Отрисовывает секцию с должностью
     */
    private func drawPositionSection(formData: SurveyFormData, startX: CGFloat, startY: CGFloat, blockWidth: CGFloat, in context: CGContext) -> CGFloat {
        // Шрифт Ruda-ExtraBold 100
        let positionFont = UIFont(name: "Ruda-ExtraBold", size: 100) ?? UIFont.boldSystemFont(ofSize: 100)
        
        let positionAttributes: [NSAttributedString.Key: Any] = [
            .font: positionFont,
            .foregroundColor: UIColor.black
        ]
        
        // Берем должность из первой работы или используем placeholder
        let positionText = formData.works.first?.position.uppercased() ?? "POSITION"
        let positionString = NSAttributedString(string: positionText, attributes: positionAttributes)
        
        // Вычисляем размер текста с учетом переноса строк
        let textRect = CGRect(x: startX, y: startY, width: blockWidth, height: CGFloat.greatestFiniteMagnitude)
        let boundingRect = positionString.boundingRect(
            with: CGSize(width: blockWidth, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        
        // Отрисовываем текст с переносом
        let drawRect = CGRect(x: startX, y: startY, width: blockWidth, height: boundingRect.height)
        positionString.draw(in: drawRect)
        
        print("💼 Должность отрисована: '\(positionText)' в позиции (\(startX), \(startY)), размер \(blockWidth)x\(boundingRect.height)")
        
        return startY + boundingRect.height + 40 // Добавляем отступ для следующей секции
    }
    
    /**
     * Отрисовывает горизонтальное изображение
     */
    private func drawHorizontalImage(startX: CGFloat, startY: CGFloat, in context: CGContext) -> CGFloat {
        // Загружаем изображение pdf_3_3blackRectHorizontal
        guard let image = UIImage(named: "pdf_3_3blackRectHorizontal") else {
            print("⚠️ Изображение pdf_3_3blackRectHorizontal не найдено")
            // Рисуем черный прямоугольник как fallback
            let rect = CGRect(x: startX, y: startY, width: 301, height: 28)
            context.setFillColor(UIColor.black.cgColor)
            context.fill(rect)
            print("⬛ Fallback: черный прямоугольник 301x28 в позиции (\(startX), \(startY))")
            return startY + 28 + 40
        }
        
        // Размеры изображения 301x28
        let imageRect = CGRect(x: startX, y: startY, width: 301, height: 28)
        image.draw(in: imageRect)
        
        print("🖼️ Горизонтальное изображение отрисовано в позиции (\(startX), \(startY))")
        
        return startY + 28 + 40 // Добавляем отступ для следующей секции
    }
    
    /**
     * Отрисовывает секцию Summary
     */
    private func drawSummarySection(formData: SurveyFormData, startX: CGFloat, startY: CGFloat, blockWidth: CGFloat, in context: CGContext) -> CGFloat {
        // Шрифт Figtree-Regular 36
        let summaryFont = UIFont(name: "Figtree-Regular", size: 36) ?? UIFont.systemFont(ofSize: 36)
        
        let summaryAttributes: [NSAttributedString.Key: Any] = [
            .font: summaryFont,
            .foregroundColor: UIColor.black
        ]
        
        let summaryText = formData.summaryData.summaryText.isEmpty ? 
            "Summary text will appear here when provided." : 
            formData.summaryData.summaryText
        
        let summaryString = NSAttributedString(string: summaryText, attributes: summaryAttributes)
        
        // Вычисляем размер текста с переносом строк
        let textRect = CGRect(x: startX, y: startY, width: blockWidth, height: CGFloat.greatestFiniteMagnitude)
        let boundingRect = summaryString.boundingRect(
            with: CGSize(width: blockWidth, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        
        let drawRect = CGRect(x: startX, y: startY, width: blockWidth, height: boundingRect.height)
        summaryString.draw(in: drawRect)
        
        print("📝 Summary отрисован в позиции (\(startX), \(startY)), размер \(blockWidth)x\(boundingRect.height)")
        
        return startY + boundingRect.height + 40 // Добавляем отступ для следующей секции
    }
    
    /**
     * Отрисовывает секцию Contact
     */
    private func drawContactSection(formData: SurveyFormData, startX: CGFloat, startY: CGFloat, blockWidth: CGFloat, in context: CGContext) {
        var currentY = startY
        
        // 1. Заголовок CONTACT
        let contactTitleFont = UIFont(name: "Ruda-ExtraBold", size: 80) ?? UIFont.boldSystemFont(ofSize: 80)
        let contactTitleAttributes: [NSAttributedString.Key: Any] = [
            .font: contactTitleFont,
            .foregroundColor: UIColor.black
        ]
        
        let contactTitleString = NSAttributedString(string: "CONTACT", attributes: contactTitleAttributes)
        let titleSize = contactTitleString.size()
        
        contactTitleString.draw(at: CGPoint(x: startX, y: currentY))
        currentY += titleSize.height + 40
        
        print("📞 Заголовок CONTACT отрисован в позиции (\(startX), \(startY))")
        
        // 2. Контактная информация
        currentY = drawContactInfo(formData: formData, startX: startX, startY: currentY, in: context)
        
        // 3. Социальные иконки
        drawSocialIcons(startX: startX, startY: currentY, in: context)
    }
    
    /**
     * Отрисовывает контактную информацию
     */
    private func drawContactInfo(formData: SurveyFormData, startX: CGFloat, startY: CGFloat, in context: CGContext) -> CGFloat {
        var currentY = startY
        
        let contactFont = UIFont(name: "Figtree-Medium", size: 36) ?? UIFont.systemFont(ofSize: 36, weight: .medium)
        let contactAttributes: [NSAttributedString.Key: Any] = [
            .font: contactFont,
            .foregroundColor: UIColor.black
        ]
        
        // Адрес
        if !formData.address.isEmpty {
            let addressString = NSAttributedString(string: formData.address, attributes: contactAttributes)
            addressString.draw(at: CGPoint(x: startX, y: currentY))
            currentY += addressString.size().height + 15
            print("🏠 Адрес: \(formData.address)")
        }
        
        // Почта
        if !formData.email.isEmpty {
            let emailString = NSAttributedString(string: formData.email, attributes: contactAttributes)
            emailString.draw(at: CGPoint(x: startX, y: currentY))
            currentY += emailString.size().height + 15
            print("📧 Email: \(formData.email)")
        }
        
        // Телефон
        if !formData.phone.isEmpty {
            let phoneString = NSAttributedString(string: formData.phone, attributes: contactAttributes)
            phoneString.draw(at: CGPoint(x: startX, y: currentY))
            currentY += phoneString.size().height + 15
            print("📱 Телефон: \(formData.phone)")
        }
        
        return currentY + 40 // Отступ для иконок
    }
    
    /**
     * Отрисовывает социальные иконки
     */
    private func drawSocialIcons(startX: CGFloat, startY: CGFloat, in context: CGContext) {
        let iconSize: CGFloat = 73
        let iconSpacing: CGFloat = 115
        let iconNames = ["fbLogo", "instLogo", "inLogo"]
        
        for (index, iconName) in iconNames.enumerated() {
            let iconX = startX + CGFloat(index) * (iconSize + iconSpacing)
            let iconRect = CGRect(x: iconX, y: startY, width: iconSize, height: iconSize)
            
            if let icon = UIImage(named: iconName) {
                icon.draw(in: iconRect)
                print("📱 Иконка \(iconName) отрисована в позиции (\(iconX), \(startY))")
            } else {
                // Fallback: серый квадрат с буквой
                context.setFillColor(UIColor.lightGray.cgColor)
                context.fill(iconRect)
                
                let fallbackFont = UIFont.systemFont(ofSize: 24, weight: .bold)
                let fallbackAttributes: [NSAttributedString.Key: Any] = [
                    .font: fallbackFont,
                    .foregroundColor: UIColor.darkGray
                ]
                
                let fallbackText = String(iconName.prefix(2)).uppercased()
                let fallbackString = NSAttributedString(string: fallbackText, attributes: fallbackAttributes)
                let textSize = fallbackString.size()
                
                let textX = iconX + (iconSize - textSize.width) / 2
                let textY = startY + (iconSize - textSize.height) / 2
                fallbackString.draw(at: CGPoint(x: textX, y: textY))
                
                print("⚠️ Иконка \(iconName) не найдена, отрисован fallback в позиции (\(iconX), \(startY))")
            }
                 }
     }
     
     /**
      * Отрисовывает блок Experience
      */
     private func drawExperienceBlock(formData: SurveyFormData, in context: CGContext) -> CGFloat {
         // Параметры блока Experience
         let blockWidth: CGFloat = 1093
         let blockHeight: CGFloat = 1096
         let rightMargin: CGFloat = 174
         let topMargin: CGFloat = 174
         
         // Позиция блока (справа и сверху)
         let blockX = pageSize.width - rightMargin - blockWidth
         let blockY = topMargin
         
         let blockRect = CGRect(
             x: blockX,
             y: blockY,
             width: blockWidth,
             height: blockHeight
         )
         
         print("💼 Блок Experience: (\(blockX), \(blockY)), размер \(blockWidth)x\(blockHeight)")
         
         var currentY = blockY
         
         // 1. Заголовок WORK EXPERIENCE
         currentY = drawExperienceTitle(startX: blockX, startY: currentY, in: context)
         
         // 2. Места работы
         let finalY = drawWorkExperiences(formData: formData, startX: blockX, startY: currentY, blockWidth: blockWidth, in: context)
         
         return finalY
     }
     
     /**
      * Отрисовывает заголовок WORK EXPERIENCE
      */
     private func drawExperienceTitle(startX: CGFloat, startY: CGFloat, in context: CGContext) -> CGFloat {
         let titleFont = UIFont(name: "Ruda-ExtraBold", size: 80) ?? UIFont.boldSystemFont(ofSize: 80)
         let titleAttributes: [NSAttributedString.Key: Any] = [
             .font: titleFont,
             .foregroundColor: UIColor.black
         ]
         
         let titleString = NSAttributedString(string: "WORK EXPERIENCE", attributes: titleAttributes)
         let titleSize = titleString.size()
         
         titleString.draw(at: CGPoint(x: startX, y: startY))
         
         print("📋 Заголовок WORK EXPERIENCE отрисован в позиции (\(startX), \(startY))")
         
         return startY + titleSize.height + 40 // Отступ для следующей секции
     }
     
     /**
      * Отрисовывает все места работы
      */
     private func drawWorkExperiences(formData: SurveyFormData, startX: CGFloat, startY: CGFloat, blockWidth: CGFloat, in context: CGContext) -> CGFloat {
         var currentY = startY
         
         for (index, work) in formData.works.enumerated() {
             currentY = drawSingleWorkExperience(
                 work: work,
                 startX: startX,
                 startY: currentY,
                 blockWidth: blockWidth,
                 in: context
             )
             
             // Добавляем отступ между местами работы (кроме последнего)
             if index < formData.works.count - 1 {
                 currentY += 60
             }
         }
         
         print("💼 Отрисовано \(formData.works.count) мест работы")
         
         return currentY
     }
     
     /**
      * Отрисовывает одно место работы
      */
     private func drawSingleWorkExperience(work: WorkData, startX: CGFloat, startY: CGFloat, blockWidth: CGFloat, in context: CGContext) -> CGFloat {
         var currentY = startY
         
         // 1. Стрелка arrowDown
         let arrowX = startX
         let arrowY = currentY
         let arrowSize = CGSize(width: 48, height: 40)
         
         if let arrowImage = UIImage(named: "arrowDown") {
             let arrowRect = CGRect(x: arrowX, y: arrowY, width: arrowSize.width, height: arrowSize.height)
             arrowImage.draw(in: arrowRect)
             print("⬇️ Стрелка arrowDown отрисована в позиции (\(arrowX), \(arrowY))")
         } else {
             // Fallback: черная стрелка
             context.setFillColor(UIColor.black.cgColor)
             let arrowRect = CGRect(x: arrowX, y: arrowY, width: arrowSize.width, height: arrowSize.height)
             context.fill(arrowRect)
             print("⚠️ Изображение arrowDown не найдено, отрисован fallback")
         }
         
         // 2. Информация справа от стрелки
         let textStartX = arrowX + arrowSize.width + 20 // Отступ от стрелки
         let textWidth = blockWidth - (textStartX - startX)
         
         var textY = currentY
         
         // Должность
         textY = drawWorkPosition(work: work, startX: textStartX, startY: textY, maxWidth: textWidth, in: context)
         
         // Даты
         textY = drawWorkDates(work: work, startX: textStartX, startY: textY, maxWidth: textWidth, in: context)
         
         // Название места работы
         textY = drawWorkCompany(work: work, startX: textStartX, startY: textY, maxWidth: textWidth, in: context)
         
         // Responsibilities
         textY = drawWorkResponsibilities(work: work, startX: textStartX, startY: textY, maxWidth: textWidth, in: context)
         
         // Возвращаем максимальную высоту (либо стрелка, либо текст)
         let arrowBottom = arrowY + arrowSize.height
         return max(arrowBottom, textY)
     }
     
     /**
      * Отрисовывает должность
      */
     private func drawWorkPosition(work: WorkData, startX: CGFloat, startY: CGFloat, maxWidth: CGFloat, in context: CGContext) -> CGFloat {
         let positionFont = UIFont(name: "Ruda-ExtraBold", size: 50) ?? UIFont.boldSystemFont(ofSize: 50)
         let positionAttributes: [NSAttributedString.Key: Any] = [
             .font: positionFont,
             .foregroundColor: UIColor.black
         ]
         
         let positionString = NSAttributedString(string: work.position, attributes: positionAttributes)
         let boundingRect = positionString.boundingRect(
             with: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude),
             options: [.usesLineFragmentOrigin, .usesFontLeading],
             context: nil
         )
         
         let drawRect = CGRect(x: startX, y: startY, width: maxWidth, height: boundingRect.height)
         positionString.draw(in: drawRect)
         
         print("💼 Должность: \(work.position)")
         
         return startY + boundingRect.height + 10
     }
     
     /**
      * Отрисовывает даты работы
      */
     private func drawWorkDates(work: WorkData, startX: CGFloat, startY: CGFloat, maxWidth: CGFloat, in context: CGContext) -> CGFloat {
         let dateFont = UIFont(name: "Ruda-ExtraBold", size: 50) ?? UIFont.boldSystemFont(ofSize: 50)
         let dateAttributes: [NSAttributedString.Key: Any] = [
             .font: dateFont,
             .foregroundColor: UIColor.black
         ]
         
         let dateText = work.isCurentlyWork ? 
             "[\(work.whenStart) - Present]" : 
             "[\(work.whenStart) - \(work.whenFinished)]"
         
         let dateString = NSAttributedString(string: dateText, attributes: dateAttributes)
         let boundingRect = dateString.boundingRect(
             with: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude),
             options: [.usesLineFragmentOrigin, .usesFontLeading],
             context: nil
         )
         
         let drawRect = CGRect(x: startX, y: startY, width: maxWidth, height: boundingRect.height)
         dateString.draw(in: drawRect)
         
         print("📅 Даты: \(dateText)")
         
         return startY + boundingRect.height + 10
     }
     
     /**
      * Отрисовывает название компании
      */
     private func drawWorkCompany(work: WorkData, startX: CGFloat, startY: CGFloat, maxWidth: CGFloat, in context: CGContext) -> CGFloat {
         let companyFont = UIFont(name: "Figtree-Medium", size: 40) ?? UIFont.systemFont(ofSize: 40, weight: .medium)
         let companyAttributes: [NSAttributedString.Key: Any] = [
             .font: companyFont,
             .foregroundColor: UIColor.black
         ]
         
         let companyString = NSAttributedString(string: work.companyName, attributes: companyAttributes)
         let boundingRect = companyString.boundingRect(
             with: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude),
             options: [.usesLineFragmentOrigin, .usesFontLeading],
             context: nil
         )
         
         let drawRect = CGRect(x: startX, y: startY, width: maxWidth, height: boundingRect.height)
         companyString.draw(in: drawRect)
         
         print("🏢 Компания: \(work.companyName)")
         
         return startY + boundingRect.height + 10
     }
     
     /**
      * Отрисовывает обязанности
      */
     private func drawWorkResponsibilities(work: WorkData, startX: CGFloat, startY: CGFloat, maxWidth: CGFloat, in context: CGContext) -> CGFloat {
         guard !work.responsibilities.isEmpty else {
             return startY
         }
         
         let responsibilitiesFont = UIFont(name: "Figtree-Regular", size: 36) ?? UIFont.systemFont(ofSize: 36)
         let responsibilitiesAttributes: [NSAttributedString.Key: Any] = [
             .font: responsibilitiesFont,
             .foregroundColor: UIColor.black
         ]
         
         let responsibilitiesString = NSAttributedString(string: work.responsibilities, attributes: responsibilitiesAttributes)
         let boundingRect = responsibilitiesString.boundingRect(
             with: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude),
             options: [.usesLineFragmentOrigin, .usesFontLeading],
             context: nil
         )
         
         let drawRect = CGRect(x: startX, y: startY, width: maxWidth, height: boundingRect.height)
         responsibilitiesString.draw(in: drawRect)
         
         print("📝 Обязанности: \(work.responsibilities.prefix(50))...")
         
         return startY + boundingRect.height + 20
     }
     
     /**
      * Отрисовывает блок Education
      */
     private func drawEducationBlock(formData: SurveyFormData, startY: CGFloat, in context: CGContext) -> CGFloat {
         // Параметры блока Education
         let blockWidth: CGFloat = 1093
         let blockHeight: CGFloat = 1096
         let rightMargin: CGFloat = 174
         
         // Позиция блока (справа, начинается с переданной Y координаты)
         let blockX = pageSize.width - rightMargin - blockWidth
         let blockY = startY
         
         let blockRect = CGRect(
             x: blockX,
             y: blockY,
             width: blockWidth,
             height: blockHeight
         )
         
         print("🎓 Блок Education: (\(blockX), \(blockY)), размер \(blockWidth)x\(blockHeight)")
         
         var currentY = blockY
         
         // 1. Заголовок EDUCATION
         currentY = drawEducationTitle(startX: blockX, startY: currentY, in: context)
         
         // 2. Места образования
         let finalY = drawEducationEntries(formData: formData, startX: blockX, startY: currentY, blockWidth: blockWidth, in: context)
         
         return finalY
     }
     
     /**
      * Отрисовывает заголовок EDUCATION
      */
     private func drawEducationTitle(startX: CGFloat, startY: CGFloat, in context: CGContext) -> CGFloat {
         let titleFont = UIFont(name: "Ruda-ExtraBold", size: 80) ?? UIFont.boldSystemFont(ofSize: 80)
         let titleAttributes: [NSAttributedString.Key: Any] = [
             .font: titleFont,
             .foregroundColor: UIColor.black
         ]
         
         let titleString = NSAttributedString(string: "EDUCATION", attributes: titleAttributes)
         let titleSize = titleString.size()
         
         titleString.draw(at: CGPoint(x: startX, y: startY))
         
         print("📚 Заголовок EDUCATION отрисован в позиции (\(startX), \(startY))")
         
         return startY + titleSize.height + 40 // Отступ для следующей секции
     }
     
     /**
      * Отрисовывает все места образования
      */
     private func drawEducationEntries(formData: SurveyFormData, startX: CGFloat, startY: CGFloat, blockWidth: CGFloat, in context: CGContext) -> CGFloat {
         var currentY = startY
         
         for (index, education) in formData.educations.enumerated() {
             currentY = drawSingleEducationEntry(
                 education: education,
                 startX: startX,
                 startY: currentY,
                 blockWidth: blockWidth,
                 in: context
             )
             
             // Добавляем отступ между местами образования (кроме последнего)
             if index < formData.educations.count - 1 {
                 currentY += 60
             }
         }
         
         print("🎓 Отрисовано \(formData.educations.count) мест образования")
         
         return currentY
     }
     
     /**
      * Отрисовывает одно место образования
      */
     private func drawSingleEducationEntry(education: EducationData, startX: CGFloat, startY: CGFloat, blockWidth: CGFloat, in context: CGContext) -> CGFloat {
         var currentY = startY
         
         // 1. Стрелка arrowDown
         let arrowX = startX
         let arrowY = currentY
         let arrowSize = CGSize(width: 48, height: 40)
         
         if let arrowImage = UIImage(named: "arrowDown") {
             let arrowRect = CGRect(x: arrowX, y: arrowY, width: arrowSize.width, height: arrowSize.height)
             arrowImage.draw(in: arrowRect)
             print("⬇️ Стрелка arrowDown отрисована в позиции (\(arrowX), \(arrowY))")
         } else {
             // Fallback: черная стрелка
             context.setFillColor(UIColor.black.cgColor)
             let arrowRect = CGRect(x: arrowX, y: arrowY, width: arrowSize.width, height: arrowSize.height)
             context.fill(arrowRect)
             print("⚠️ Изображение arrowDown не найдено, отрисован fallback")
         }
         
         // 2. Информация справа от стрелки
         let textStartX = arrowX + arrowSize.width + 20 // Отступ от стрелки
         let textWidth = blockWidth - (textStartX - startX)
         
         var textY = currentY
         
         // Название вуза
         textY = drawEducationSchool(education: education, startX: textStartX, startY: textY, maxWidth: textWidth, in: context)
         
         // Даты
         textY = drawEducationDates(education: education, startX: textStartX, startY: textY, maxWidth: textWidth, in: context)
         
         // Описание
         textY = drawEducationDetails(education: education, startX: textStartX, startY: textY, maxWidth: textWidth, in: context)
         
         // Возвращаем максимальную высоту (либо стрелка, либо текст)
         let arrowBottom = arrowY + arrowSize.height
         return max(arrowBottom, textY)
     }
     
     /**
      * Отрисовывает название вуза
      */
     private func drawEducationSchool(education: EducationData, startX: CGFloat, startY: CGFloat, maxWidth: CGFloat, in context: CGContext) -> CGFloat {
         let schoolFont = UIFont(name: "Ruda-ExtraBold", size: 50) ?? UIFont.boldSystemFont(ofSize: 50)
         let schoolAttributes: [NSAttributedString.Key: Any] = [
             .font: schoolFont,
             .foregroundColor: UIColor.black
         ]
         
         let schoolString = NSAttributedString(string: education.schoolName, attributes: schoolAttributes)
         let boundingRect = schoolString.boundingRect(
             with: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude),
             options: [.usesLineFragmentOrigin, .usesFontLeading],
             context: nil
         )
         
         let drawRect = CGRect(x: startX, y: startY, width: maxWidth, height: boundingRect.height)
         schoolString.draw(in: drawRect)
         
         print("🎓 Вуз: \(education.schoolName)")
         
         return startY + boundingRect.height + 10
     }
     
     /**
      * Отрисовывает даты образования
      */
     private func drawEducationDates(education: EducationData, startX: CGFloat, startY: CGFloat, maxWidth: CGFloat, in context: CGContext) -> CGFloat {
         let dateFont = UIFont(name: "Ruda-ExtraBold", size: 50) ?? UIFont.boldSystemFont(ofSize: 50)
         let dateAttributes: [NSAttributedString.Key: Any] = [
             .font: dateFont,
             .foregroundColor: UIColor.black
         ]
         
         let dateText = education.isCurrentlyStudying ? 
             "[\(education.whenStart) - Present]" : 
             "[\(education.whenStart) - \(education.whenFinished)]"
         
         let dateString = NSAttributedString(string: dateText, attributes: dateAttributes)
         let boundingRect = dateString.boundingRect(
             with: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude),
             options: [.usesLineFragmentOrigin, .usesFontLeading],
             context: nil
         )
         
         let drawRect = CGRect(x: startX, y: startY, width: maxWidth, height: boundingRect.height)
         dateString.draw(in: drawRect)
         
         print("📅 Даты образования: \(dateText)")
         
         return startY + boundingRect.height + 10
     }
     
     /**
      * Отрисовывает описание образования
      */
     private func drawEducationDetails(education: EducationData, startX: CGFloat, startY: CGFloat, maxWidth: CGFloat, in context: CGContext) -> CGFloat {
         guard !education.educationalDetails.isEmpty else {
             return startY
         }
         
         let detailsFont = UIFont(name: "Figtree-Regular", size: 36) ?? UIFont.systemFont(ofSize: 36)
         let detailsAttributes: [NSAttributedString.Key: Any] = [
             .font: detailsFont,
             .foregroundColor: UIColor.black
         ]
         
         let detailsString = NSAttributedString(string: education.educationalDetails, attributes: detailsAttributes)
         let boundingRect = detailsString.boundingRect(
             with: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude),
             options: [.usesLineFragmentOrigin, .usesFontLeading],
             context: nil
         )
         
         let drawRect = CGRect(x: startX, y: startY, width: maxWidth, height: boundingRect.height)
         detailsString.draw(in: drawRect)
         
         print("📝 Детали образования: \(education.educationalDetails.prefix(50))...")
         
         return startY + boundingRect.height + 20
     }
     
     /**
      * Отрисовывает блок Skills
      */
     private func drawSkillsBlock(formData: SurveyFormData, startY: CGFloat, in context: CGContext) {
         // Параметры блока Skills
         let blockWidth: CGFloat = 1093
         let rightMargin: CGFloat = 174
         
         // Позиция блока (справа, начинается с переданной Y координаты)
         let blockX = pageSize.width - rightMargin - blockWidth
         let blockY = startY
         
         print("🛠️ Блок Skills: (\(blockX), \(blockY)), ширина \(blockWidth)")
         
         var currentY = blockY
         
         // 1. Заголовок SKILLS
         currentY = drawSkillsTitle(startX: blockX, startY: currentY, in: context)
         
         // 2. Получаем выбранные навыки
         let selectedSkills = getSelectedSkills(formData: formData)
         
         // 3. Отрисовываем сетку навыков
         drawSkillsGrid(skills: selectedSkills, startX: blockX, startY: currentY, blockWidth: blockWidth, in: context)
     }
     
     /**
      * Отрисовывает заголовок SKILLS
      */
     private func drawSkillsTitle(startX: CGFloat, startY: CGFloat, in context: CGContext) -> CGFloat {
         let titleFont = UIFont(name: "Ruda-ExtraBold", size: 80) ?? UIFont.boldSystemFont(ofSize: 80)
         let titleAttributes: [NSAttributedString.Key: Any] = [
             .font: titleFont,
             .foregroundColor: UIColor.black
         ]
         
         let titleString = NSAttributedString(string: "SKILLS", attributes: titleAttributes)
         let titleSize = titleString.size()
         
         titleString.draw(at: CGPoint(x: startX, y: startY))
         
         print("🛠️ Заголовок SKILLS отрисован в позиции (\(startX), \(startY))")
         
         return startY + titleSize.height + 40 // Отступ для следующей секции
     }
     
     /**
      * Отрисовывает сетку навыков (3 в ряду)
      */
     private func drawSkillsGrid(skills: [String], startX: CGFloat, startY: CGFloat, blockWidth: CGFloat, in context: CGContext) {
         let skillsPerRow = 3
         let iconSize: CGFloat = 200
         let textHeight: CGFloat = 80 // Примерная высота текста
         let itemHeight = iconSize + textHeight + 20 // Иконка + текст + отступ
         let horizontalSpacing = (blockWidth - CGFloat(skillsPerRow) * iconSize) / CGFloat(skillsPerRow - 1)
         
         var currentY = startY
         
         for (index, skill) in skills.enumerated() {
             let row = index / skillsPerRow
             let column = index % skillsPerRow
             
             // Вычисляем позицию элемента
             let itemX = startX + CGFloat(column) * (iconSize + horizontalSpacing)
             let itemY = currentY + CGFloat(row) * (itemHeight + 60) // 60px между рядами
             
             // Отрисовываем один навык
             drawSingleSkill(skill: skill, x: itemX, y: itemY, iconSize: iconSize, in: context)
         }
         
         print("🛠️ Отрисовано \(skills.count) навыков в сетке 3x\(Int(ceil(Double(skills.count) / 3.0)))")
     }
     
     /**
      * Отрисовывает один навык (иконка + текст)
      */
     private func drawSingleSkill(skill: String, x: CGFloat, y: CGFloat, iconSize: CGFloat, in context: CGContext) {
         // 1. Отрисовываем иконку
         let iconRect = CGRect(x: x, y: y, width: iconSize, height: iconSize)
         
         if let iconImage = UIImage(named: "100icon") {
             iconImage.draw(in: iconRect)
             print("🔧 Иконка 100icon для навыка '\(skill)' в позиции (\(x), \(y))")
         } else {
             // Fallback: серый квадрат с символом
             context.setFillColor(UIColor.lightGray.cgColor)
             context.fill(iconRect)
             
             let fallbackFont = UIFont.systemFont(ofSize: 60, weight: .bold)
             let fallbackAttributes: [NSAttributedString.Key: Any] = [
                 .font: fallbackFont,
                 .foregroundColor: UIColor.darkGray
             ]
             
             let fallbackString = NSAttributedString(string: "🛠️", attributes: fallbackAttributes)
             let textSize = fallbackString.size()
             
             let textX = x + (iconSize - textSize.width) / 2
             let textY = y + (iconSize - textSize.height) / 2
             fallbackString.draw(at: CGPoint(x: textX, y: textY))
             
             print("⚠️ Иконка 100icon не найдена для '\(skill)', отрисован fallback")
         }
         
         // 2. Отрисовываем название навыка под иконкой
         let skillFont = UIFont(name: "Ruda-ExtraBold", size: 50) ?? UIFont.boldSystemFont(ofSize: 50)
         
         // Создаем параграф с центральным выравниванием
         let paragraphStyle = NSMutableParagraphStyle()
         paragraphStyle.alignment = .center
         
         let skillAttributes: [NSAttributedString.Key: Any] = [
             .font: skillFont,
             .foregroundColor: UIColor.black,
             .paragraphStyle: paragraphStyle
         ]
         
         let skillString = NSAttributedString(string: skill, attributes: skillAttributes)
         let maxTextWidth: CGFloat = 400
         
         // Вычисляем размер текста с учетом переноса строк
         let boundingRect = skillString.boundingRect(
             with: CGSize(width: maxTextWidth, height: CGFloat.greatestFiniteMagnitude),
             options: [.usesLineFragmentOrigin, .usesFontLeading],
             context: nil
         )
         
         // Центрируем текстовый блок под иконкой
         let textX = x + (iconSize - maxTextWidth) / 2
         let textY = y + iconSize + 20 // 20px отступ от иконки
         
         let textRect = CGRect(x: textX, y: textY, width: maxTextWidth, height: boundingRect.height)
         skillString.draw(in: textRect)
         
         print("📝 Навык '\(skill)' отрисован под иконкой с переносом, размер \(maxTextWidth)x\(boundingRect.height)")
     }
     
     /**
      * Получает выбранные навыки из formData
      */
     private func getSelectedSkills(formData: SurveyFormData) -> [String] {
         let hardSkills = formData.additionalSkills.hardSkills.filter { $0.active }.map { $0.name }
         let softSkills = formData.additionalSkills.softSkills.filter { $0.active }.map { $0.name }
         let allSkills = hardSkills + softSkills
         
         print("🛠️ Выбранные навыки: \(allSkills.count) (Hard: \(hardSkills.count), Soft: \(softSkills.count))")
         
         return allSkills
     }
     
     /**
      * Отрисовывает декоративные изображения поверх всех элементов
      */
     private func drawDecorativeImages(in context: CGContext) {
         // 1. Первое изображение pdf_3_3lines (большое)
         let image1Size = CGSize(width: 340, height: 280)
         let image1Position = CGPoint(x: 190, y: 190)
         let image1Rect = CGRect(origin: image1Position, size: image1Size)
         
         if let image1 = UIImage(named: "pdf_3_3lines") {
             image1.draw(in: image1Rect)
             print("🎨 Декоративное изображение 1: pdf_3_3lines (340x280) в позиции (350, 350)")
         } else {
             // Fallback: полупрозрачный серый прямоугольник
             context.setFillColor(UIColor.lightGray.withAlphaComponent(0.3).cgColor)
             context.fill(image1Rect)
             print("⚠️ Изображение pdf_3_3lines не найдено, отрисован fallback в позиции (350, 350)")
         }
         
         // 2. Второе изображение pdf_3_3lines (маленькое)
         let image2Size = CGSize(width: 187, height: 156)
         let image2Position = CGPoint(x: 2300, y: 1500)
         let image2Rect = CGRect(origin: image2Position, size: image2Size)
         
         if let image2 = UIImage(named: "pdf_3_3lines") {
             image2.draw(in: image2Rect)
             print("🎨 Декоративное изображение 2: pdf_3_3lines (187x156) в позиции (2000, 1500)")
         } else {
             // Fallback: полупрозрачный серый прямоугольник
             context.setFillColor(UIColor.lightGray.withAlphaComponent(0.3).cgColor)
             context.fill(image2Rect)
             print("⚠️ Изображение pdf_3_3lines не найдено, отрисован fallback в позиции (2000, 1500)")
         }
         
         print("🎨 Декоративные изображения отрисованы поверх всех элементов")
     }
 
 }   
