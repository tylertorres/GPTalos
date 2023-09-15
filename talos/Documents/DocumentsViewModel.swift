//
//  DocumentsViewModel.swift
//  talos
//
//  Created by Tyler Torres on 9/14/23.
//

import Foundation
import PDFKit

struct PDFThumbnailInfo : Hashable {
    let document: PDFDocument
    let thumbnailImage: UIImage
    let description: String = "This is a description of the current pdf"
}

class DocumentsViewModel : ObservableObject {
    
    @Published var thumbnails: [PDFThumbnailInfo] = []
    
    func loadPDFsFromBundle() {
        guard let resourceURL = Bundle.main.resourceURL else { return }
        
        do {
            thumbnails = try generateThumbnails(from: resourceURL)
        } catch {
            print("Error while fetching : \(error.localizedDescription)")
        }
    }
    
    func generateThumbnails(from resourceURL: URL) throws -> [PDFThumbnailInfo] {
        let fileNames = try FileManager.default.contentsOfDirectory(at: resourceURL, includingPropertiesForKeys: nil)
        let filteredFilenames = fileNames.filter { $0.pathExtension.lowercased() == "pdf" }
        
        return filteredFilenames.compactMap { filename in
            guard let documentData = FileManager.default.contents(atPath: filename.path()),
                  let document = PDFDocument(data: documentData),
                  let page = document.page(at: 0) else { return nil }
            
            let thumbnail = page.thumbnail(of: CGSize(width: 100, height: 100), for: .artBox)
            return PDFThumbnailInfo(document: document, thumbnailImage: thumbnail)
        }
    }
}
