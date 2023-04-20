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
    case jsonSerializationError(Error)
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
    private var indexOpsBaseUrl : String
    private let projectId : String
    
    
    private init() {
        self.apiKey = ProcessInfo.processInfo.environment["PINECONE_API_KEY"]!
        self.environment = ProcessInfo.processInfo.environment["PINECONE_ENV"]!
        self.projectId = ProcessInfo.processInfo.environment["PINECONE_PROJECT_ID"]!
        
        self.indexOpsBaseUrl = "https://controller.\(self.environment).pinecone.io/databases"
        
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
    
    //---- List Index Flow ----\\
    
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
    
    //---- Delete Index Flow ----\\
    
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
        
        let urlString = indexOpsBaseUrl + "/\(indexName)"
        
        var request = URLRequest(url: URL(string: urlString)!)
        
        request.httpMethod = "DELETE"
        request.allHTTPHeaderFields = [
            "accept": "text/plain",
            "Api-Key": apiKey
        ]
        
        return request
    }
    
    
    //----- Vector Operations -----\\
    
    
    struct QueryIndexParameters : Codable {
        let vector: Embedding
        let topK : Int
        let includeMetadata : Bool
        let namespace : String
    }
    
    struct UpsertIndexParameters : Codable {
        let vectors : [UpsertRequest]
        let namespace : String
    
    }
    
    struct UpsertRequest : Codable {
        let id : String
        let values : Embedding
        let metadata: [String : String]
    }
    
    // you would have to encode before the request ; we dont want this
    // TODO: Try to come up with a better idea after first pass through
    
    
    // Query
    func query(vector: Embedding,
               topK: Int,
               includeMetadata: Bool,
               namespace: String,
               indexName: String,
               completion: @escaping(Result<PineconeQueryResponse, Error>) -> Void
     ) {
        
        // Generate query embeddings
            // Take in input and send to openai to generate embeddings
            // store query embeddings
        // Send pinecone query request
        
        let queryUrl = "https://\(indexName)-\(projectId).svc.\(environment).pinecone.io"
        
        let endpointUrl = URL(string: queryUrl)?.appendingPathComponent("/query")

        var queryRequest = URLRequest(url: endpointUrl!)
        queryRequest.httpMethod = "POST"
        queryRequest.allHTTPHeaderFields = [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Api-Key": apiKey
        ]
        
        let parameters = QueryIndexParameters(vector: vector, topK: topK, includeMetadata: includeMetadata, namespace: namespace)
        
        do {
            queryRequest.httpBody = try JSONEncoder().encode(parameters)
        } catch {
            print(error)
        }
        
        URLSession.shared.dataTask(with: queryRequest) { data, response, error in
            guard let data = data else { return completion(.failure("No data found" as! Error))}
            
            let decoder = JSONDecoder()
            
            do {
                let decoded = try decoder.decode(PineconeQueryResponse.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
            
            
            
            
            
        }.resume()
        
        
        
        
        // comparing vector values and extracting metadata from that ,such as tasks, text, etc
    
        
        
        
        
        
        
        
    }
    
    private func buildQueryUrl(indexName: String) -> URL {
        
        let baseVectorOpsUrl = "https://\(indexName)-\(projectId).svc.\(environment).pinecone.io"
        
        let endpointUrl = URL(string: baseVectorOpsUrl)!.appendingPathComponent("/vectors/upsert")
        
        return endpointUrl
    }
    
    
    // Upsert
    func upsert(id : String,
                vector: Embedding,
                metadata: [String : String] = [:],
                namespace: String,
                index: String,
                completion: @escaping(Result<PineconeUpsertResponse, Error>) -> Void) { //TODO: Change later to not take in index
        
        var vectorToInsert = UpsertRequest(id: id, values: vector, metadata: metadata)
        
        var upsertRequest = buildUpsertRequest(index: index)
        
        let bodyParams = UpsertIndexParameters(vectors: [vectorToInsert], namespace: namespace)
        
        do {
            upsertRequest.httpBody = try JSONEncoder().encode(bodyParams) // Encoder used to turn dicts into json for body params
        } catch {
            completion(.failure(PineconeError.jsonSerializationError(error)))
        }
        
        URLSession.shared.dataTask(with: upsertRequest) { data, response, error in
            guard let data = data else {
                print("Error occurred with request")
                return
            }
            
            do {
                let upsertResponse = try JSONDecoder().decode(PineconeUpsertResponse.self, from: data)
                completion(.success(upsertResponse))
            } catch {
                completion(.failure(PineconeError.jsonSerializationError(error)))
            }
            
        }.resume()
        
    }
    
    private func buildUpsertRequest(index: String) -> URLRequest {
        
        let url = buildVectorOpsUrl(indexName: index)
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Api-Key": apiKey
        ]
        
        return request
    }
    
    private func buildVectorOpsUrl(indexName: String) -> URL {
        
        let baseVectorOpsUrl = "https://\(indexName)-\(projectId).svc.\(environment).pinecone.io"
        
        let endpointUrl = URL(string: baseVectorOpsUrl)!.appendingPathComponent("/vectors/upsert")
        
        return endpointUrl
    }
    
    //TODO:  Create an underlying Index Object so you dont have to keep passing in Index Name ( encapsulation )
    	
}
