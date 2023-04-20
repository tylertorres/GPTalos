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
                    testDeleteIndex()
                },
                label: {
                    Text("TEST FUNC")
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
    
    func testListIndexPinecone() {
        let client = PineconeClient.shared
        
        client.listIndexes()
    }
    
    func testCreateIndex() {
        let pinecone = PineconeClient.shared
        let parameters = CreateIndexParameters(name: "talos-index-2", dimension: 1536, metric: "cosine", pods: 1, replicas: 1, pod_type: "p1.x1")
        
        pinecone.createIndex(parameters: parameters) { result in
            
            switch result {
            case .success(let httpResponse):
                print(httpResponse)

            case .failure(let error):
                print(error)
            }
            
        }
    }
    
    func testDeleteIndex() {
        let client = PineconeClient.shared
        
        client.deleteIndex(indexName: "talos-index-3") { result in
            
            switch result {
            case .success(let response):
                print(response)
            case .failure(let error):
                print(error)
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
