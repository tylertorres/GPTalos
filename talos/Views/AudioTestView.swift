//
//  AudioTestView.swift
//  talos
//
//  Created by Tyler Torres on 4/23/23.
//

import SwiftUI
import AVFAudio

struct AudioTestView: View {
    
    @StateObject private var audioBox = AudioBox()
    
    @State private var hasAccess = false
    @State private var displayPermissionAccessAlert = false
    
    var body: some View {
        VStack {
            Button(
                action: { configureAndRecord() },
                label: {
                    Text("Start Recording")
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(15)
                })
            
            Divider().padding()
            
            Button(
                action: { stop() },
                label: {
                    Text("Stop Recording")
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(15)
                })
            
            Divider().padding()
            
            Image(systemName: isRecording() ? "mic" : "mic.slash")
                .font(.title)
                .foregroundColor(Color.blue)
                .padding()
            
            Text(audioBox.transcript)
                .font(.body)
                .foregroundColor(.black)
                .padding()
            
            
            
            
            
        }
        .padding()
        .onAppear {
            requestAllPermissions()
        }
        .alert(isPresented: $displayPermissionAccessAlert) {
            Alert(
                title: Text("Requires Microphone Access"),
                message: Text("Go to Settings > TALOS > Allow TALOS to Access Microphone"),
                dismissButton: .default(Text("OK"))
            )
        }
        .background(Color.white)
    }
    
    private func isRecording() -> Bool {
        return audioBox.status == .recording
    }
    
    private func configureAndRecord() {
        let isRecording = audioBox.status == .recording
        
        if isRecording {
            print("Stopping current recording")
            audioBox.stopRecording()
        }
        
        print("Starting to record...")
        
        hasAccess
        ? audioBox.startRecording()
        : requestMicrophoneAccess()
    }
    
    private func stop() {
        print("Stopping recording...")
        
        audioBox.stopRecording()
        
        print("\nTranscribing from file")
        
        audioBox.transcribeAudioFile()
    }
    
    private func requestSpeechAccess() {
        print("In request speech access")
        audioBox.requestSpeech();
    }
    
    private func requestMicrophoneAccess() {
        print("In request microphone access")
        audioBox.requestMicrophone { granted in
            guard granted else {
                print("Mic access denied")
                return
            }
            hasAccess = granted
        }
    }
    
    private func requestAllPermissions() {
        requestMicrophoneAccess()
        requestSpeechAccess()
    }
    
}
