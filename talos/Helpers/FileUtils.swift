//
//  HelperFunc.swift
//  talos
//
//  Created by Tyler Torres on 4/29/23.
//

import Foundation



struct FileUtils {
    
    static func getTemporaryDirectory() -> URL {
        let fileManager = FileManager.default
        let tempDirectoryUrl = fileManager.temporaryDirectory
        return tempDirectoryUrl
    }
    
    
    static func deleteAudioFile() {
        let fileManager = FileManager.default
        
        do {
            try fileManager.removeItem(at: getTemporaryDirectory().appendingPathComponent(Constants.AUDIO_FILENAME))
        } catch {
            print("Error occurred when trying to remove \(Constants.AUDIO_FILENAME)")
            print(error.localizedDescription)
        }
    }

    
}

