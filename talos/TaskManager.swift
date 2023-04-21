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
    
    private let taskList : Queue<Task>
    
    private var contextEmbeddings : Embedding = []
    
    init() {
        self.openAIClient = OpenAIClient.shared
        self.pineconeClient = PineconeClient.shared
        self.taskList = Queue<Task>()
    }
    
    
    func run(objective: String, initialTask : String) {
        
        print("**************** Adding first task to list... ****************")
        taskList.enqueue(Task(id: UUID().uuidString, name: initialTask))
        
        
        while !taskList.isEmpty {
            print("\n******** TASK LIST ********\n")
            
            for task in taskList.queue {
                print("- \(task.name)")
            }
            
            print("\n**************** UPCOMING TASK ****************\n")
            let task = taskList.dequeue()!
            print(task.name)
            
            
            // Execution Agent
            let result = runExecutionAgent(task: task, objective: objective)
            print("\n**************** TASK RESULT ****************\n")

                        
        }
        
    }
    
    private func runExecutionAgent(task: Task, objective: String) -> String {
        
        let context = runContextAgent(query: objective)
        
//        let prompt =
//                    """
//                        You are an AI who performs one task based on the following objective: \(objective)\n.
//                        Take into account these previously completed tasks: \(context)\n.
//                        Your task: \(task.name)\n
//                        Response:
//                    """
//
//        var result = openAIClient.createChatCompletion(prompt: prompt, temperature: 0.7)
    
        
        return ""
    }
    
    private func runContextAgent(query: String, n: Int = 5) {
        
        getQueryEmbedding(query: query)
        
        
        
        
    }
    
    private func getQueryEmbedding(query: String) {
        
        openAIClient.generateEmbeddings(for: query) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.contextEmbeddings = response.data.first!.embedding
            case .failure(let error):
                print("Error occurredd: \(error)")
            }
        }
    }
    

}
