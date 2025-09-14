//
//  PDF_2.swift
//  Resume
//
//  Created by Алкександр Степанов on 15.09.2025.
//

import SwiftUI
import PDFKit
import UIKit

// MARK: - PDF_2 Generator Class
class PDF_2_Generator: ObservableObject {
    
    // MARK: - Page Configuration
    /// Размер страницы A4 в точках (2480x3508)
    private let pageSize = CGSize(width: 2480, height: 3508)
    
    // Делим страницу на 3 части по вертикали
    private let topSectionHeight: CGFloat = 787  // pageSize.height / 3
    private let middleSectionHeight: CGFloat = 1169
    private let bottomSectionHeight: CGFloat = 1170  // Последняя часть чуть больше для округления
    
    // MARK: - Font Configuration
    /// Настройки шрифтов для разных элементов
    private struct FontConfig {
        static let nameFont = UIFont(name: "Figtree-ExtraBold", size: 150) ?? UIFont.boldSystemFont(ofSize: 28)
        static let surnameFont = UIFont(name: "Figtree-ExtraBold", size: 150) ?? UIFont.boldSystemFont(ofSize: 28)
        static let positionFont = UIFont(name: "Figtree-Medium", size: 80) ?? UIFont.systemFont(ofSize: 16)
        static let sectionTitleFont = UIFont(name: "Figtree-Bold", size: 70) ?? UIFont.systemFont(ofSize: 18, weight: .medium)
        static let contentFont = UIFont(name: "Figtree-Regular", size: 36) ?? UIFont.systemFont(ofSize: 12)
        static let smallFont = UIFont(name: "Figtree-Regular", size: 36) ?? UIFont.systemFont(ofSize: 10)
        static let infoFont = UIFont(name: "Figtree-Medium", size: 40) ?? UIFont.systemFont(ofSize: 10)
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
    private struct LayoutConfig {
        // Отступы между элементами
        static let smallSpacing: CGFloat = 5
        static let mediumSpacing: CGFloat = 10
        static let largeSpacing: CGFloat = 15
        
        // Отступы от краев
        static let pageMargin: CGFloat = 50
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
            
            // Отрисовываем верхнюю секцию с изображением
            drawTopSection(formData: formData, userPhoto: userPhoto, in: cgContext)
            
            // Отрисовываем круглое фото в первой трети
            drawCircularPhoto(userPhoto: userPhoto, in: cgContext)
            
            // Отрисовываем имя в области 4
            drawNameInArea4(formData: formData, in: cgContext)
            
            // Отрисовываем блок с опытом работы
            drawExperienceBlock(formData: formData, in: cgContext)
            
            // Отрисовываем блок с образованием
            drawEducationBlock(formData: formData, in: cgContext)
            
            // Отрисовываем блок About Me
            drawAboutMeBlock(formData: formData, in: cgContext)
            
            // Отрисовываем блок с контактными данными
            drawContactBlock(formData: formData, in: cgContext)
            
            // Отрисовываем блок со скиллами
            drawSkillsBlock(formData: formData, in: cgContext)
            
            print("🎯 PDF_2 сгенерирован успешно")
        }
        
        return pdfData
    }
    
    // MARK: - Top Section Drawing
    /**
     * Рисует верхнюю секцию с фоновым изображением
     */
    private func drawTopSection(formData: SurveyFormData, userPhoto: UIImage?, in context: CGContext) {
        // Определяем область верхней секции
        let topSectionRect = CGRect(x: 0, y: 0, width: pageSize.width, height: topSectionHeight)
        
        // Загружаем и отрисовываем фоновое изображение pdf_2_topRect
        if let topRectImage = UIImage(named: "pdf_2_topRect") {
            // Растягиваем изображение на всю ширину и высоту верхней секции
            let drawRect = topSectionRect
            
            // Отрисовываем изображение без сохранения пропорций
            topRectImage.draw(in: drawRect)
            print("🖼️ Верхнее изображение отрисовано на всю ширину страницы: \(drawRect)")
        } else {
            // Если изображение не найдено, рисуем заглушку
            context.setFillColor(UIColor.lightGray.cgColor)
            context.fill(topSectionRect)
            print("⚠️ Изображение pdf_2_topRect не найдено, отрисована заглушка")
        }
    }
    
    /**
     * Отрисовывает имя и фамилию внутри изображения pdf_2_topRect с черной рамкой
     */
    private func drawNameInArea4(formData: SurveyFormData, in context: CGContext) {
        // Область верхней секции (где находится pdf_2_topRect)
        let topSectionRect = CGRect(x: 0, y: 0, width: pageSize.width, height: topSectionHeight)
        
        // Создаем полное имя
        let fullName = "\(formData.name) \(formData.surname)"
        
        // Настраиваем шрифт ExtraBold размером 150
        guard let font = UIFont(name: "Figtree-ExtraBold", size: 150) else {
            print("❌ Шрифт Figtree-ExtraBold не найден")
            return
        }
        
        // Создаем атрибуты текста
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black
        ]
        
        let attributedString = NSAttributedString(string: fullName, attributes: textAttributes)
        
        // Вычисляем размер текста
        let textSize = attributedString.size()
        
        // Вычисляем размеры прямоугольников
        let blackRectWidth = textSize.width + 150  // Ширина больше на 150
        let blackRectHeight = textSize.height + 150  // Высота больше на 150
        let whiteRectWidth = blackRectWidth - 16  // Белый прямоугольник меньше на 16
        let whiteRectHeight = blackRectHeight - 16  // Белый прямоугольник меньше на 16
        
