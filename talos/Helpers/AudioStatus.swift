//
//  AudioStatus.swift
//  talos
//
//  Created by Tyler Torres on 4/23/23.
//

import Foundation

enum AudioStatus: Int, CustomStringConvertible {
    
    case stopped,
         recording
    
    var audioName: String {
        let audioNames = ["Audio:Stopped", "Audio:Recording"]
        return audioNames[rawValue]
    }
    
    var description: String {
        return audioName
    }
    
}
