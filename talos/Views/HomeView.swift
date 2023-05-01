//
//  HomeView.swift
//  talos
//
//  Created by Tyler Torres on 4/30/23.
//

import SwiftUI

struct HomeView: View {
    
    var randomColor : Color {
        let red = Double.random(in: 0...1)
        let green = Double.random(in: 0...1)
        let blue = Double.random(in: 0...1)

        return Color(red: red, green: green, blue: blue)
    }
    
    var color : Color = Color(hex: "#006400")
    
    var body: some View {
        
        NavigationStack {
            
            ZStack {
                
                color.edgesIgnoringSafeArea(.all)
                    .cornerRadius(20)
                
                VStack {
                    
                    Text("Hello, World!")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    Text("I am the greatest there is")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                }
                
            }
            .padding(.init(top: 20, leading: 20, bottom: 0, trailing: 20))
            .shadow(radius: 15)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(
                        action: {},
                        label: {
                            Image(systemName: "mic")
                                .bold()
                                .foregroundColor(.green)
                        }
                    )
                }
            }
            
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
