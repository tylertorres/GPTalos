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
    
    
    func generateEmbeddings(for input: String, completion: @escaping (Result<OpenAIEmbeddingResponse, Error>) -> Void) {
        
        var embeddingsRequest = createDefaultEmbeddingsRequest()
        
        // Configure json body
        let jsonBody = [
            "model": embeddingsModel,
            "input": input
        ]
        
        let jsonPostData = try! JSONSerialization.data(withJSONObject: jsonBody)
        embeddingsRequest.httpBody = jsonPostData
        
        URLSession.shared.dataTask(with: embeddingsRequest) { [weak self] data, response, error in
            
            guard let data = data else {
                print(error?.localizedDescription ?? "No data returned")
                return
            }
            
            do {
                let embeddingResponse = try JSONDecoder().decode(OpenAIEmbeddingResponse.self, from: data)
                completion(.success(embeddingResponse))
            } catch {
                print(error)
            }
        
        }.resume()
        
    }
    
    
    
    private func createDefaultEmbeddingsRequest() -> URLRequest {
        
        let url = URL(string: baseUrl + version + embeddingsEndpoint)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(self.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
    }
    
}
