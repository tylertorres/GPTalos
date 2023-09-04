//
//  AudioAgent.swift
//  talos
//
//  Created by Tyler Torres on 4/23/23.
//

import Foundation
import AVFoundation
import Speech

// Class Transcriber
/// Strictly in charge of transcribing an audio file at a given url


class SpeechRecognizer : NSObject, ObservableObject {
    /// Different ways to get recording of audio
    ///     1. AVAudioRecorder - pre-recorded
    ///     2. AVAudioEngine - live buffer
    
    @Published var status: AudioStatus = .stopped
    @Published var transcript : String = "Tap anywhere to start recording..."
    @Published var hasMicAccess = false
    
    private var openAIClient : OpenAIClient = OpenAIClient.shared
    private let transcriber = Transcriber()
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    var audioRecorder : AVAudioRecorder?
    var audioEngine : AVAudioEngine?
    var audioPlayer : AVAudioPlayer?
    
    /// Speech Recognition Properties
    var speechRecognizer : SFSpeechRecognizer?
    var recognitionRequest : SFSpeechURLRecognitionRequest?
    
    var urlForRecording : URL {
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory
        let filePath = "audio.m4a"
        
        return tempDir.appendingPathComponent(filePath)
    }
    
    
    func setupRecorder() {
        
        let recordSettings : [String : Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: urlForRecording, settings: recordSettings)
            //            audioRecorder?.delegate = self
            
            print("Recorder setup")
        } catch {
            print("Error setting up recorder with error : \(error.localizedDescription)")
        }
    }
    
    func startRecording() {
        if audioRecorder == nil {
            print("\nCreating recorder...")
            setupRecorder()
        }
        audioRecorder?.record()
        status = .recording
        
        transcript = "Listening..."
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
    
    func transcribeAudioFile() async {
        let newTranscript = await transcriber.transcribe()
        
        do {
            let response = try await openAIClient.createChatCompletion(prompt: newTranscript, temperature: 0.5)
            
            // play response
            await speakUsingGoogleTTS(with: response)
            
            DispatchQueue.main.async {
                self.transcript = response
            }
            
        } catch {
            print(error.localizedDescription)
        }
        
        // Cleanup of the intermediate audio recording
        FileUtils.deleteAudioFile()
    }
    
    private func speakUsingGoogleTTS(with text: String) async {
        let googleManager = GoogleTTSManager.shared
        
        let audioContent = await googleManager.callTTS(with: text)
        
        guard !audioContent.isEmpty,
              let audioData = Data(base64Encoded: audioContent, options: .ignoreUnknownCharacters) else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(data: audioData)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Error: \(error.localizedDescription)")
            
        }
    }
    
    func speak() {
        let zoeVoiceId = "com.apple.voice.enhanced.en-US.Zoe"
        
        let utterance = AVSpeechUtterance(string: transcript)
        utterance.voice = AVSpeechSynthesisVoice(identifier: zoeVoiceId)
        utterance.rate = 0.5 // default
        
        speechSynthesizer.speak(utterance)
    }
    
    //    func transcribeAudioFile() async {
    //        // 1. Setup Speech Recognizer
    //        // 2. Setup Recognition Request
    //        // 3. Transcribe
    //
    //        setupSpeechRecognizer()
    //
    //        guard
    //            let speechRecognizer,
    //            speechRecognizer.isAvailable else {
    //            transcript = "Speech recognizer is unavailable"
    //            return
    //        }
    //
    //        setupRecognitionRequest()
    //
    //        guard let recognitionRequest else {
    //            transcript = "Recognition request isnt available"
    //            return
    //        }
    //
    //        let task = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
    //            guard let self else { return }
    //
    //            if let result = result {
    //
    //                let isTranscriptionComplete = result.isFinal
    //
    //                if isTranscriptionComplete {
    //                    let speechText = result.bestTranscription.formattedString
    //                    print(speechText)
    //                    self.transcript = speechText
    //                } else {
    //                    print("Transcription incomplete")
    //                }
    //
    //            }
    //
    //        }
    //    }
    
    
    // Permissions Requesting
    
//    func requestPermissions() {
//        requestSpeech()
//        requestMicrophone(completion: <#T##(Bool) -> Void#>)
//
//    }
    
    func requestSpeech() {
        SFSpeechRecognizer.requestAuthorization { _ in }
    }
    
    func requestMicrophone(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission(completion)
    }
    
}


extension SpeechRecognizer : AVAudioRecorderDelegate {}

