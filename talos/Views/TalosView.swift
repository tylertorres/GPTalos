//
//  TalosView.swift
//  talos
//
//  Created by Tyler Torres on 9/4/23.
//

import SwiftUI

struct TalosView: View {
    
    @StateObject private var viewModel = TalosViewModel()
    @State private var color : Color = Color(hex: "#FFFFFF")

    
    var body: some View {
        ZStack {
            
            color
            
            VStack {
                Text(viewModel.modelText)
                    .padding()
                Spacer()
                RoundedRectangleButton(title: "Speak & Transcribe") {
                    viewModel.handleTapRecord()
                }
                .frame(height: 60)
                .padding()
            }
            .onAppear {
                viewModel.requestPermissions()
            }
        }
    }
}

struct TalosView_Previews: PreviewProvider {
    static var previews: some View {
        TalosView()
    }
}
