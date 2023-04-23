//
//  TaskManager.swift
//  talos
//
//  Created by Tyler Torres on 4/20/23.
//

import Foundation


class TaskManager {
    
    private let openAIClient : OpenAIClient
    private let pineconeClient: PineconeClient
    
    private let taskList : Queue<LLMTask>
    
    private var contextEmbeddings : Embedding = []
    
    init() {
        self.openAIClient = OpenAIClient.shared
        self.pineconeClient = PineconeClient.shared
        self.taskList = Queue<LLMTask>()
    }
    
    func runExecutionAgent(context: [LLMTask] = [],
                           objective: String,
                           currentTask: LLMTask) async -> String {
        let prompt =
                    """
                        You are an AI who performs one task based on the following objective: \(objective)\n.
                        Take into account these previously completed tasks: \(context)\n.
                        Your task: \(currentTask.name)\n
                        Response:
                    """
        
        var result : String = "TEST"
        
        do {
            result = try await openAIClient.createChatCompletion(prompt: prompt, temperature: 0.5)
        } catch {
            print(error)
        }
        
        return result
    
    }
    
    func runContextAgent(query: String,
                         n: Int = 5) async -> Embedding {
        
        var embeddings : Embedding = []
        
        do {
            embeddings = try await openAIClient.generateEmbeddings(for: query)
        } catch {
            print(error)
        }
        
        return embeddings
    }
    
    func upsertEnrichedTask(result: String, namespace: String, task: LLMTask) async {
        
        let resultId = "result_\(task.id)"
        var resultEmbeddings : Embedding = []
        
        do {
            resultEmbeddings = try await openAIClient.generateEmbeddings(for: result)
        } catch {
            print("Error occured when trying to generate embedings for result")
            return
        }
        
        do {
            let upsert = try await pineconeClient.upsert(id: resultId,
                                                         vector: resultEmbeddings,
                                                         metadata: ["task": task.name, "result": result],
                                                         namespace: namespace,
                                                         index: "talos-index-1")
            print("Upsert Successful : \(upsert)")
        } catch {
            print(error)
        }
    }
    
    func query(namespace: String) async {
        
        do {
            let queryVector = try await openAIClient.generateEmbeddings(for: "What are some tasks I have completed?")
            
            let response = try await pineconeClient.query(vector: queryVector,
                                                topK: 5,
                                                includeMetadata: true,
                                                namespace: namespace,
                                                indexName: "talos-index-1")
            
            
            
        } catch {
            print(error)
        }
        
    }

}
