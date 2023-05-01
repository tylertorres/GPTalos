//
//  Transcriber.swift
//  talos
//
//  Created by Tyler Torres on 4/29/23.
//

import Foundation

class Transcriber {
    
    private var whisperIsEnabled : Bool = true
    private let openAIClient : OpenAIClient = OpenAIClient.shared
    
    func transcribe() async -> String {
        
        do {
            if (whisperIsEnabled) {
                return try await transcribeUsingOAI()
            }
            return try await transcribeNative()
            
        } catch {
            print("Error thrown while transcribing")
            return ""
        }
    }
    
    private func transcribeUsingOAI() async throws -> String {
        
        guard let audioData = try convertAudioToData() else { return "" }
        
        let transcribedText = try await openAIClient.createTranscription(for: audioData)
        
        return transcribedText
    }
    
    private func transcribeNative() async throws -> String {
        return ""
    }
    
    private func convertAudioToData() throws -> Data? {
        let audioFileUrl = FileUtils.getTemporaryDirectory().appendingPathComponent(Constants.AUDIO_FILENAME)
        
        return try Data(contentsOf: audioFileUrl)
    }
    
}






