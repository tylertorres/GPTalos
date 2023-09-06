//
//  ListeningIndicator.swift
//  talos
//
//  Created by Tyler Torres on 9/4/23.
//

import SwiftUI

struct ListeningIndicator: View {
    
    @State private var currentIndex = 0
    
    let numberOfDots: Int
    let animationInterval: TimeInterval
    
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<numberOfDots, id: \.self) { index in
                PulsatingDot(isActive: index == currentIndex)
            }
        }
        .onAppear {
            animate()
        }
    }
    
    private func animate() {
        Timer.scheduledTimer(withTimeInterval: animationInterval, repeats: true) { _ in
            currentIndex = (currentIndex + 1) % numberOfDots
        }
    }
}

struct PulsatingDot: View {
    var isActive: Bool
    
    var body: some View {
        Circle()
            .frame(width: 10, height: 10)
            .foregroundColor(Color.gray)
            .scaleEffect(isActive ? 1.5 : 1)
            .opacity(isActive ? 0.5 : 1)
            .animation(Animation.easeInOut(duration: 0.5).repeatForever(), value: isActive)
    }
}



struct ListeningIndicator_Previews: PreviewProvider {
    static var previews: some View {
        ListeningIndicator(numberOfDots: 3, animationInterval: 0.5)
    }
}
