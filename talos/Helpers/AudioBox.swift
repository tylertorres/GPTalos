//
//  AudioAgent.swift
//  talos
//
//  Created by Tyler Torres on 4/23/23.
//

import Foundation
import AVFoundation



class AudioBox : NSObject, ObservableObject {
    
    /// Different ways to get recording of audio
    ///     1. AVAudioRecorder
    ///     2. AVAudioEngine

    @Published var status: AudioStatus = .stopped
    
    var audioRecorder : AVAudioRecorder?
    
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
        audioRecorder?.record()
        status = .recording
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        status = .stopped
    }
    
}

extension AudioBox : AVAudioRecorderDelegate {
    
}
