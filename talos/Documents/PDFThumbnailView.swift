//
//  PDFThumbnailView.swift
//  talos
//
//  Created by Tyler Torres on 9/14/23.
//

import SwiftUI

struct PDFThumbnailView: View {
    
    @ObservedObject var viewModel: DocumentsViewModel
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: [GridItem(.fixed(100))]) {
                ForEach(viewModel.thumbnails, id: \.self) { thumbnail in
                    Button(action: {
                        print("Open PDF")
                    }) {
                        Image(uiImage: thumbnail.thumbnailImage)
                            .resizable()
                            .frame(width: 100, height: 100)
                            .cornerRadius(10)
                    }
                }
            }
        }
    }
    
}

struct PDFThumbnailView_Previews: PreviewProvider {
    static var previews: some View {
        PDFThumbnailView(viewModel: DocumentsViewModel())
    }
}