        // Делим ширину страницы на 3 части и находим границу между 2-й и 3-й третями (сдвигаем левее и ниже на 85)
        let thirdWidth = pageSize.width / 3
        let centerX = thirdWidth * 2 - 85  // Граница между 2-й и 3-й третями + смещение влево
        
        // Позиционируем так, чтобы верхняя граница черной рамки была на расстоянии 232 от верха страницы
        let blackRectTopY: CGFloat = 232
        let centerY = blackRectTopY + blackRectHeight / 2
        
        // Позиции прямоугольников
        let blackRect = CGRect(
            x: centerX - blackRectWidth / 2,
            y: blackRectTopY,
            width: blackRectWidth,
            height: blackRectHeight
        )
        
        let whiteRect = CGRect(
            x: centerX - whiteRectWidth / 2,
            y: centerY - whiteRectHeight / 2,
            width: whiteRectWidth,
            height: whiteRectHeight
        )
        
        // Рисуем черный прямоугольник
        context.setFillColor(UIColor.black.cgColor)
        context.fill(blackRect)
        
        // Рисуем белый прямоугольник поверх
        context.setFillColor(UIColor.white.cgColor)
        context.fill(whiteRect)
        
        // Добавляем профессию в нижней части рамки
        let profession = formData.works.first?.position ?? "Professional"
        
        // Настраиваем шрифт для профессии (SemiBold 64)
        guard let professionFont = UIFont(name: "Figtree-SemiBold", size: 64) else {
            print("❌ Шрифт Figtree-SemiBold для профессии не найден")
            return
        }
        
        let professionAttributes: [NSAttributedString.Key: Any] = [
            .font: professionFont,
            .foregroundColor: UIColor.black
        ]
        
        let professionString = NSAttributedString(string: profession, attributes: professionAttributes)
        let professionSize = professionString.size()
        
        // Вычисляем позицию для белого прямоугольника профессии (по центру нижней линии)
        let professionRectWidth = professionSize.width + 150  // Шире профессии на 100
        let professionRectHeight = 16  // Высота равна толщине рамки (8*2)
        
        let professionRectY = blackRect.maxY - 8  // По центру нижней линии черной рамки
        let professionWhiteRect = CGRect(
            x: centerX - professionRectWidth / 2,
            y: professionRectY - CGFloat(professionRectHeight / 2),
            width: professionRectWidth,
            height: CGFloat(professionRectHeight)
        )
        
        // Рисуем белый прямоугольник для "стирания" части нижней линии
        context.setFillColor(UIColor.white.cgColor)
        context.fill(professionWhiteRect)
        
        // Рисуем текст профессии
        let professionPosition = CGPoint(
            x: centerX - professionSize.width / 2,
            y: professionRectY - professionSize.height / 2
        )
        
        professionString.draw(at: professionPosition)
        
        // Рисуем текст имени поверх всего
        let textPosition = CGPoint(
            x: centerX - textSize.width / 2,
            y: centerY - textSize.height / 2
        )
        
        attributedString.draw(at: textPosition)
        
