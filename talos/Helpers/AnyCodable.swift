//
//  AnyCodable.swift
//  talos
//
//  Created by Tyler Torres on 4/21/23.
//

import Foundation


struct AnyCodable: Codable {
    private let value: Codable
    
    init(_ value: Codable) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let intValue = try? container.decode(Int.self) {
            self.init(intValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            self.init(doubleValue)
        } else if let stringValue = try? container.decode(String.self) {
            self.init(stringValue)
        } else if let arrayValue = try? container.decode([AnyCodable].self) {
            self.init(arrayValue)
        } else if let dictionaryValue = try? container.decode([String: AnyCodable].self) {
            self.init(dictionaryValue)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable value cannot be decoded")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        try value.encode(to: encoder)
        
        switch value {
        case let intValue as Int:
            try container.encode(intValue)
        case let doubleValue as Double:
            try container.encode(doubleValue)
        case let stringValue as String:
            try container.encode(stringValue)
        case let arrayValue as [AnyCodable]:
            try container.encode(arrayValue)
        case let dictionaryValue as [String: AnyCodable]:
            try container.encode(dictionaryValue)
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: container.codingPath, debugDescription: "AnyCodable value cannot be encoded"))
        }
    }
}
