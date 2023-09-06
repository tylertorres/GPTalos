//
//  TalosView.swift
//  talos
//
//  Created by Tyler Torres on 9/4/23.
//

import SwiftUI

@available(iOS 16.1, *)
struct TalosView: View {
    
    @StateObject private var viewModel = TalosViewModel()
    
    var body: some View {
        
        VStack {
            Text(viewModel.modelText)
                .padding()
            Spacer()
            RoundedRectangleButton(title: "Speak & Transcribe") {
                onTapped()
            }
            .frame(height: 60)
        }
        .onAppear {
            viewModel.requestPermissions()
        }
    }
    
    private func onTapped() {
        viewModel.handleTapRecord()
    }
}

struct TalosView_Previews: PreviewProvider {
    static var previews: some View {
        TalosView()
    }
}