        print("📝 Имя '\(fullName)' и профессия '\(profession)' отрисованы с черной рамкой")
        print("📏 Черный прямоугольник: \(blackRect)")
        print("📏 Белый прямоугольник: \(whiteRect)")
        print("📏 Белый прямоугольник профессии: \(professionWhiteRect)")
        print("📏 Позиция текста имени: \(textPosition)")
        print("📏 Позиция текста профессии: \(professionPosition)")
    }
    
    /**
     * Отрисовывает круглое фото в центре первой трети верхней секции
     */
    private func drawCircularPhoto(userPhoto: UIImage?, in context: CGContext) {
        guard let photo = userPhoto else {
            print("⚠️ Фото пользователя не найдено для отрисовки")
            return
        }
        
        // Вычисляем центр первой трети страницы (сдвигаем правее на 85)
        let thirdWidth = pageSize.width / 3
        let centerX = thirdWidth / 2 + 85  // Центр первой трети + смещение вправо
        
        // Параметры круглого фото
        let photoDiameter: CGFloat = 425
        let photoRadius = photoDiameter / 2
        
        // Позиционируем так, чтобы верхняя граница круга была на расстоянии 232 от верха страницы
        let photoTopY: CGFloat = 232
        let centerY = photoTopY + photoRadius
        
        // Вычисляем позицию круглого фото
        let photoRect = CGRect(
            x: centerX - photoRadius,
            y: photoTopY,
            width: photoDiameter,
            height: photoDiameter
        )
        
        // Сохраняем состояние контекста
        context.saveGState()
        
        // Создаем круглую маску
        let circlePath = UIBezierPath(ovalIn: photoRect)
        context.addPath(circlePath.cgPath)
        context.clip()
        
        // Отрисовываем фото с сохранением пропорций (scaledToFill)
        let photoAspectRatio = photo.size.width / photo.size.height
        let circleAspectRatio: CGFloat = 1.0  // Круг всегда 1:1
        
        var drawRect: CGRect
        
        if photoAspectRatio > circleAspectRatio {
            // Фото шире - масштабируем по высоте
            let scaledWidth = photoDiameter * photoAspectRatio
            let offsetX = centerX - scaledWidth / 2
            drawRect = CGRect(x: offsetX, y: centerY - photoRadius, width: scaledWidth, height: photoDiameter)
        } else {
            // Фото выше - масштабируем по ширине
            let scaledHeight = photoDiameter / photoAspectRatio
            let offsetY = centerY - scaledHeight / 2
            drawRect = CGRect(x: centerX - photoRadius, y: offsetY, width: photoDiameter, height: scaledHeight)
        }
        
        // Рисуем фото
        photo.draw(in: drawRect)
        
        // Восстанавливаем состояние контекста
        context.restoreGState()
        
        print("📸 Круглое фото отрисовано в центре первой трети")
        print("📏 Позиция фото: \(photoRect)")
        print("📏 Область отрисовки: \(drawRect)")
    }
    
    /**
     * Отрисовывает блок с опытом работы
     */
    private func drawExperienceBlock(formData: SurveyFormData, in context: CGContext) {
        // Параметры блока
        let blockX: CGFloat = 155
        let blockY: CGFloat = topSectionHeight + 60  // Ниже верхней секции с отступом 60
        let blockWidth: CGFloat = 1406
        let blockHeight: CGFloat = 1114
        
        let blockRect = CGRect(x: blockX, y: blockY, width: blockWidth, height: blockHeight)
        
        // Отрисовываем заголовок EXPERIENCE
        guard let titleFont = UIFont(name: "Figtree-Bold", size: 64) else {
            print("❌ Шрифт Figtree-Bold не найден")
            return
        }
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: UIColor.black
        ]
        
        let titleString = NSAttributedString(string: "EXPERIENCE", attributes: titleAttributes)
        let titlePosition = CGPoint(x: blockX, y: blockY)
        titleString.draw(at: titlePosition)
        
        // Вычисляем позицию для изображения pdf_2_longSkroll
        let titleHeight = titleString.size().height
        let imageY = blockY + titleHeight + 20  // Отступ после заголовка
        
        // Отрисовываем изображение pdf_2_longSkroll
        if let scrollImage = UIImage(named: "pdf_2_longSkroll") {
            let imageRect = CGRect(x: blockX, y: imageY, width: blockWidth, height: 0)
            
            // Вычисляем высоту с сохранением пропорций
            let imageAspectRatio = scrollImage.size.width / scrollImage.size.height
            let scaledHeight = blockWidth / imageAspectRatio
            
            let finalImageRect = CGRect(x: blockX, y: imageY, width: blockWidth, height: scaledHeight)
            scrollImage.draw(in: finalImageRect)
            
            print("🖼️ Изображение pdf_2_longSkroll отрисовано: \(finalImageRect)")
            
            // Начинаем отрисовку мест работы после изображения
            var currentY = imageY + scaledHeight + 30  // Отступ после изображения
            
            drawWorkExperiences(formData: formData, in: context, startY: currentY, blockX: blockX, blockWidth: blockWidth)
            
        } else {
            print("⚠️ Изображение pdf_2_longSkroll не найдено")
            // Если изображения нет, начинаем сразу после заголовка
            let currentY = imageY + 30
            drawWorkExperiences(formData: formData, in: context, startY: currentY, blockX: blockX, blockWidth: blockWidth)
        }
        
        print("💼 Блок Experience отрисован: \(blockRect)")
    }
    
    /**
     * Отрисовывает места работы в блоке Experience
     */
    private func drawWorkExperiences(formData: SurveyFormData, in context: CGContext, startY: CGFloat, blockX: CGFloat, blockWidth: CGFloat) {
        var currentY = startY
        
        // Настройки шрифтов
        guard let positionFont = UIFont(name: "Figtree-Medium", size: 50),
              let dateFont = UIFont(name: "Figtree-SemiBold", size: 40),
              let companyFont = UIFont(name: "Figtree-Medium", size: 40),
              let responsibilitiesFont = UIFont(name: "Figtree-Regular", size: 36) else {
            print("❌ Один или несколько шрифтов не найдены")
            return
        }
        
        let positionAttributes: [NSAttributedString.Key: Any] = [
            .font: positionFont,
            .foregroundColor: UIColor.black
        ]
        
        let dateAttributes: [NSAttributedString.Key: Any] = [
            .font: dateFont,
            .foregroundColor: UIColor(named: "PDFpediodColor") ?? UIColor.gray
        ]
        
        let companyAttributes: [NSAttributedString.Key: Any] = [
            .font: companyFont,
            .foregroundColor: UIColor.black
        ]
        
        let responsibilitiesAttributes: [NSAttributedString.Key: Any] = [
            .font: responsibilitiesFont,
            .foregroundColor: UIColor.black
        ]
        
        for (index, work) in formData.works.enumerated() {
            // Левая колонка - должность (максимальная ширина 447)
            let positionMaxWidth: CGFloat = 447
            let positionString = NSAttributedString(string: work.position.uppercased(), attributes: positionAttributes)
            let positionRect = CGRect(x: blockX, y: currentY, width: positionMaxWidth, height: CGFloat.greatestFiniteMagnitude)
            let positionBoundingRect = positionString.boundingRect(with: CGSize(width: positionMaxWidth, height: CGFloat.greatestFiniteMagnitude),
                                                                  options: [.usesLineFragmentOrigin, .usesFontLeading],
                                                                  context: nil)
            positionString.draw(in: positionRect)
            
            // Даты под должностью
            let dateText = work.isCurentlyWork ?
                "\(work.whenStart) - Present" :
                "\(work.whenStart) - \(work.whenFinished)"
            let dateString = NSAttributedString(string: dateText, attributes: dateAttributes)
            let dateY = currentY + positionBoundingRect.height + 5
            dateString.draw(at: CGPoint(x: blockX, y: dateY))
            
            // Правая колонка - название компании
            let companyX = blockX + positionMaxWidth + 100  // Отступ между колонками
            let companyString = NSAttributedString(string: work.companyName, attributes: companyAttributes)
            companyString.draw(at: CGPoint(x: companyX, y: currentY))
            
            // Responsibilities под названием компании
            let responsibilitiesY = currentY + companyString.size().height + 15
            let responsibilitiesMaxWidth = blockWidth - (companyX - blockX) - 50  // Оставшаяся ширина
            
            print("📍 Работа \(index + 1) (\(work.companyName)):")
            print("   currentY: \(currentY)")
            print("   companyX: \(companyX)")
            print("   companyString.size().height: \(companyString.size().height)")
            print("   responsibilitiesY: \(responsibilitiesY)")
            print("   responsibilitiesMaxWidth: \(responsibilitiesMaxWidth)")
            
            if !work.responsibilities.trimmingCharacters(in: .whitespaces).isEmpty {
                print("💼 PDF_2: Отрисовываем responsibilities для \(work.companyName): '\(work.responsibilities)'")
                let responsibilitiesString = NSAttributedString(string: work.responsibilities, attributes: responsibilitiesAttributes)
                let responsibilitiesRect = CGRect(x: companyX, y: responsibilitiesY, width: responsibilitiesMaxWidth, height: CGFloat.greatestFiniteMagnitude)
                print("   responsibilitiesRect: \(responsibilitiesRect)")
                let responsibilitiesBoundingRect = responsibilitiesString.boundingRect(with: CGSize(width: responsibilitiesMaxWidth, height: CGFloat.greatestFiniteMagnitude),
                                                                                      options: [.usesLineFragmentOrigin, .usesFontLeading],
                                                                                      context: nil)
                responsibilitiesString.draw(in: responsibilitiesRect)
                
                // Вычисляем максимальную высоту блока работы
                let leftColumnHeight = positionBoundingRect.height + 5 + dateString.size().height
                let rightColumnHeight = companyString.size().height + 15 + responsibilitiesBoundingRect.height
                let maxHeight = max(leftColumnHeight, rightColumnHeight)
                
                print("   leftColumnHeight: \(leftColumnHeight)")
                print("   rightColumnHeight: \(rightColumnHeight)")
                print("   maxHeight: \(maxHeight)")
                print("   новый currentY: \(currentY + maxHeight + 50)")
                
                currentY += maxHeight + 50  // Отступ между работами
            } else {
                print("💼 PDF_2: Пустые responsibilities для \(work.companyName)")
                let leftColumnHeight = positionBoundingRect.height + 5 + dateString.size().height
                let rightColumnHeight = companyString.size().height
                let maxHeight = max(leftColumnHeight, rightColumnHeight)
                
                print("   leftColumnHeight: \(leftColumnHeight)")
                print("   rightColumnHeight: \(rightColumnHeight)")
                print("   maxHeight: \(maxHeight)")
                print("   новый currentY: \(currentY + maxHeight + 50)")
                
                currentY += maxHeight + 50
            }
            
            print("💼 Работа \(index + 1): \(work.position) в \(work.companyName)")
        }
    }
    
    /**
     * Отрисовывает блок с образованием
     */
    private func drawEducationBlock(formData: SurveyFormData, in context: CGContext) {
        // Параметры блока (размещаем ниже блока Experience)
        let blockX: CGFloat = 155
        let experienceBlockHeight: CGFloat = 1114 + 60 // Высота блока Experience + отступ
        let blockY: CGFloat = topSectionHeight + experienceBlockHeight + 60  // Ниже блока Experience с отступом 60
        let blockWidth: CGFloat = 1406
        let blockHeight: CGFloat = 800  // Меньше чем у Experience
        
        let blockRect = CGRect(x: blockX, y: blockY, width: blockWidth, height: blockHeight)
        
        // Отрисовываем заголовок EDUCATION
        guard let titleFont = UIFont(name: "Figtree-Bold", size: 64) else {
            print("❌ Шрифт Figtree-Bold не найден")
            return
        }
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: UIColor.black
        ]
        
        let titleString = NSAttributedString(string: "EDUCATION", attributes: titleAttributes)
        let titlePosition = CGPoint(x: blockX, y: blockY)
        titleString.draw(at: titlePosition)
        
        // Вычисляем позицию для изображения pdf_2_longSkroll
        let titleHeight = titleString.size().height
        let imageY = blockY + titleHeight + 20  // Отступ после заголовка
        
        // Отрисовываем изображение pdf_2_longSkroll
        if let scrollImage = UIImage(named: "pdf_2_longSkroll") {
            // Вычисляем высоту с сохранением пропорций
            let imageAspectRatio = scrollImage.size.width / scrollImage.size.height
            let scaledHeight = blockWidth / imageAspectRatio
            
            let finalImageRect = CGRect(x: blockX, y: imageY, width: blockWidth, height: scaledHeight)
            scrollImage.draw(in: finalImageRect)
            
            print("🖼️ Изображение pdf_2_longSkroll отрисовано: \(finalImageRect)")
            
            // Начинаем отрисовку образований после изображения
            let currentY = imageY + scaledHeight + 30  // Отступ после изображения
            
            drawEducationEntries(formData: formData, in: context, startY: currentY, blockX: blockX, blockWidth: blockWidth)
            
        } else {
            print("⚠️ Изображение pdf_2_longSkroll не найдено")
            // Если изображения нет, начинаем сразу после заголовка
            let currentY = imageY + 30
            drawEducationEntries(formData: formData, in: context, startY: currentY, blockX: blockX, blockWidth: blockWidth)
        }
        
        print("🎓 Блок Education отрисован: \(blockRect)")
    }
    
    /**
     * Отрисовывает образования в блоке Education
     */
    private func drawEducationEntries(formData: SurveyFormData, in context: CGContext, startY: CGFloat, blockX: CGFloat, blockWidth: CGFloat) {
        var currentY = startY
        
        // Настройки шрифтов
        guard let schoolFont = UIFont(name: "Figtree-Medium", size: 50),
              let dateFont = UIFont(name: "Figtree-SemiBold", size: 40),
              let degreeFont = UIFont(name: "Figtree-Medium", size: 40),
              let detailsFont = UIFont(name: "Figtree-Regular", size: 36) else {
            print("❌ Один или несколько шрифтов не найдены")
            return
        }
        
        let schoolAttributes: [NSAttributedString.Key: Any] = [
            .font: schoolFont,
            .foregroundColor: UIColor.black
        ]
        
        let dateAttributes: [NSAttributedString.Key: Any] = [
            .font: dateFont,
            .foregroundColor: UIColor(named: "PDFpediodColor") ?? UIColor.gray
        ]
        
        let degreeAttributes: [NSAttributedString.Key: Any] = [
            .font: degreeFont,
            .foregroundColor: UIColor.black
        ]
        
        let detailsAttributes: [NSAttributedString.Key: Any] = [
            .font: detailsFont,
            .foregroundColor: UIColor.black
        ]
        
        for (index, education) in formData.educations.enumerated() {
            // Левая колонка - название школы (максимальная ширина 447)
            let schoolMaxWidth: CGFloat = 447
            let schoolString = NSAttributedString(string: education.schoolName.uppercased(), attributes: schoolAttributes)
            let schoolRect = CGRect(x: blockX, y: currentY, width: schoolMaxWidth, height: CGFloat.greatestFiniteMagnitude)
            let schoolBoundingRect = schoolString.boundingRect(with: CGSize(width: schoolMaxWidth, height: CGFloat.greatestFiniteMagnitude),
                                                              options: [.usesLineFragmentOrigin, .usesFontLeading],
                                                              context: nil)
            schoolString.draw(in: schoolRect)
            
            // Даты под названием школы
            let dateText = education.isCurrentlyStudying ?
                "\(education.whenStart) - Present" :
                "\(education.whenStart) - \(education.whenFinished)"
            let dateString = NSAttributedString(string: dateText, attributes: dateAttributes)
            let dateY = currentY + schoolBoundingRect.height + 5
            dateString.draw(at: CGPoint(x: blockX, y: dateY))
            
            // Правая колонка - степень/специальность
            let degreeX = blockX + schoolMaxWidth + 100  // Отступ между колонками
            let degreeString = NSAttributedString(string: "Bachelor's Degree", attributes: degreeAttributes)  // Заглушка
            degreeString.draw(at: CGPoint(x: degreeX, y: currentY))
            
            // Educational Details под степенью
            let detailsY = currentY + degreeString.size().height + 15
            let detailsMaxWidth = blockWidth - (degreeX - blockX) - 50  // Оставшаяся ширина
            
            print("📍 Образование \(index + 1) (\(education.schoolName)):")
            print("   currentY: \(currentY)")
            print("   degreeX: \(degreeX)")
            print("   detailsY: \(detailsY)")
            print("   detailsMaxWidth: \(detailsMaxWidth)")
            
            if !education.educationalDetails.trimmingCharacters(in: .whitespaces).isEmpty {
                print("🎓 PDF_2: Отрисовываем educational details для \(education.schoolName): '\(education.educationalDetails)'")
                let detailsString = NSAttributedString(string: education.educationalDetails, attributes: detailsAttributes)
                let detailsRect = CGRect(x: degreeX, y: detailsY, width: detailsMaxWidth, height: CGFloat.greatestFiniteMagnitude)
                let detailsBoundingRect = detailsString.boundingRect(with: CGSize(width: detailsMaxWidth, height: CGFloat.greatestFiniteMagnitude),
                                                                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                                                                    context: nil)
                detailsString.draw(in: detailsRect)
                
                // Вычисляем максимальную высоту блока образования
                let leftColumnHeight = schoolBoundingRect.height + 5 + dateString.size().height
                let rightColumnHeight = degreeString.size().height + 15 + detailsBoundingRect.height
                let maxHeight = max(leftColumnHeight, rightColumnHeight)
                
                print("   leftColumnHeight: \(leftColumnHeight)")
                print("   rightColumnHeight: \(rightColumnHeight)")
                print("   maxHeight: \(maxHeight)")
                print("   новый currentY: \(currentY + maxHeight + 50)")
                
                currentY += maxHeight + 50  // Отступ между образованиями
            } else {
                print("🎓 PDF_2: Пустые educational details для \(education.schoolName)")
                let leftColumnHeight = schoolBoundingRect.height + 5 + dateString.size().height
                let rightColumnHeight = degreeString.size().height
                let maxHeight = max(leftColumnHeight, rightColumnHeight)
                
                print("   leftColumnHeight: \(leftColumnHeight)")
                print("   rightColumnHeight: \(rightColumnHeight)")
                print("   maxHeight: \(maxHeight)")
                print("   новый currentY: \(currentY + maxHeight + 50)")
                
                currentY += maxHeight + 50
            }
            
            print("🎓 Образование \(index + 1): \(education.schoolName)")
        }
    }
    
    /**
     * Отрисовывает блок About Me справа
     */
    private func drawAboutMeBlock(formData: SurveyFormData, in context: CGContext) {
        // Параметры блока (справа с отступом)
        let blockWidth: CGFloat = 624
        let blockHeight: CGFloat = 801
        let rightMargin: CGFloat = 155  // Отступ справа (такой же как слева у других блоков)
        let blockX: CGFloat = pageSize.width - rightMargin - blockWidth
        let blockY: CGFloat = topSectionHeight + 60  // На том же уровне что Experience
        
        let blockRect = CGRect(x: blockX, y: blockY, width: blockWidth, height: blockHeight)
        
        // Отрисовываем заголовок ABOUT ME
        guard let titleFont = UIFont(name: "Figtree-Bold", size: 64) else {
            print("❌ Шрифт Figtree-Bold не найден")
            return
        }
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: UIColor.black
        ]
        
        let titleString = NSAttributedString(string: "ABOUT ME", attributes: titleAttributes)
        // Центрируем заголовок по горизонтали
        let titleWidth = titleString.size().width
        let titleCenterX = blockX + (blockWidth - titleWidth) / 2
        let titlePosition = CGPoint(x: titleCenterX, y: blockY)
        titleString.draw(at: titlePosition)
        
        // Вычисляем позицию для изображения pdf_2_shortScroll
        let titleHeight = titleString.size().height
        let imageY = blockY + titleHeight + 20  // Отступ после заголовка
        
        // Отрисовываем изображение pdf_2_shortScroll
        if let scrollImage = UIImage(named: "pdf_2_shortScroll") {
            // Вычисляем высоту с сохранением пропорций
            let imageAspectRatio = scrollImage.size.width / scrollImage.size.height
            let scaledHeight = blockWidth / imageAspectRatio
            
            let finalImageRect = CGRect(x: blockX, y: imageY, width: blockWidth, height: scaledHeight)
            scrollImage.draw(in: finalImageRect)
            
            print("🖼️ Изображение pdf_2_shortScroll для About Me отрисовано: \(finalImageRect)")
            
            // Начинаем отрисовку текста About Me после изображения
            let textStartY = imageY + scaledHeight + 30  // Отступ после изображения
            
            drawAboutMeText(formData: formData, in: context, startY: textStartY, blockX: blockX, blockWidth: blockWidth)
            
        } else {
            print("⚠️ Изображение pdf_2_shortScroll не найдено")
            // Если изображения нет, начинаем сразу после заголовка
            let textStartY = imageY + 30
            drawAboutMeText(formData: formData, in: context, startY: textStartY, blockX: blockX, blockWidth: blockWidth)
        }
        
        print("📝 Блок About Me отрисован: \(blockRect)")
    }
    
    /**
     * Отрисовывает текст About Me (summary)
     */
    private func drawAboutMeText(formData: SurveyFormData, in context: CGContext, startY: CGFloat, blockX: CGFloat, blockWidth: CGFloat) {
        // Настройки шрифта для текста About Me
        guard let aboutMeFont = UIFont(name: "Figtree-Regular", size: 36) else {
            print("❌ Шрифт Figtree-Regular не найден")
            return
        }
        
        let aboutMeAttributes: [NSAttributedString.Key: Any] = [
            .font: aboutMeFont,
            .foregroundColor: UIColor.black
        ]
        
        // Получаем текст summary
        let summaryText = formData.summaryData.summaryText
        
        if !summaryText.trimmingCharacters(in: .whitespaces).isEmpty {
            print("📝 PDF_2: Отрисовываем About Me: '\(summaryText)'")
            
            let aboutMeString = NSAttributedString(string: summaryText, attributes: aboutMeAttributes)
            let textMaxWidth = blockWidth  // Убираем отступы по бокам
            let textRect = CGRect(x: blockX, y: startY, width: textMaxWidth, height: CGFloat.greatestFiniteMagnitude)
            
            let boundingRect = aboutMeString.boundingRect(with: CGSize(width: textMaxWidth, height: CGFloat.greatestFiniteMagnitude),
                                                         options: [.usesLineFragmentOrigin, .usesFontLeading],
                                                         context: nil)
            
            aboutMeString.draw(in: textRect)
            
            print("📝 About Me текст отрисован в позиции (\(textRect.minX), \(textRect.minY)) размером \(boundingRect.width)x\(boundingRect.height)")
        } else {
                         print("📝 PDF_2: Пустой текст About Me")
         }
     }
     
     /**
      * Отрисовывает блок с контактными данными ниже About Me
      */
     private func drawContactBlock(formData: SurveyFormData, in context: CGContext) {
         // Параметры блока (такие же как About Me, но ниже)
         let blockWidth: CGFloat = 624
         let blockHeight: CGFloat = 600  // Меньше чем About Me
         let rightMargin: CGFloat = 155
         let blockX: CGFloat = pageSize.width - rightMargin - blockWidth
         let aboutMeBlockHeight: CGFloat = 801 + 60  // Высота About Me + отступ
         let blockY: CGFloat = topSectionHeight + 60 + aboutMeBlockHeight  // Ниже About Me
         
         let blockRect = CGRect(x: blockX, y: blockY, width: blockWidth, height: blockHeight)
         
         // Отрисовываем заголовок CONTACT
         guard let titleFont = UIFont(name: "Figtree-Bold", size: 64) else {
             print("❌ Шрифт Figtree-Bold не найден")
             return
         }
         
         let titleAttributes: [NSAttributedString.Key: Any] = [
             .font: titleFont,
             .foregroundColor: UIColor.black
         ]
         
         let titleString = NSAttributedString(string: "CONTACT", attributes: titleAttributes)
         // Центрируем заголовок по горизонтали
         let titleWidth = titleString.size().width
         let titleCenterX = blockX + (blockWidth - titleWidth) / 2
         let titlePosition = CGPoint(x: titleCenterX, y: blockY)
         titleString.draw(at: titlePosition)
         
         // Вычисляем позицию для изображения pdf_2_shortScroll
         let titleHeight = titleString.size().height
         let imageY = blockY + titleHeight + 20  // Отступ после заголовка
         
         // Отрисовываем изображение pdf_2_shortScroll
         if let scrollImage = UIImage(named: "pdf_2_shortScroll") {
             // Вычисляем высоту с сохранением пропорций
             let imageAspectRatio = scrollImage.size.width / scrollImage.size.height
             let scaledHeight = blockWidth / imageAspectRatio
             
             let finalImageRect = CGRect(x: blockX, y: imageY, width: blockWidth, height: scaledHeight)
             scrollImage.draw(in: finalImageRect)
             
             print("🖼️ Изображение pdf_2_shortScroll для Contact отрисовано: \(finalImageRect)")
             
             // Начинаем отрисовку контактных данных после изображения
             let contactStartY = imageY + scaledHeight + 30  // Отступ после изображения
             
             drawContactData(formData: formData, in: context, startY: contactStartY, blockX: blockX, blockWidth: blockWidth)
             
         } else {
             print("⚠️ Изображение pdf_2_shortScroll не найдено")
             // Если изображения нет, начинаем сразу после заголовка
             let contactStartY = imageY + 30
             drawContactData(formData: formData, in: context, startY: contactStartY, blockX: blockX, blockWidth: blockWidth)
         }
         
         print("📞 Блок Contact отрисован: \(blockRect)")
     }
     
     /**
      * Отрисовывает контактные данные
      */
     private func drawContactData(formData: SurveyFormData, in context: CGContext, startY: CGFloat, blockX: CGFloat, blockWidth: CGFloat) {
         var currentY = startY
         
         // Настройки шрифтов
         guard let labelFont = UIFont(name: "Figtree-SemiBold", size: 40),
               let valueFont = UIFont(name: "Figtree-Regular", size: 36) else {
             print("❌ Один или несколько шрифтов не найдены")
             return
         }
         
         let labelAttributes: [NSAttributedString.Key: Any] = [
             .font: labelFont,
             .foregroundColor: UIColor.black
         ]
         
         let valueAttributes: [NSAttributedString.Key: Any] = [
             .font: valueFont,
             .foregroundColor: UIColor.black
         ]
         
         let leftMargin: CGFloat = 0  // Убираем отступ слева
         let spacing: CGFloat = 30  // Отступ между разными контактами
         let labelValueSpacing: CGFloat = 10  // Отступ между лейблом и значением
         
         // Address
         if !formData.address.trimmingCharacters(in: .whitespaces).isEmpty {
             let addressLabelString = NSAttributedString(string: "Address", attributes: labelAttributes)
             addressLabelString.draw(at: CGPoint(x: blockX + leftMargin, y: currentY))
             currentY += addressLabelString.size().height + labelValueSpacing
             
             let addressValueString = NSAttributedString(string: formData.address, attributes: valueAttributes)
             let maxWidth = blockWidth  // Убираем отступы
             let addressRect = CGRect(x: blockX + leftMargin, y: currentY, width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
             let addressBoundingRect = addressValueString.boundingRect(with: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude),
                                                                      options: [.usesLineFragmentOrigin, .usesFontLeading],
                                                                      context: nil)
             addressValueString.draw(in: addressRect)
             currentY += addressBoundingRect.height + spacing
         }
         
         // Email
         if !formData.email.trimmingCharacters(in: .whitespaces).isEmpty {
             let emailLabelString = NSAttributedString(string: "Email", attributes: labelAttributes)
             emailLabelString.draw(at: CGPoint(x: blockX + leftMargin, y: currentY))
             currentY += emailLabelString.size().height + labelValueSpacing
             
             let emailValueString = NSAttributedString(string: formData.email, attributes: valueAttributes)
             emailValueString.draw(at: CGPoint(x: blockX + leftMargin, y: currentY))
             currentY += emailValueString.size().height + spacing
         }
         
         // Phone
         if !formData.phone.trimmingCharacters(in: .whitespaces).isEmpty {
             let phoneLabelString = NSAttributedString(string: "Phone", attributes: labelAttributes)
             phoneLabelString.draw(at: CGPoint(x: blockX + leftMargin, y: currentY))
             currentY += phoneLabelString.size().height + labelValueSpacing
             
             let phoneValueString = NSAttributedString(string: formData.phone, attributes: valueAttributes)
             phoneValueString.draw(at: CGPoint(x: blockX + leftMargin, y: currentY))
             currentY += phoneValueString.size().height + spacing
         }
         
         // Website
         if !formData.website.trimmingCharacters(in: .whitespaces).isEmpty {
             let websiteLabelString = NSAttributedString(string: "Website", attributes: labelAttributes)
             websiteLabelString.draw(at: CGPoint(x: blockX + leftMargin, y: currentY))
             currentY += websiteLabelString.size().height + labelValueSpacing
             
             let websiteValueString = NSAttributedString(string: formData.website, attributes: valueAttributes)
             websiteValueString.draw(at: CGPoint(x: blockX + leftMargin, y: currentY))
             currentY += websiteValueString.size().height + spacing
         }
         
                   print("📞 Контактные данные отрисованы")
      }
      
      /**
       * Отрисовывает блок со скиллами ниже Contact
       */
      private func drawSkillsBlock(formData: SurveyFormData, in context: CGContext) {
          // Параметры блока (такие же как другие правые блоки, но ниже Contact)
          let blockWidth: CGFloat = 624
          let blockHeight: CGFloat = 800
          let rightMargin: CGFloat = 155
          let blockX: CGFloat = pageSize.width - rightMargin - blockWidth
          let aboutMeBlockHeight: CGFloat = 801 + 60  // Высота About Me + отступ
          let contactBlockHeight: CGFloat = 600 + 60  // Высота Contact + отступ
          let blockY: CGFloat = topSectionHeight + 60 + aboutMeBlockHeight + contactBlockHeight  // Ниже Contact
          
          let blockRect = CGRect(x: blockX, y: blockY, width: blockWidth, height: blockHeight)
          
          // Отрисовываем заголовок SKILLS
          guard let titleFont = UIFont(name: "Figtree-Bold", size: 64) else {
              print("❌ Шрифт Figtree-Bold не найден")
              return
          }
          
          let titleAttributes: [NSAttributedString.Key: Any] = [
              .font: titleFont,
              .foregroundColor: UIColor.black
          ]
          
          let titleString = NSAttributedString(string: "SKILLS", attributes: titleAttributes)
          // Центрируем заголовок по горизонтали
          let titleWidth = titleString.size().width
          let titleCenterX = blockX + (blockWidth - titleWidth) / 2
          let titlePosition = CGPoint(x: titleCenterX, y: blockY)
          titleString.draw(at: titlePosition)
          
          // Вычисляем позицию для изображения pdf_2_shortScroll
          let titleHeight = titleString.size().height
          let imageY = blockY + titleHeight + 20  // Отступ после заголовка
          
          // Отрисовываем изображение pdf_2_shortScroll
          if let scrollImage = UIImage(named: "pdf_2_shortScroll") {
              // Вычисляем высоту с сохранением пропорций
              let imageAspectRatio = scrollImage.size.width / scrollImage.size.height
              let scaledHeight = blockWidth / imageAspectRatio
              
              let finalImageRect = CGRect(x: blockX, y: imageY, width: blockWidth, height: scaledHeight)
              scrollImage.draw(in: finalImageRect)
              
              print("🖼️ Изображение pdf_2_shortScroll для Skills отрисовано: \(finalImageRect)")
              
              // Начинаем отрисовку скиллов после изображения
              let skillsStartY = imageY + scaledHeight + 30  // Отступ после изображения
              
              drawSkillsData(formData: formData, in: context, startY: skillsStartY, blockX: blockX, blockWidth: blockWidth)
              
          } else {
              print("⚠️ Изображение pdf_2_shortScroll не найдено")
              // Если изображения нет, начинаем сразу после заголовка
              let skillsStartY = imageY + 30
              drawSkillsData(formData: formData, in: context, startY: skillsStartY, blockX: blockX, blockWidth: blockWidth)
          }
          
          print("🎯 Блок Skills отрисован: \(blockRect)")
      }
      
      /**
       * Отрисовывает скиллы с рамками и индикаторами уровня
       */
      private func drawSkillsData(formData: SurveyFormData, in context: CGContext, startY: CGFloat, blockX: CGFloat, blockWidth: CGFloat) {
          var currentY = startY
          
          // Настройки шрифта для названий скиллов
          guard let skillFont = UIFont(name: "Figtree-Medium", size: 36) else {
              print("❌ Шрифт Figtree-Medium не найден")
              return
          }
          
          let skillAttributes: [NSAttributedString.Key: Any] = [
              .font: skillFont,
              .foregroundColor: UIColor.black
          ]
          
          let leftMargin: CGFloat = 0  // Убираем отступ слева
          let skillBoxWidth: CGFloat = 278  // Ширина рамки для текста
          let skillLevelWidth: CGFloat = 346  // Ширина изображения уровня
          let skillLevelHeight: CGFloat = 20  // Высота изображения уровня
          let skillSpacing: CGFloat = 30  // Отступ между скиллами
          let boxPadding: CGFloat = 15  // Внутренние отступы в рамке
          
          // Получаем выбранные скиллы
          let selectedHardSkills = formData.additionalSkills.hardSkills.filter { $0.active }.map { $0.name }
          let selectedSoftSkills = formData.additionalSkills.softSkills.filter { $0.active }.map { $0.name }
          let allSelectedSkills = selectedHardSkills + selectedSoftSkills
          
          for skill in allSelectedSkills {
              // Вычисляем размер текста скилла
              let skillString = NSAttributedString(string: skill, attributes: skillAttributes)
              let textMaxWidth = skillBoxWidth
              let textBoundingRect = skillString.boundingRect(with: CGSize(width: textMaxWidth, height: CGFloat.greatestFiniteMagnitude),
                                                             options: [.usesLineFragmentOrigin, .usesFontLeading],
                                                             context: nil)
              
              // Рисуем текст скилла
              let textRect = CGRect(x: blockX + leftMargin, 
                                   y: currentY, 
                                   width: textMaxWidth, 
                                   height: textBoundingRect.height)
              skillString.draw(in: textRect)
              
              // Рисуем изображение уровня скилла справа
              let skillLevelX = blockX + blockWidth - skillLevelWidth
              let skillLevelY = currentY + (textBoundingRect.height - skillLevelHeight) / 2  // Центрируем по вертикали относительно текста
              
              if let skillLevelImage = UIImage(named: "pdf_2_skillLevel") {
                  let skillLevelRect = CGRect(x: skillLevelX, y: skillLevelY, width: skillLevelWidth, height: skillLevelHeight)
                  skillLevelImage.draw(in: skillLevelRect)
                  print("🎯 Skill level изображение отрисовано для '\(skill)': \(skillLevelRect)")
              } else {
                  // Если изображения нет, рисуем заглушку
                  let skillLevelRect = CGRect(x: skillLevelX, y: skillLevelY, width: skillLevelWidth, height: skillLevelHeight)
                  context.setFillColor(UIColor.lightGray.cgColor)
                  context.fill(skillLevelRect)
                  print("⚠️ Изображение pdf_2_skillLevel не найдено, отрисована заглушка")
              }
              
              // Переходим к следующему скиллу
              currentY += textBoundingRect.height + skillSpacing
              
              print("🎯 Скилл '\(skill)' отрисован")
          }
          
          if allSelectedSkills.isEmpty {
              let noSkillsString = NSAttributedString(string: "No skills selected", attributes: skillAttributes)
              noSkillsString.draw(at: CGPoint(x: blockX + leftMargin, y: currentY))
          }
          
          print("🎯 Все скиллы отрисованы")
      }
}
