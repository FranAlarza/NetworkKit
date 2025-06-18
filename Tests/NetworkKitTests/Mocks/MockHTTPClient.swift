//
//  MockHTTPClient.swift
//  NetworkKit
//
//  Created by Fran Alarza on 18/6/25.
//

import Foundation
import NetworkKit

final class MockHTTPClient: HTTPClientProtocol {
    var result: Result<Data, Error>?

    func send<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T {
        switch result {
        case .success(let data):
            return try JSONDecoder().decode(T.self, from: data)
        case .failure(let error):
            throw error
        case .none:
            fatalError("No result set on MockHTTPClient")
        }
    }
    
    func upload<T: Decodable>(_ endpoint: Endpoint, fileURL: URL, as type: T.Type) async throws -> T {
        switch result {
        case .success(let data):
            return try JSONDecoder().decode(T.self, from: data)
        case .failure(let error):
            throw error
        case .none:
            fatalError("No result set on MockHTTPClient")
        }
    }
    
    func download(_ endpoint: Endpoint, to destinationURL: URL) async throws {
        switch result {
        case .success(let data):
            try data.write(to: destinationURL)
        case .failure(let error):
            throw error
        case .none:
            fatalError("No result set on MockHTTPClient")
        }
    }
}
