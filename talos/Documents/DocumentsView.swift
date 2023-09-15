//
//  DocumentsView.swift
//  talos
//
//  Created by Tyler Torres on 9/13/23.
//

import SwiftUI
import PDFKit

struct DocumentsView: View {
    
    @State private var isFilePickerPresented = false
    @State private var isPDFReadyToView = false
    @State private var documentData: Data?
        
    @StateObject private var viewModel = DocumentsViewModel()
    
    var body: some View {
        ThumbnailGrid(thumbnails: ThumbnailGenerator.generateThumbnailsFromBundle())
    }
}

struct DocumentsView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentsView()
    }
}
