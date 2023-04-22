//
//  PineconeQueryResponse.swift
//  talos
//
//  Created by Tyler Torres on 4/20/23.
//

import Foundation

struct PineconeQueryResponse: Codable {
    let matches: [Match]
    let namespace: String
}

struct Match: Codable {
    let id: String
    let score: Double
    let values: [Double]
    let sparseValues: SparseValues?
    let metadata: [String : AnyCodable]?
    
    private enum CodingKeys: String, CodingKey {
        case id, score, values, sparseValues, metadata
    }

}

struct SparseValues: Codable {
    let indices: [Int]
    let values: [Double]
}
