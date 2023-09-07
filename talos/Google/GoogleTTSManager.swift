//
//  GoogleTTSManager.swift
//  talos
//
//  Created by Tyler Torres on 5/1/23.
//

import Foundation
import Combine
import AVFoundation


class GoogleTTSManager : NSObject {
    
    enum GoogleTTSError: Error {
        case invalidUrl
        case other(Error)
    }
    
    private let url = "https://texttospeech.googleapis.com/v1/text:synthesize"
    private let apiKey: String = try! Config.getValue(for: Constants.GOOGLE_API_KEY)
    
    private let NEURAL_VOICE : String = "en-US-Neural2-F"
    private let WAVENET_VOICE : String = "en-US-Wavenet-F"
    private let STUDIO_VOICE : String = "en-US-Studio-O"
    
    
    
    private var cancellables = Set<AnyCancellable>()
    private var audioPlayer: AVAudioPlayer?
    
    override init() {  
        super.init()
        audioPlayer = AVAudioPlayer()
        audioPlayer?.delegate = self
    }

    
    func speakText(_ text: String) {
        fetchGoogleTTS(input: text)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: handleCompletion, receiveValue: playAudioContent)
            .store(in: &cancellables)
    }
    
    func fetchGoogleTTS(input: String) -> AnyPublisher<String, GoogleTTSError> {
        
        let request = createTTSRequest(text: input)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { GoogleTTSError.other($0) }
            .tryMap { data, _ in
                let ttsResponse = try JSONDecoder().decode(GoogleSynthesizeResponse.self, from: data)
                print(ttsResponse.audioContent)
                return ttsResponse.audioContent
            }
            .mapError { $0 as? GoogleTTSError ?? GoogleTTSError.other($0) }
            .eraseToAnyPublisher()
    }
    
    private func handleCompletion(_ completion: Subscribers.Completion<GoogleTTSError>) {
        switch completion {
        case .failure(let error):
            print(error)
        case .finished:
            break
        }
    }
    
    private func playAudioContent(_ audioContent: String) {
        guard !audioContent.isEmpty,
              let audioData = Data(base64Encoded: audioContent, options: .ignoreUnknownCharacters) else {
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(data: audioData)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    private func createTTSRequest(text: String) -> URLRequest {
        let url = try! createUrlWithQueryParameters(queryParams: ["key": apiKey])
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! createRequestBody(text: text)
        
        
        return request
    }
    
    private func createUrlWithQueryParameters(queryParams: [String: String]) throws -> URL {
        guard var urlComponents = URLComponents(string: url) else { throw GoogleTTSError.invalidUrl }
        
        urlComponents.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let finalUrl = urlComponents.url else { throw GoogleTTSError.invalidUrl }
        
        return finalUrl
    }
    
    private func createRequestBody(text: String) throws -> Data {
        let input = RequestBody.Input(text: text)
        let audioConfig = RequestBody.AudioConfig(audioEncoding: "MP3")
        let voice = RequestBody.Voice(languageCode: "en-US", name: NEURAL_VOICE)
        
        let requestBody = RequestBody(input: input, voice: voice, audioConfig: audioConfig)
        return try JSONEncoder().encode(requestBody)
    }
}

extension GoogleTTSManager {
    
    struct RequestBody: Encodable {
        
        struct Input: Encodable {
            let text: String
        }
        
        struct Voice: Encodable {
            let languageCode: String
            let name: String
        }
        
        struct AudioConfig: Encodable {
            let audioEncoding: String
        }
        
        let input: Input
        let voice: Voice
        let audioConfig: AudioConfig
    }
}

extension GoogleTTSManager : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            print("Finished successfully.")
        } else {
            print("Did not finish successfully.")
        }
    }
}
