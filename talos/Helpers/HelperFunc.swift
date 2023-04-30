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

    
}

