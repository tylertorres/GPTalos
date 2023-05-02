//
//  HomeView.swift
//  talos
//
//  Created by Tyler Torres on 4/30/23.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject private var speechRecognizer = SpeechRecognizer()
    
    @State private var isRecording : Bool = false
    @State private var hasAccess : Bool = false
    @State private var color : Color = Color(hex: "#006400")
    @State private var animate : Bool = false
    
    var body: some View {
        
        NavigationStack {
            
            ZStack {
                
                color.edgesIgnoringSafeArea(.all)
                    .cornerRadius(20)
                
                Button(
                    action: {
                        Task { await onTapped() }
                    }) {
                        
                        VStack {
                            
                            Text(speechRecognizer.transcript)
                                .font(.title)
                                .foregroundColor(.white)
                                .padding(.top, 50)
                            
                            Button(
                                action: {
                                    speak()
                                },
                                label: {
                                    Text("Speak")
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.secondary)
                                        .cornerRadius(15)
                                        .padding()
                                })
                            
                            Spacer()
                            
                            HStack {
                                
                                Image("twitter")
                                    .resizable()
                                    .foregroundColor(Color.black)
                                    .frame(width: 30, height: 30)
                                    .colorInvert()
                                
                            }.padding()
                            
                            Divider()
                                .background(Color.white)
                                .frame(width: 100, height: 1)
                            
                        }
                        .padding()
                    }
                
            }
            .opacity(animate ? 0.8 : 1.0)
            .padding(.init(top: 20, leading: 20, bottom: 0, trailing: 20))
            .shadow(radius: 15)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(
                        action: {},
                        label: {
                            Image(systemName: "mic")
                                .bold()
                                .foregroundColor(.green)
                        }
                    )
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Quotes")
                        .font(.largeTitle)
                        .bold()
                }
            }
            .onAppear {
                requestAllPermissions()
            }

        }
    }
    
    private func speak() {
//        speechRecognizer.writeToFile()
        
    }
    
    private func onTapped() async {
        if !isRecording {
            isRecording = true
            withAnimation(.easeInOut(duration: 0.5)) {
                animate = true
            }

            speechRecognizer.startRecording()
        } else {
            isRecording = false

            speechRecognizer.stopRecording()
            await speechRecognizer.transcribeAudioFile()

            withAnimation(.easeInOut(duration: 0.5)) {
                animate = false
            }
        }
    }
    private func requestAllPermissions() {
        requestMicrophoneAccess()
        requestSpeechAccess()
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
    
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
