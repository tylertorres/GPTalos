//
//  AudioTestView.swift
//  talos
//
//  Created by Tyler Torres on 4/23/23.
//

import SwiftUI
import AVFAudio

struct AudioTestView: View {
    
    @ObservedObject private var audioBox = AudioBox()
    
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
        }
        .padding()
        .onAppear {
            requestMicrophoneAccess()
            audioBox.setupRecorder()
        }
        .alert(isPresented: $displayPermissionAccessAlert) {
            Alert(
                title: Text("Requires Microphone Access"),
                message: Text("Go to Settings > TALOS > Allow TALOS to Access Microphone"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func requestMicrophoneAccess() {
        
        print("In request access")
        
        AVAudioSession.sharedInstance().requestRecordPermission { grantedAccess in
            hasAccess = grantedAccess
            if !grantedAccess {
                displayPermissionAccessAlert = true
            }
        }
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
    }
    
}
