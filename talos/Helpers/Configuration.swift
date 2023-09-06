//
//  Configuration.swift
//  talos
//
//  Created by Tyler Torres on 9/6/23.
//

import Foundation


enum Config {
    
    enum ConfigError: Error {
        case missingKey
    }
    
    static func getValue(for key: String) throws -> String {
        guard let infoDictionary = Bundle.main.infoDictionary,
              let value = infoDictionary[key] as? String else { throw ConfigError.missingKey }
        
        return value
    }
}
