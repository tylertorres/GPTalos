//
//  GoogleTTSManager.swift
//  talos
//
//  Created by Tyler Torres on 5/1/23.
//

import Foundation


class GoogleTTSManager {
    
    static let shared = GoogleTTSManager()
    
    private let url : String = "https://texttospeech.googleapis.com/v1/text:synthesize"
    private let apiKey : String = "AIzaSyCW2DYVunybWnhb8q3NowI0tnH-H5goCTI"
    
    private let NEURAL_VOICE : String = "en-US-Neural2-F"
    private let WAVENET_VOICE : String = "en-US-Wavenet-F"
    private let STUDIO_VOICE : String = "n-US-Studio-O"
    
    func callTTS(with text: String) async -> String {
        // Send it payload consisting of input text, audio config, voice config
        let input = [
             "text": text
         ]

         let voice = [
             "languageCode": "en-US",
             "name": NEURAL_VOICE // Choose the desired voice
         ]

         let audioConfig = [
             "audioEncoding": "MP3"
         ]
        
        let requestBody : [String: Any] = [
            "input": input,
            "voice": voice,
            "audioConfig": audioConfig
        ]
        
        let requestData = try! JSONSerialization.data(withJSONObject: requestBody)
        
        let queryParams = [
            "key": apiKey
        ]
        
        let url = createURLWithQueryParameters(baseUrl: url, queryParams: queryParams)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestData
        
        var outputText : String = ""
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
//            print(response)
            
            let googleResponse = try JSONDecoder().decode(GoogleSynthesizeResponse.self, from: data)
            outputText = googleResponse.audioContent
            
        } catch {
            print(error.localizedDescription)
        }
        
        return outputText
    }
    
    private func createURLWithQueryParameters(baseUrl: String, queryParams: [String: String]) -> URL? {
        guard var urlComponents = URLComponents(string: baseUrl) else {
            return nil
        }

        urlComponents.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }

        return urlComponents.url
    }
}
