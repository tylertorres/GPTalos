//
//  ThumbnailGenerator.swift
//  talos
//
//  Created by Tyler Torres on 9/14/23.
//

import Foundation
import PDFKit


struct ThumbnailGenerator {
    
    static func generateThumbnailsFromBundle() -> [PDFThumbnailInfo] {
        if let url = Bundle.main.url(forResource: "tylertorres_resume_20230901", withExtension: "pdf"),
           let document = PDFDocument(url: url),
           let page = document.page(at: 0) {
            let thumbnailOne = PDFThumbnailInfo(document: document, thumbnailImage: page.thumbnail(of: CGSize(width: 320, height: 400), for: .artBox))
            let thumbnailTwo = PDFThumbnailInfo(document: document, thumbnailImage: page.thumbnail(of: CGSize(width: 320, height: 400), for: .artBox))
            let thumbnailThree = PDFThumbnailInfo(document: document, thumbnailImage: page.thumbnail(of: CGSize(width: 320, height: 400), for: .artBox))
            let thumbnailFour = PDFThumbnailInfo(document: document, thumbnailImage: page.thumbnail(of: CGSize(width: 320, height: 400), for: .artBox))
            let thumbnailFive = PDFThumbnailInfo(document: document, thumbnailImage: page.thumbnail(of: CGSize(width: 320, height: 400), for: .artBox))
            
            return [thumbnailOne, thumbnailTwo, thumbnailThree, thumbnailFour, thumbnailFive]
        } else {
            return []
        }
    }
}
