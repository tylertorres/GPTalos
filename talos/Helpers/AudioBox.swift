//
//  AudioAgent.swift
//  talos
//
//  Created by Tyler Torres on 4/23/23.
//

import Foundation
import AVFoundation
import Speech


class AudioBox : NSObject, ObservableObject {
    
    /// Different ways to get recording of audio
    ///     1. AVAudioRecorder - pre-recorded
    ///     2. AVAudioEngine - live buffer

    @Published var status: AudioStatus = .stopped
    @Published var transcript : String = "TEST"
    
    var audioRecorder : AVAudioRecorder?
    var audioEngine : AVAudioEngine?
    
    /// Speech Recognition Properties
    var speechRecognizer : SFSpeechRecognizer?
    var recognitionRequest : SFSpeechURLRecognitionRequest?
    
    
    var urlForRecording : URL {
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory
        let filePath = "tempRec.caf"
        
        return tempDir.appendingPathComponent(filePath)
    }
    
    
    func setupRecorder() {
        let recordSettings : [String : Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: urlForRecording, settings: recordSettings)
            audioRecorder?.delegate = self
            
            print("Recorder setup")
        } catch {
            print("Error setting up recorder with error : \(error.localizedDescription)")
        }
        
    }
    
    func startRecording() {
        setupRecorder()
        audioRecorder?.record()
        status = .recording
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        status = .stopped
    }
    
    
    //---- Speech Recognition Methods ----\\
    
    func setupSpeechRecognizer() {
        guard let recognizer = SFSpeechRecognizer(locale: .current) else { return }
        recognizer.supportsOnDeviceRecognition = true
        
        speechRecognizer = recognizer
    }
    
    func setupRecognitionRequest() {
        let request = SFSpeechURLRecognitionRequest(url: urlForRecording)
        request.requiresOnDeviceRecognition = true
        request.addsPunctuation = true
        
        recognitionRequest = request
    }
    
    func transcribeAudioFile() {
        // 1. Setup Speech Recognizer
        // 2. Setup Recognition Request
        // 3. Transcribe
        
        setupSpeechRecognizer()
        
        guard
            let speechRecognizer,
            speechRecognizer.isAvailable else {
            transcript = "Speech recognizer is unavailable"
            return
        }
        
        setupRecognitionRequest()
        
        guard let recognitionRequest else {
            transcript = "Recognition request isnt available"
            return
        }
        
        let task = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self else { return }
            
            if let result = result {
                
                let isTranscriptionComplete = result.isFinal
                
                if isTranscriptionComplete {
                    let speechText = result.bestTranscription.formattedString
                    print(speechText)
                    self.transcript = speechText
                } else {
                    print("Transcription incomplete")
                }
                
            }
            
        }
        
    }
    
    func requestSpeech() {
        SFSpeechRecognizer.requestAuthorization { _ in }
    }
    
    func requestMicrophone(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission(completion)
    }
    
}

extension AudioBox : AVAudioRecorderDelegate {
    
}
