//
//  AudioAgent.swift
//  talos
//
//  Created by Tyler Torres on 4/23/23.
//

import Foundation
import AVFoundation
import Speech

class SpeechRecognizer: NSObject, ObservableObject {
    
    @Published var status: AudioStatus = .stopped
    
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    
    var urlForRecording: URL {
        return FileUtils.getTemporaryDirectory().appendingPathComponent(Constants.AUDIO_FILENAME)
    }
    
    override init() {
        super.init()
        setupRecorder()
    }
    
    func toggleRecording() {
        switch status {
        case .recording:
            stopRecording()
        default:
            startRecording()
        }
    }
    
    func startRecording() {
        audioRecorder?.record()
        status = .recording
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        status = .stopped
    }
    
    
    private func setupRecorder() {
        let recorderSettings : [String : Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: urlForRecording, settings: recorderSettings)
            print("Recorder setup")
        } catch {
            print("Error setting up recorder with error : \(error.localizedDescription)")
        }
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
    
    func requestSpeech() {
        SFSpeechRecognizer.requestAuthorization { _ in }
    }
    
    func requestMicrophone(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission(completion)
    }
    
}

extension SpeechRecognizer : AVAudioRecorderDelegate {}

