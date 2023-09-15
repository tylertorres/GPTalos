//
//  ThumbnailCard.swift
//  talos
//
//  Created by Tyler Torres on 9/14/23.
//

import SwiftUI
import PDFKit

struct ThumbnailCard: View {

    let thumbnail: PDFThumbnailInfo
    let action: () -> Void

    var body: some View {

        Button(action: action) {

            ZStack(alignment: .bottom) {

                Image(uiImage: thumbnail.thumbnailImage)
                    .resizable()
                    .frame(height: 400)

                VStack {
                    Text(thumbnail.description)
                        .lineLimit(2, reservesSpace: true)
                        .frame(maxWidth: .infinity)
                }
                .font(.body.bold())
                .padding(.vertical, 10)
                .padding(.horizontal, 10)
                .background(.blue.gradient)
                .foregroundColor(.white)
            }
            .frame(width: 320)
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .shadow(radius: 2)
            .padding(4)
        }
    }
}

struct ThumbnailCard_Previews: PreviewProvider {
    static var previews: some View {
        if let url = Bundle.main.url(forResource: "tylertorres_resume_20230901", withExtension: "pdf"),
           let document = PDFDocument(url: url),
           let page = document.page(at: 0) {
            ThumbnailCard(thumbnail: .init(document: document, thumbnailImage: page.thumbnail(of: CGSize(width: 320, height: 400), for: .artBox)), action: {} )
        }
    }
}
