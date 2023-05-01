//
//  talosApp.swift
//  talos
//
//  Created by Tyler Torres on 4/19/23.
//

import SwiftUI
import AVFoundation

class AppDelegate : NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(.playAndRecord, options: .defaultToSpeaker )
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("AVAudioSession configuration error : \(error.localizedDescription)")
        }
            
        return true
    }
}

@main
struct talosApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.colorScheme, .light)
        }
    }
}
