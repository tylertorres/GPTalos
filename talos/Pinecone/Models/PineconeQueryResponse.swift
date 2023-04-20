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
    let metadata: Metadata?
}

struct SparseValues: Codable {
    let indices: [Int]
    let values: [Double]
}

struct Metadata: Codable {
    let genre: String
    let year: Int
}
