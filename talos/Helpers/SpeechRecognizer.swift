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
    
    func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { _ in }
        AVAudioSession.sharedInstance().requestRecordPermission { _ in }
    }
    
    func isAudioDataAvailable() -> Bool {
        return FileManager.default.fileExists(atPath: urlForRecording.path())
    }
    
    private func startRecording() {
        print("Started Recording...")
        audioRecorder?.record()
        status = .recording
    }
    
    private func stopRecording() {
        print("Stopped Recording...")
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
            audioRecorder?.delegate = self
        } catch {
            print("Failed to setup recorder : \(error.localizedDescription)")
        }
    }
}

extension SpeechRecognizer : AVAudioRecorderDelegate {}

