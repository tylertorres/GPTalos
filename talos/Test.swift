//
//  Test.swift
//  talos
//
//  Created by Tyler Torres on 4/23/23.
//

import SwiftUI
import Speech
import AVFoundation

struct ContentViewOne: View {
    @State private var isListening = false
    @State private var assistantText = "Hi there! How can I help you?"
    
    private let activationPhrase = "Hi assistant"
    private let speechRecognizer = SFSpeechRecognizer()
    private let audioEngine = AVAudioEngine()
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    var body: some View {
        VStack {
            Text(assistantText)
                .padding()
            
            // Add any other UI elements you need
        }
        .onAppear {
            requestSpeechRecognitionPermission()
            startListeningForActivationPhrase()
        }
    }
    
    private func requestSpeechRecognitionPermission() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            if authStatus != .authorized {
                fatalError("Speech recognition permission not granted")
            }
        }
    }
    
    private func startListeningForActivationPhrase() {
        guard SFSpeechRecognizer.authorizationStatus() == .authorized else { return }
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            isListening = false
        } else {
//            startRecognitionTask()
            isListening = true
        }
    }
    
    //    private func startRecognitionTask() {
    //
    //        recognitionTask?.cancel()
    //        recognitionTask = nil
    //
    //        let audioSession = AVAudioSession.sharedInstance()
    //        try? audioSession.setCategory(., mode: .measurement, options: .duckOthers)
    //        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    //
    //        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    //        guard let recognitionRequest = recognitionRequest else { return }
    //
    //        let inputNode = audioEngine.inputNode
    //        recognitionRequest.shouldReportPartialResults = true
    //
    //        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
    //            if let result = result {
    //                let recognizedText = result.bestTranscription.formattedString
    //                if recognizedText.lowercased() == self.activationPhrase.lowercased() {
    //                    self.audioEngine.stop()
    //                    inputNode.removeTap(onBus: 0)
    //                    self.recognitionRequest = nil
    //                    self.recognitionTask = nil
    //
    //                    self.processUserCommand()
    //                }
    //            }
    //
    //            if error != nil {
    //                self.audioEngine.stop()
    //                inputNode.removeTap(onBus: 0)
    //                self.recognitionRequest = nil
    //                self.recognitionTask = nil
    //            }
    //        }
    //
    //        let recordingFormat = inputNode.outputFormat(forBus: 0)
    //        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
    //            self.recognitionRequest?.append(buffer)
    //        }
    //
    //        audioEngine.prepare()
    //
    //        do {
    //            try audioEngine.start()
    //        } catch {
    //            fatalError("Could not start audio engine")
    //        }
    //    }
    
    private func processUserCommand() {
        // Implement processing and responding to user commands here.
        // You can use a natural language processing library or API to help with understanding and responding to user queries.
        
        // For this example, we'll just provide a simple response.
        let responseText = "I'm here to help you!"
        self.assistantText = responseText
        self.speak(text: responseText)
    }
    
    private func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        
        speechSynthesizer.speak(utterance)
    }
}
