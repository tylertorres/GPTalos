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
        .task {
//            let tm = TaskManager()
//
//            let currentTask : LLMTask = LLMTask(id: UUID().uuidString, name: "Develop a task list")
//
//            let embedding = await tm.runContextAgent(query: "Who is who?")
//            print(embedding)
//            print()
//
//            let result = await tm.runExecutionAgent(objective: "Write a weather report for New York City", currentTask: currentTask)
//
//            await tm.upsertEnrichedTask(result: result, namespace: "test", task: currentTask)
            await testFunc()
        }
        .padding()
    }
    
    
    
    func testFunc() async {
        let tm = TaskManager()
        
        await tm.query(namespace: "test")
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
    
    func testGenEmbeddingAndUpsert() {
        let config = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: config,delegate:nil, delegateQueue: .main)
        
        
        let openAIClient = OpenAIClient.shared
        let pineconeClient = PineconeClient.shared
        
//        openAIClient.generateEmbeddings(for: "RetrievalQA differs from ConversationalQA as the latter allows for chat history.") { res in
//
//            switch res {
//                case .success(let response):
//
//                let embedding = response.data.first?.embedding
//
//                pineconeClient.upsert(id: UUID().uuidString, vector: embedding!, namespace: "test", index: "talos-index-1") { result in
//                    switch result {
//                    case .success(let dict):
//                        print(dict.upsertedCount)
//                    case.failure(let error):
//                        print("ERROR occurred on upsert : \(error)")
//                    }
//                }
//
//
//                case .failure(let error):
//                    print(error)
//            }
//
//        }
    }
    
    private func generateEmbedding() -> Embedding {
        let openAIClient = OpenAIClient.shared
        
        var embeddings : Embedding = []
        
//        openAIClient.generateEmbeddings(for: "RetrievalQA differs from ConversationalQA as the latter allows for chat history.") { res in
//
//            switch res {
//            case .success(let response):
//                print(response.data.first!.embedding)
//                embeddings = response.data.first!.embedding
//            case .failure(let error):
//                print(error)
//            }
//        }
        
        return embeddings
            
    }
    
    func testQuery() {
        let pineconeClient = PineconeClient.shared
        let openAIClient = OpenAIClient.shared
        
//        openAIClient.generateEmbeddings(for: "What is different about RetrievalQA than ConversationalQA?") { res in
//
//            switch res {
//            case .success(let response):
//
//                let embeddings = response.data.first!.embedding
//
//                pineconeClient.query(
//                    vector: embeddings, topK: 5, includeMetadata: true, namespace: "test", indexName: "talos-index-1"
//                ) { result in
//                    switch result {
//                    case .success(let response):
//                        print(response)
//                    case .failure(let error):
//                        print(error)
//                    }
//                }
//
//            case .failure(let error):
//                print(error)
//            }
//        }

    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


// TODO: Figure out way to decouple nested api calls in trailing closures
// TODO: For all optional values in requests, change their value to Optional ( adding ? )
// TODO: Refactor PineconeClient to encapsulate all config related properties upon initialization
// TODO: Figure out metadata generic dictionary issue


// Notes:
// - comparing vector values and extracting metadata from that ,such as tasks, text, etc


