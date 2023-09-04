//
//  OpenAIClient.swift
//  talos
//
//  Created by Tyler Torres on 4/19/23.
//

import Foundation


final class OpenAIClient {
    
    static let shared = OpenAIClient()
    
    private let baseUrl = "https://api.openai.com"
    
    private let version = "/v1"
    
    private let embeddingsEndpoint = "/embeddings"
    
    private let completionsEndpoint = "/completions"
    
    private let chatCompletionsEndpoint = "/chat/completions"
    
    private let whisperEndpoint : String = "/audio/transcriptions"
    
    private let apiKey = "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" // TODO: turn this into a environment variable
    
    private let turboChatModel : String = "gpt-3.5-turbo"
    
    private let gpt4ChatModel : String = "gpt-4"
    
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

    
    struct CreateChatCompletionParams : Codable {
        let model : String
        let messages : [[String : String]]
    }
    
    func createChatCompletion(model: String? = "gpt-4",
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
    
    func createTranscription(for audioData: Data, with model: String = "whisper-1") async throws -> String {
        // Build request
        let request = createMultiPartRequest(audioData: audioData, model: model)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let whisperResponse = try JSONDecoder().decode(OpenAIWhisperReponse.self, from: data)
        
        let transcribedText = whisperResponse.text
                
        return transcribedText
    }
    
    private func createMultiPartRequest(audioData: Data, model: String) -> URLRequest {
        let boundary = UUID().uuidString
        
        let mimeType = "audio/mp4"
        let filename = "audioTwo.m4a"
        let language = "en"
        
        // URL Request Building
        let url = URL(string: baseUrl + version + whisperEndpoint)!
        let httpBody = createMultiPartBody(with: audioData,
                                           modelName: model,
                                           mimeType: mimeType,
                                           fileName: filename,
                                           boundary: boundary,
                                           language: language)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "multipart/form-data; boundary=\(boundary)",
        ]
        request.httpBody = httpBody
        
        return request
    }
    
    private func createMultiPartBody(with data: Data,
                                     modelName: String,
                                     mimeType: String,
                                     fileName: String,
                                     boundary: String,
                                     language: String) -> Data {
        var body = Data()
        
        // Add audio data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)

        // Add model data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(modelName)\r\n".data(using: .utf8)!)
        
        // Add optional input language for faster latency per OpenAI docs
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"language\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(language)\r\n".data(using: .utf8)!)

        // Add closing boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
}
