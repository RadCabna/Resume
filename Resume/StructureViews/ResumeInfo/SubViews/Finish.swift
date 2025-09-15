//
//  Finish.swift
//  Resume
//
//  Created by Алкександр Степанов on 01.09.2025.
//

import SwiftUI
import PDFKit
import CoreData

struct Finish: View {
    @ObservedObject var formData: SurveyFormData
    @ObservedObject var surveyManager: SurveyManager
    @State private var stepNumber = 7  // Finish screen (8-й шаг, индекс 7)
    @State private var stepsTextArray = Arrays.stepsTextArray
    @StateObject private var keyboardObserver = KeyboardObserver()
    
    // MARK: - PDF Management
    @StateObject private var pdfGenerator = PDF_1_Generator()
    @StateObject private var pdf2Generator = PDF_2_Generator()
    @StateObject private var pdf3Generator = PDF_3_Generator()
    @State private var pdfThumbnailImage: UIImage?
    @State private var pdf2ThumbnailImage: UIImage?
    @State private var pdf3ThumbnailImage: UIImage?
    @State private var showingPDFView = false
    @State private var showingPDF2View = false
    @State private var showingPDF3View = false
    @State private var showingPDF3Share = false
    
    // MARK: - Photo Management
    @State private var profilePhoto: UIImage?
    @State private var showingPhotoPicker = false
    @State private var photoUpdateID = UUID() // Для принудительного обновления PDF
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: screenHeight*0.02) {
                Image(.personFinishFrame)
                    .resizable()
                    .scaledToFit()
                    .overlay(
                        HStack {
                            Button(action: {
                                showingPhotoPicker = true
                            }) {
                                if let profilePhoto = profilePhoto {
                                    Image(uiImage: profilePhoto)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: screenHeight*0.15, height: screenHeight*0.18)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                } else {
                                    Image(.noPhoto)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: screenHeight*0.18)
                                }
                            }
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
                
                // MARK: - PDF Thumbnail Section
                PDFThumbnailView()
                    .padding(.top, screenHeight*0.03)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
//            .frame(maxWidth: screenWidth*0.9)
            .padding(.top, screenHeight*0.2)
            .padding(.bottom, keyboardObserver.isKeyboardVisible ? screenHeight*0.4 : screenHeight*0.15)
            .animation(.easeInOut(duration: 0.3), value: keyboardObserver.isKeyboardVisible)
        }
        .sheet(isPresented: $showingPDFView) {
            PDFPreviewView(formData: formData, userPhoto: formData.photos.first?.image)
                .id(photoUpdateID) // Принудительно пересоздаем view при изменении фото
        }
        .sheet(isPresented: $showingPDF2View) {
            PDFPreview2View(formData: formData, userPhoto: formData.photos.first?.image)
                .id(photoUpdateID) // Принудительно пересоздаем view при изменении фото
        }
        .sheet(isPresented: $showingPDF3View) {
            PDFPreview3View(formData: formData, userPhoto: formData.photos.first?.image)
                .id(photoUpdateID) // Принудительно пересоздаем view при изменении фото
        }
        .sheet(isPresented: $showingPhotoPicker) {
            PhotoPicker(selectedImage: $profilePhoto)
        }
        .onAppear {
            // Отладочная информация
            print("🔍 Finish onAppear - данные в formData:")
            print("📝 Name: '\(formData.name)', Surname: '\(formData.surname)'")
            print("📧 Email: '\(formData.email)', Phone: '\(formData.phone)'")
            print("🎓 Educations count: \(formData.educations.count)")
            if !formData.educations.isEmpty {
                print("🎓 First education: '\(formData.educations[0].schoolName)'")
            }
            print("💼 Works count: \(formData.works.count)")
            if !formData.works.isEmpty {
                print("💼 First work: '\(formData.works[0].companyName)' - '\(formData.works[0].position)'")
            }
            print("📝 Summary: '\(formData.summaryData.summaryText)'")
            print("📷 Photos count: \(formData.photos.count)")
            
            // Убеждаемся что все данные сохранены в CoreData перед генерацией PDF
            surveyManager.saveDraft()
            // Принудительно перезагружаем все данные из CoreData
            surveyManager.forceReloadFromCoreData()
            
            // Отладочная информация после перезагрузки
            print("🔄 После перезагрузки:")
            print("🎓 Educations count: \(formData.educations.count)")
            print("💼 Works count: \(formData.works.count)")
            
            // Небольшая задержка перед генерацией PDF чтобы данные успели обновиться
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                generatePDFThumbnail()
            }
            loadProfilePhoto()
        }
        .onChange(of: profilePhoto) { _ in
            saveProfilePhoto()
            
            // Даем время CoreData сохранить данные, затем перезагружаем все данные
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                surveyManager.forceReloadFromCoreData()
                generatePDFThumbnail() // Перегенерируем превью PDF с новым фото
                photoUpdateID = UUID() // Обновляем ID для принудительной перегенерации PDF view
            }
        }
    }
    
    // MARK: - Photo Management Functions
    
    private func loadProfilePhoto() {
        // Загружаем первое фото из formData.photos как профильное
        if let firstPhoto = formData.photos.first,
           let image = firstPhoto.image {
            profilePhoto = image
        }
    }
    
    private func saveProfilePhoto() {

        // Сохраняем выбранное фото в formData.photos
        if let photo = profilePhoto {
            let photoData = PhotoData()
            photoData.image = photo
            photoData.fileName = "profile_\(Date().timeIntervalSince1970).jpg"
            photoData.createdAt = Date()
            
            // Заменяем или добавляем как первое фото
            if formData.photos.isEmpty {
                formData.photos.append(photoData)
            } else {
                formData.photos[0] = photoData
            }
            
            // Сразу сохраняем в CoreData
            savePhotoToCoreData(photo)
            
            print("📷 Профильное фото сохранено в память и CoreData")
        }
    }
    
    private func savePhotoToCoreData(_ image: UIImage) {
        // Используем тот же контекст, что и SurveyManager
        let viewContext = surveyManager.context
        
        // Находим текущий черновик Person
        let request: NSFetchRequest<Person> = Person.fetchRequest()
        request.predicate = NSPredicate(format: "isDraft == true")
        request.sortDescriptors = [NSSortDescriptor(key: "lastModified", ascending: false)]
        request.fetchLimit = 1
        
        do {
            let drafts = try viewContext.fetch(request)
            
            guard let currentDraft = drafts.first else {
                print("❌ Черновик не найден в savePhotoToCoreData")
                return
            }
            
            // Удаляем старые фото для этого Person
            deleteExistingPhotosFromCoreData(for: currentDraft, context: viewContext)
            

            
            // Создаем новое фото в CoreData
            let photo = Photo(context: viewContext)
            
            // Сжимаем изображение для хранения
            if let compressedData = image.jpegData(compressionQuality: 0.8) {
                photo.imageData = compressedData
            }
            
            // Создаем thumbnail
            if let thumbnail = image.resized(to: CGSize(width: 150, height: 150)),
               let thumbnailData = thumbnail.jpegData(compressionQuality: 0.7) {
                photo.thumbnailData = thumbnailData
            }
            
            photo.fileName = "profile_\(Date().timeIntervalSince1970).jpg"
            photo.createdAt = Date()
            photo.person = currentDraft
            
            // Сохраняем изменения
            try viewContext.save()
            print("📷 Фото успешно сохранено в CoreData")
            

            
        } catch {
            print("❌ Ошибка сохранения фото в CoreData: \(error)")
        }
    }
    
    private func deleteExistingPhotosFromCoreData(for person: Person, context: NSManagedObjectContext) {
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        request.predicate = NSPredicate(format: "person == %@", person)
        
        do {
            let existingPhotos = try context.fetch(request)
            for photo in existingPhotos {
                context.delete(photo)
            }
            print("🗑️ Удалено старых фото: \(existingPhotos.count)")
        } catch {
            print("❌ Ошибка удаления старых фото: \(error)")
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
    // Используем замыкание для инициализации
    let (testFormData, testSurveyManager) = {
        let formData = SurveyFormData()
        formData.name = "John"
        formData.surname = "Doe"
        formData.email = "john.doe@example.com"
        formData.phone = "+1 (555) 123-4567"
        formData.website = "www.johndoe.com"
        formData.address = "123 Main St, New York, NY"
        formData.adress_1 = "Apt 4B"
        
        // Добавляем тестовое образование
        let education = EducationData()
        education.schoolName = "Harvard University"
        education.whenStart = "09/2018"
        education.whenFinished = "05/2022"
        education.isCurrentlyStudying = false
        formData.educations.append(education)
        
        // Добавляем тестовую работу
        let work = WorkData()
        work.companyName = "Apple Inc."
        work.position = "Software Engineer"
        work.companiLocation = "Cupertino, CA"
        work.whenStart = "06/2022"
        work.whenFinished = "Present"
        work.isCurentlyWork = true
        formData.works.append(work)
        
        // Добавляем тестовый summary
        let summaryData = SummaryData()
        summaryData.summaryText = "Experienced software engineer with expertise in iOS development."
        formData.summaryData = summaryData
        
        // Создаем тестовый SurveyManager
        let surveyManager = SurveyManager(context: PersistenceController.preview.container.viewContext)
        surveyManager.formData = formData
        
        return (formData, surveyManager)
    }()
    
    Finish(formData: testFormData, surveyManager: testSurveyManager)
}

// MARK: - PDF Thumbnail Extension
extension Finish {
    
    /**
     * Генерирует миниатюру PDF документа
     */
    private func generatePDFThumbnail() {
        DispatchQueue.global(qos: .userInitiated).async {
            // Генерируем миниатюру для PDF_1
            if let pdfData = pdfGenerator.generatePDF(formData: formData, userPhoto: formData.photos.first?.image),
               let pdfDocument = PDFDocument(data: pdfData),
               let firstPage = pdfDocument.page(at: 0) {
                
                let thumbnailSize = CGSize(width: 200, height: 283) // Соотношение A4
                let thumbnail = firstPage.thumbnail(of: thumbnailSize, for: .mediaBox)
                
                DispatchQueue.main.async {
                    self.pdfThumbnailImage = thumbnail
                    print("✅ PDF_1 миниатюра создана успешно")
                }
            } else {
                print("❌ Не удалось создать PDF_1 миниатюру")
            }
            
            // Генерируем миниатюру для PDF_2
            if let pdf2Data = pdf2Generator.generatePDF(formData: formData, userPhoto: formData.photos.first?.image),
               let pdf2Document = PDFDocument(data: pdf2Data),
               let firstPage2 = pdf2Document.page(at: 0) {
                
                let thumbnailSize = CGSize(width: 200, height: 283) // Соотношение A4
                let thumbnail2 = firstPage2.thumbnail(of: thumbnailSize, for: .mediaBox)
                
                DispatchQueue.main.async {
                    self.pdf2ThumbnailImage = thumbnail2
                    print("✅ PDF_2 миниатюра создана успешно")
                }
            } else {
                print("❌ Не удалось создать PDF_2 миниатюру")
            }
            
            // Generate thumbnail for PDF_3
            if let pdf3Data = pdf3Generator.generatePDF(formData: formData, userPhoto: formData.photos.first?.image),
               let pdf3Document = PDFDocument(data: pdf3Data),
               let firstPage3 = pdf3Document.page(at: 0) {
                
                let thumbnailSize = CGSize(width: 200, height: 283) // Соотношение A4
                let thumbnail3 = firstPage3.thumbnail(of: thumbnailSize, for: .mediaBox)
                
                DispatchQueue.main.async {
                    self.pdf3ThumbnailImage = thumbnail3
                    print("✅ PDF_3 миниатюра создана успешно")
                }
            } else {
                print("❌ Не удалось создать PDF_3 миниатюру")
            }
        }
    }
    
    /**
     * Компонент для отображения миниатюры PDF
     */
    @ViewBuilder
    private func PDFThumbnailView() -> some View {
        VStack(alignment: .leading, spacing: screenHeight*0.02) {
            
            
            VStack(spacing: screenHeight*0.03) {
                // Верхний ряд: Template 1 и Template 2
                HStack(spacing: screenWidth*0.05) {
                    // Template 1
                    VStack(spacing: screenHeight*0.01) {
                        Button(action: {
                            // Убеждаемся что все данные сохранены перед открытием PDF
                            surveyManager.saveDraft()
                            surveyManager.forceReloadFromCoreData()
                            showingPDFView = true
                            print("📄 Открываем полный просмотр PDF Template 1")
                        }) {
                            ZStack {
                                // Фон для миниатюры
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white)
                                    .frame(width: screenWidth*0.4, height: screenWidth*0.56) // A4 пропорции
                                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                                
                                if let thumbnail = pdfThumbnailImage {
                                    // Отображаем реальную миниатюру PDF
                                    Image(uiImage: thumbnail)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: screenWidth*0.4, height: screenWidth*0.56)
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                } else {
                                    // Placeholder пока миниатюра загружается
                                    VStack(spacing: 10) {
                                        ProgressView()
                                            .scaleEffect(1.0)
                                        
                                        Text("Generating...")
                                            .font(Font.custom("Figtree-Regular", size: screenHeight*0.014))
                                            .foregroundStyle(Color.gray)
                                    }
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Download Button
                        Button(action: {
                            downloadPDF1()
                        }) {
                            HStack {
                                Image(.downloadIcon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: screenHeight*0.025)
                                Text("Download PDF")
                                    .font(Font.custom("Figtree-Regular", size: screenHeight*0.016))
                                    .foregroundStyle(Color.gray)
                            }
                        }
                        .frame(width: screenWidth*0.4)
                    }
                    
                    // Template 2
                    VStack(spacing: screenHeight*0.01) {
                        Button(action: {
                            // Убеждаемся что все данные сохранены перед открытием PDF
                            surveyManager.saveDraft()
                            surveyManager.forceReloadFromCoreData()
                            showingPDF2View = true
                            print("📄 Открываем полный просмотр PDF Template 2")
                        }) {
                            ZStack {
                                // Фон для миниатюры
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white)
                                    .frame(width: screenWidth*0.4, height: screenWidth*0.56) // A4 пропорции
                                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                                
                                if let thumbnail = pdf2ThumbnailImage {
                                    // Отображаем реальную миниатюру PDF
                                    Image(uiImage: thumbnail)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: screenWidth*0.4, height: screenWidth*0.56)
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                } else {
                                    // Placeholder пока миниатюра загружается
                                    VStack(spacing: 10) {
                                        ProgressView()
                                            .scaleEffect(1.0)
                                        
                                        Text("Generating...")
                                            .font(Font.custom("Figtree-Regular", size: screenHeight*0.014))
                                            .foregroundStyle(Color.gray)
                                    }
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Download Button
                        Button(action: {
                            downloadPDF2()
                        }) {
                            HStack {
                                Image(.downloadIcon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: screenHeight*0.025)
                                Text("Download PDF")
                                    .font(Font.custom("Figtree-Regular", size: screenHeight*0.016))
                                    .foregroundStyle(Color.gray)
                            }
                        }
                        .frame(width: screenWidth*0.4)
                    }
                }
                
                // Нижний ряд: Template 3
                HStack(spacing: screenWidth*0.05) {
                    // Template 3
                    VStack(spacing: screenHeight*0.01) {
                        Button(action: {
                            // Убеждаемся что все данные сохранены перед открытием PDF
                            surveyManager.saveDraft()
                            surveyManager.forceReloadFromCoreData()
                            showingPDF3View = true
                            print("📄 Открываем полный просмотр PDF Template 3")
                        }) {
                            ZStack {
                                // Фон для миниатюры
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white)
                                    .frame(width: screenWidth*0.4, height: screenWidth*0.56) // A4 пропорции
                                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                                
                                if let thumbnail = pdf3ThumbnailImage {
                                    // Отображаем реальную миниатюру PDF
                                    Image(uiImage: thumbnail)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: screenWidth*0.4, height: screenWidth*0.56)
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                } else {
                                    // Placeholder пока миниатюра загружается
                                    VStack(spacing: 10) {
                                        ProgressView()
                                            .scaleEffect(1.0)
                                        
                                        Text("Generating...")
                                            .font(Font.custom("Figtree-Regular", size: screenHeight*0.014))
                                            .foregroundStyle(Color.gray)
                                    }
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            downloadPDF3()
                        }) {
                            HStack {
                                Image(.downloadIcon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: screenHeight*0.025)
                                Text("Download PDF")
                                    .font(Font.custom("Figtree-Regular", size: screenHeight*0.016))
                                    .foregroundStyle(Color.gray)
                            }
                        }
                        .frame(width: screenWidth*0.4)
                    }
                    
                    Spacer() // Пустое место справа от Template 3
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, screenWidth*0.1)
        }
    }
    
    /**
     * Скачивает PDF Template 1
     */
    private func downloadPDF1() {
        print("📥 Начинаем скачивание PDF Template 1")
        
        // Убеждаемся что все данные сохранены
        surveyManager.saveDraft()
        surveyManager.forceReloadFromCoreData()
        
        // Генерируем PDF_1
        guard let pdf1Data = pdfGenerator.generatePDF(formData: formData, userPhoto: formData.photos.first?.image) else {
            print("❌ Не удалось сгенерировать PDF Template 1")
            return
        }
        
        // Создаем временный файл
        let fileName = "\(formData.name)_\(formData.surname)_Resume_Template1.pdf"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try pdf1Data.write(to: tempURL)
            print("✅ PDF Template 1 сохранен во временный файл: \(tempURL)")
            
            // Показываем системное меню для сохранения/отправки
            DispatchQueue.main.async {
                self.sharePDF1(url: tempURL)
            }
        } catch {
            print("❌ Ошибка при сохранении PDF Template 1: \(error)")
        }
    }
    
    /**
     * Скачивает PDF Template 2
     */
    private func downloadPDF2() {
        print("📥 Начинаем скачивание PDF Template 2")
        
        // Убеждаемся что все данные сохранены
        surveyManager.saveDraft()
        surveyManager.forceReloadFromCoreData()
        
        // Генерируем PDF_2
        guard let pdf2Data = pdf2Generator.generatePDF(formData: formData, userPhoto: formData.photos.first?.image) else {
            print("❌ Не удалось сгенерировать PDF Template 2")
            return
        }
        
        // Создаем временный файл
        let fileName = "\(formData.name)_\(formData.surname)_Resume_Template2.pdf"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try pdf2Data.write(to: tempURL)
            print("✅ PDF Template 2 сохранен во временный файл: \(tempURL)")
            
            // Показываем системное меню для сохранения/отправки
            DispatchQueue.main.async {
                self.sharePDF2(url: tempURL)
            }
        } catch {
            print("❌ Ошибка при сохранении PDF Template 2: \(error)")
        }
    }
    
    /**
     * Скачивает PDF Template 3
     */
    private func downloadPDF3() {
        print("📥 Начинаем скачивание PDF Template 3")
        
        // Убеждаемся что все данные сохранены
        surveyManager.saveDraft()
        surveyManager.forceReloadFromCoreData()
        
        // Генерируем PDF_3
        guard let pdf3Data = pdf3Generator.generatePDF(formData: formData, userPhoto: formData.photos.first?.image) else {
            print("❌ Не удалось сгенерировать PDF Template 3")
            return
        }
        
        // Создаем временный файл
        let fileName = "\(formData.name)_\(formData.surname)_Resume_Template3.pdf"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try pdf3Data.write(to: tempURL)
            print("✅ PDF Template 3 сохранен во временный файл: \(tempURL)")
            
            // Показываем системное меню для сохранения/отправки
            DispatchQueue.main.async {
                self.sharePDF3(url: tempURL)
            }
        } catch {
            print("❌ Ошибка при сохранении PDF Template 3: \(error)")
        }
    }
    
    /**
     * Показывает системное меню для экспорта PDF Template 3
     */
    private func sharePDF3(url: URL) {
        let activityController = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        
        // Настраиваем заголовок
        activityController.setValue("\(formData.name) \(formData.surname) - Resume Template 3", forKey: "subject")
        
        // Для iPad - задаем источник popover
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first,
           let rootViewController = window.rootViewController {
            
            if let popover = activityController.popoverPresentationController {
                popover.sourceView = window
                popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            rootViewController.present(activityController, animated: true) {
                print("📤 Системное меню экспорта PDF Template 3 открыто")
            }
        }
    }
    
    /**
     * Показывает системное меню для экспорта PDF Template 1
     */
    private func sharePDF1(url: URL) {
        let activityController = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        
        // Настраиваем заголовок
        activityController.setValue("\(formData.name) \(formData.surname) - Resume Template 1", forKey: "subject")
        
        // Для iPad - задаем источник popover
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first,
           let rootViewController = window.rootViewController {
            
            if let popover = activityController.popoverPresentationController {
                popover.sourceView = window
                popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            rootViewController.present(activityController, animated: true) {
                print("📤 Системное меню экспорта PDF Template 1 открыто")
            }
        }
    }
    
    /**
     * Показывает системное меню для экспорта PDF Template 2
     */
    private func sharePDF2(url: URL) {
        let activityController = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        
        // Настраиваем заголовок
        activityController.setValue("\(formData.name) \(formData.surname) - Resume Template 2", forKey: "subject")
        
        // Для iPad - задаем источник popover
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first,
           let rootViewController = window.rootViewController {
            
            if let popover = activityController.popoverPresentationController {
                popover.sourceView = window
                popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            rootViewController.present(activityController, animated: true) {
                print("📤 Системное меню экспорта PDF Template 2 открыто")
            }
        }
    }
    
}
