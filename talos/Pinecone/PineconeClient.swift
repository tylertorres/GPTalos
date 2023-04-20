//
//  PineconeClient.swift
//  talos
//
//  Created by Tyler Torres on 4/19/23.
//

import Foundation

enum PineconeError: Error {
    case invalidURL
    case unexpectedResponse
}

struct CreateIndexParameters : Codable {
    let name : String
    let dimension : Int
    let metric: String
    let pods: Int
    let replicas: Int
    let pod_type: String
}


class PineconeClient {
    
    static let shared = PineconeClient()
    
    private let apiKey : String
    private let environment : String
    
    private var baseUrl : String = ""
    
    
    private init() {
        self.apiKey = ProcessInfo.processInfo.environment["PINECONE_API_KEY"]!
        self.environment = ProcessInfo.processInfo.environment["PINECONE_ENV"]!
        self.baseUrl = "https://controller.\(self.environment).pinecone.io/databases"
    }
    
    //---- Create Index Flow ----\\
    
    func createIndex(parameters: CreateIndexParameters, completion: @escaping (Result<HTTPURLResponse, Error>) -> Void) {
            
        var request = buildCreateIndexRequest()
        
        do {
            request.httpBody = try JSONEncoder().encode(parameters)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(error?.localizedDescription ?? "No data returned")
                return
            }
            
            if let error = error {
                completion(.failure(error))
            } else if let httpResponse = response as? HTTPURLResponse {
                completion(.success(httpResponse))
            } else {
                completion(.failure(PineconeError.unexpectedResponse))
            }
        }.resume()
            
    }
    
    private func buildCreateIndexRequest() -> URLRequest {
        
        let urlString = "https://controller.\(self.environment).pinecone.io/databases"
        
        var pineconeRequest = URLRequest(url: URL(string: urlString)!)
        
        pineconeRequest.httpMethod = "POST"
        pineconeRequest.allHTTPHeaderFields = [
            "accept": "text/plain",
            "content-type": "application/json",
            "Api-Key": self.apiKey
        ]
        
        return pineconeRequest
    }
    
    func listIndexes() {
        
        let pineconeRequest = buildListIndexesRequest()
        
        URLSession.shared.dataTask(with: pineconeRequest) { data, response, error in
            guard let data = data else {
                print(error?.localizedDescription ?? "No data returned")
                return
            }
            
            do {
                let indices = try JSONDecoder().decode([String].self, from: data)
                print(indices)
                
            } catch {
                print(error)
            }


        }.resume()

    }
    
    private func buildListIndexesRequest() -> URLRequest {
        
        let urlString = "https://controller.\(self.environment).pinecone.io/databases"

        var pineconeRequest = URLRequest(url: URL(string: urlString)!)
        pineconeRequest.allHTTPHeaderFields = buildPineconeHeaders()
        pineconeRequest.httpMethod = "GET"
        
        return pineconeRequest
    }
    
    private func buildPineconeHeaders() -> [String : String] {
        return [
            "Api-Key": apiKey,
            "accept": "application/json; charset=utf-8"
        ]
    }
    
    func deleteIndex(indexName: String, completion: @escaping(Result<HTTPURLResponse, Error>) -> Void) {
        
        let request = buildDeleteIndexRequest(indexName: indexName)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(error?.localizedDescription ?? "No data returned")
                return
            }
            
            if let error = error {
                completion(.failure(error))
            } else if let httpResponse = response as? HTTPURLResponse {
                completion(.success(httpResponse))
            } else {
                completion(.failure(PineconeError.unexpectedResponse))
            }
        }.resume()
        
    }
    
    private func buildDeleteIndexRequest(indexName: String) -> URLRequest {
        
        let urlString = baseUrl + "/\(indexName)"
        
        var request = URLRequest(url: URL(string: urlString)!)
        
        request.httpMethod = "DELETE"
        request.allHTTPHeaderFields = [
            "accept": "text/plain",
            "Api-Key": apiKey
        ]
        
        return request
    }
    
}
