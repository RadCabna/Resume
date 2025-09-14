//
//  PDFKitView.swift
//  Resume
//
//  Created by Алкександр Степанов on 15.09.2025.
//

import SwiftUI
import PDFKit

// MARK: - Universal PDFKitView
struct PDFKitView: UIViewRepresentable {
    
    // MARK: - Properties
    private let pdfDocument: PDFDocument?
    
    // MARK: - Initializers
    /// Инициализация с Data
    init(data: Data) {
        self.pdfDocument = PDFDocument(data: data)
    }
    
    /// Инициализация с PDFDocument
    init(document: PDFDocument) {
        self.pdfDocument = document
    }
    
    // MARK: - UIViewRepresentable
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        
        // Настройки отображения
        pdfView.autoScales = true
        pdfView.displayMode = .singlePage
        pdfView.displayDirection = .vertical
        
        // Настройки качества
        pdfView.interpolationQuality = .high
        
        // Включаем возможность выделения текста
        pdfView.enableDataDetectors = true
        
        // Загружаем PDF документ
        if let document = pdfDocument {
            pdfView.document = document
            pdfView.go(to: document.page(at: 0)!)  // Переходим на первую страницу
            
            // Автоматически масштабируем для показа всей страницы
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit
                print("📏 PDF масштабирован для показа всей страницы, масштаб: \(pdfView.scaleFactor)")
            }
            
            print("📄 PDF документ загружен в PDFView, страниц: \(document.pageCount)")
        } else {
            print("❌ Не удалось создать PDFDocument из данных")
        }
        
        return pdfView
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {
        // Если данные изменились, перезагружаем документ
        if pdfView.document != pdfDocument {
            pdfView.document = pdfDocument
            if let document = pdfDocument {
                pdfView.go(to: document.page(at: 0)!)
                
                // Автоматически масштабируем для показа всей страницы
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit
                    print("📏 PDF обновлен и масштабирован, масштаб: \(pdfView.scaleFactor)")
                }
                
                print("🔄 PDF документ обновлен в PDFView")
            }
        }
    }
} 