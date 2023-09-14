//
//  PDFKitView.swift
//  talos
//
//  Created by Tyler Torres on 9/14/23.
//

import Foundation
import SwiftUI
import PDFKit

struct PDFKitView: UIViewRepresentable {
    
    var documentData: Data?
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        guard let documentData = documentData else { return }
        
        uiView.document = PDFDocument(data: documentData)
    }
}
