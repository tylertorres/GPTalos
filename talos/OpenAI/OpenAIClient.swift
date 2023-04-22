//
//  OpenAIClient.swift
//  talos
//
//  Created by Tyler Torres on 4/19/23.
//

import Foundation


class OpenAIClient {
    
    static let shared = OpenAIClient()
    
    private let baseUrl = "https://api.openai.com"
    
    private let version = "/v1"
    
    private let embeddingsEndpoint = "/embeddings"
    
    private let completionsEndpoint = "/completions"
    
    private let chatCompletionsEndpoint = "/chat/completions"
    
    private let apiKey = "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" // TODO: turn this into a environment variable
    
    private let chatModel : String = "gpt-3.5-turbo"
    
    private let embeddingsModel : String = "text-embedding-ada-002"
    
    
    func generateEmbeddings(for input: String) async throws -> Embedding {
        
        var embeddingsRequest = createDefaultEmbeddingsRequest()
        
        // Configure json body
        let jsonBody = [
            "model": embeddingsModel,
            "input": input
        ]
        
        let jsonPostData = try! JSONSerialization.data(withJSONObject: jsonBody)
        embeddingsRequest.httpBody = jsonPostData

        let (data, _) = try await URLSession.shared.data(for: embeddingsRequest)
        
        let embeddingResponse = try JSONDecoder().decode(OpenAIEmbeddingResponse.self, from: data)
        
        guard let embedding = embeddingResponse.data.first?.embedding else { return [] }
        
        return embedding
    }
    
    
    private func createDefaultEmbeddingsRequest() -> URLRequest {
        
        let url = URL(string: baseUrl + version + embeddingsEndpoint)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(self.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
    }
    
    func createCompletion() {}
    
    
    struct CreateChatCompletionParams : Codable {
        let model : String
        let messages : [[String : String]]
    }
    
    func createChatCompletion(model: String? = "gpt-3.5-turbo",
                              prompt: String,
                              temperature: Float) async throws -> String {
        
        let urlString = baseUrl + version + chatCompletionsEndpoint
        let url = URL(string: urlString)
        
        var chatCompletionRequest = URLRequest(url: url!)
        chatCompletionRequest.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
        chatCompletionRequest.httpMethod = "POST"
            
        let messages = [["role": "system", "content": prompt]]
        let parameters = CreateChatCompletionParams(model: model!, messages: messages)
        
        do {
            chatCompletionRequest.httpBody = try JSONEncoder().encode(parameters)
        } catch {
            print(error)
        }
        
        let (data, _ ) = try await URLSession.shared.data(for: chatCompletionRequest)

        let completionResponse = try JSONDecoder().decode(OpenAIChatCompletionResponse.self, from: data)
        
        let result = completionResponse.choices.first?.message.content
        
        return result ?? ""
    }
    
}
