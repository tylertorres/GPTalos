//
//  RoundedRectangleButton.swift
//  talos
//
//  Created by Tyler Torres on 9/4/23.
//

import SwiftUI

struct RoundedRectangleButton: View {
    
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title2)
                .frame(maxWidth: .infinity, maxHeight: 200)
        }
        .buttonStyle(RoundedButtonStyle())
        .padding(.horizontal)
    }
}

struct RoundedButtonStyle : ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .fontDesign(.rounded)
            .foregroundColor(Color.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(configuration.isPressed ? Color.blue.opacity(0.7) : Color.blue)
            )
    }
}

struct RoundedRectangleButton_Previews: PreviewProvider {
    static var previews: some View {
        RoundedRectangleButton(title: "Speak & Transcribe", action: {})
    }
}
