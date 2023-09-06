//
//  OpenAIReactiveService.swift
//  talos
//
//  Created by Tyler Torres on 9/5/23.
//

import Foundation
import Combine

enum OpenAIError : Error {
    case invalidUrl
    case invalidAudioFile
    case contentError
    case other(Error)
}

// Another potential way of getting an env var
enum Environment {
    static var myEnvVar: String? {
        return ProcessInfo.processInfo.environment["MY_ENV_VAR"]
    }
}



class OpenAIReactiveService {
    
    private let baseUrl = "https://api.openai.com/v1"
    private let chatCompletionsEndpoint = "/chat/completions"
    private let whisperEndpoint = "/audio/transcriptions"
    
    
    func fetchTranscription() -> AnyPublisher<String, OpenAIError> {
        
        guard let audioData = convertAudioFileToData() else {
            return Fail(error: OpenAIError.invalidAudioFile).eraseToAnyPublisher()
        }
        
        let request = createMultiPartRequest(audioData: audioData, model: ChatModel.whisper.rawValue)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { OpenAIError.other($0) }
            .tryMap { data, _ in
                let whisperResponse = try JSONDecoder().decode(OpenAIWhisperReponse.self, from: data)
                return whisperResponse.text
            }
            .mapError { $0 as? OpenAIError ?? OpenAIError.other($0) }
            .eraseToAnyPublisher()
    }
    
    
    func fetchChatCompletion(input: String) -> AnyPublisher<String, OpenAIError> {
        let request = createChatCompletionRequest(input: input)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { OpenAIError.other($0) }
            .tryMap { data, _ in
                let completionResponse = try JSONDecoder().decode(OpenAIChatCompletionResponse.self, from: data)
                
                guard let result = completionResponse.choices.first?.message.content else {
                    throw OpenAIError.contentError
                }
                
                return result
            }
            .mapError { $0 as? OpenAIError ?? OpenAIError.other($0) }
            .eraseToAnyPublisher()
    }
    
    private func convertAudioFileToData() -> Data? {
        let audioFileUrl = FileUtils.getTemporaryDirectory().appendingPathComponent(Constants.AUDIO_FILENAME)
        
        guard FileManager.default.fileExists(atPath: audioFileUrl.path()) else { return nil }
        
        return try? Data(contentsOf: audioFileUrl)
    }
    
    private func createMultiPartRequest(audioData: Data, model: String) -> URLRequest {
        let boundary = UUID().uuidString
        let mimeType = "audio/mp4"
        let filename = "audio.m4a"
        let language = "en"
        
        let url = URL(string: baseUrl + whisperEndpoint)!
        var request = URLRequest(url: url)
        
        // TODO: Maybe come back to this and move to a more suitable place
        guard let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String else {
            fatalError("Must have an api key to use OpenAI API")
        }
        
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "multipart/form-data; boundary=\(boundary)"
        ]
        
        request.httpBody = createMultiPartBody(with: audioData,
                                               modelName: model,
                                               mimeType: mimeType,
                                               fileName: filename,
                                               boundary: boundary,
                                               language: language)
        
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
    
    private func createChatCompletionRequest(input: String) -> URLRequest {
        
        guard let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String else {
            fatalError("Must have an api key to use OpenAI API")
        }
        
        let url = URL(string: baseUrl + chatCompletionsEndpoint)!
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]
        
        let messages = [["role": "system", "content": input]]
        let parameters = ChatCompletionParams(model: ChatModel.gpt3.rawValue, messages: messages)
        
        do {
            request.httpBody = try JSONEncoder().encode(parameters)
        } catch {
            print(error)
        }
        
        return request
    }
    
}



extension OpenAIReactiveService {
    
    enum ChatModel : String {
        case gpt3 = "gpt-3.5-turbo"
        case gpt4 = "gpt-4"
        case whisper = "whisper-1"
    }
    
    struct ChatCompletionParams : Codable {
        let model : String
        let messages : [[String : String]]
    }
    
    struct CreateChatCompletionParams : Codable {
        let model : String
        let messages : [[String : String]]
    }
    
}
