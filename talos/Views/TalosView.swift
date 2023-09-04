//
//  TalosView.swift
//  talos
//
//  Created by Tyler Torres on 9/4/23.
//

import SwiftUI

@available(iOS 16.1, *)
struct TalosView: View {
    
    @StateObject private var talosViewModel = TalosViewModel()
    
    var body: some View {
        
        VStack {
            Spacer()
            RoundedRectangleButton(title: "Speak & Transcribe") {
                print("Button Tapped")
            }
            .frame(height: 70)
        }
    }
}

struct TalosView_Previews: PreviewProvider {
    static var previews: some View {
        TalosView()
    }
}
