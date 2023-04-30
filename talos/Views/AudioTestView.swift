//
//  AudioTestView.swift
//  talos
//
//  Created by Tyler Torres on 4/23/23.
//

import SwiftUI
import AVFAudio

struct AudioTestView: View {
    
    @StateObject private var speechRecognizer = SpeechRecognizer()
    
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
                action: {
                    Task {
                        await stop()
                    }
                },
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
            
            Text(speechRecognizer.transcript)
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
        return speechRecognizer.status == .recording
    }
    
    private func configureAndRecord() {
        let isRecording = speechRecognizer.status == .recording
        
        if isRecording {
            print("Stopping current recording")
            speechRecognizer.stopRecording()
        }
        
        print("Starting to record...")
        
        hasAccess
        ? speechRecognizer.startRecording()
        : requestMicrophoneAccess()
    }
    
    private func stop() async {
        print("Stopping recording...")
        
        speechRecognizer.stopRecording()
        
        print("\nTranscribing from file")
        
        await speechRecognizer.transcribeAudioFile()
    }
    
    private func requestSpeechAccess() {
        print("In request speech access")
        speechRecognizer.requestSpeech();
    }
    
    private func requestMicrophoneAccess() {
        print("In request microphone access")
        speechRecognizer.requestMicrophone { granted in
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
