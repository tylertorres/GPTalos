//
//  ThumbnailGrid.swift
//  talos
//
//  Created by Tyler Torres on 9/14/23.
//

import SwiftUI
import PDFKit

struct ThumbnailGrid: View {
    
//    @ObservedObject var viewModel: DocumentsViewModel

    let thumbnails: [PDFThumbnailInfo]

    var body: some View {

        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(thumbnails, id: \.self) { thumbnail in
                    ThumbnailCard(thumbnail: thumbnail, action: {})
                }
            }
            .padding(.horizontal, 20)
        }
    }
}



struct ThumbnailGrid_Previews: PreviewProvider {
    static var previews: some View {
        if let url = Bundle.main.url(forResource: "tylertorres_resume_20230901", withExtension: "pdf"),
           let document = PDFDocument(url: url),
           let page = document.page(at: 0) {
            let thumbnailOne = PDFThumbnailInfo(document: document, thumbnailImage: page.thumbnail(of: CGSize(width: 320, height: 400), for: .artBox))
            let thumbnailTwo = PDFThumbnailInfo(document: document, thumbnailImage: page.thumbnail(of: CGSize(width: 320, height: 400), for: .artBox))
            let thumbnailThree = PDFThumbnailInfo(document: document, thumbnailImage: page.thumbnail(of: CGSize(width: 320, height: 400), for: .artBox))
            let thumbnailFour = PDFThumbnailInfo(document: document, thumbnailImage: page.thumbnail(of: CGSize(width: 320, height: 400), for: .artBox))
            let thumbnailFive = PDFThumbnailInfo(document: document, thumbnailImage: page.thumbnail(of: CGSize(width: 320, height: 400), for: .artBox))
            
//            ThumbnailGrid(thumbnails: [thumbnailOne])
            
            ThumbnailGrid(thumbnails: [thumbnailOne, thumbnailTwo, thumbnailThree, thumbnailFour, thumbnailFive])
        }
    }
}
