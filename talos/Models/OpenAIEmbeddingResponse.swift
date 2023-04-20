//
//  OpenAIEmbeddingResponse.swift
//  talos
//
//  Created by Tyler Torres on 4/19/23.
//

import Foundation


struct OpenAIEmbeddingResponse: Codable {
    let data : [EmbeddingResponse]
    let model : String
    let usage : Usage
}

struct EmbeddingResponse : Codable {
    let embedding : Embedding
}


struct Usage : Codable {
    let prompt_tokens : Int
    let total_tokens : Int
}
