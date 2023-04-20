//
//  ContentView.swift
//  talos
//
//  Created by Tyler Torres on 4/19/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Button(
                action: {
                    testEmbedding()
                },
                label: {
                    Text("TEST EMBEDDING FUNC")
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(15)
            })
        }
        .padding()
    }
    
    
    
    
    func testEmbedding() {
        let client = OpenAIClient.shared
        let input : String = "Hello world embedding"
        
        client.generateEmbeddings(for: input)
        
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
