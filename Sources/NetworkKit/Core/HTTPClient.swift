//
//  HTTPClient.swift
//  NetworkKit
//
//  Created by Fran Alarza on 18/6/25.
//

import Foundation

public protocol HTTPClientProtocol {
    func send<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T
    func upload<T: Decodable>(_ endpoint: Endpoint, fileURL: URL, as type: T.Type) async throws -> T
    func download(_ endpoint: Endpoint, to destinationURL: URL) async throws
}

public final class HTTPClient: HTTPClientProtocol {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func send<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T {
        guard var components = URLComponents(string: endpoint.path) else {
            throw NetworkError.invalidURL
        }

        components.queryItems = endpoint.queryItems

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers
        request.httpBody = endpoint.body

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.statusCode(httpResponse.statusCode)
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                return decoded
            } catch {
                throw NetworkError.decodingError(error)
            }
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
    
    public func upload<T: Decodable>(_ endpoint: Endpoint, fileURL: URL, as type: T.Type) async throws -> T {
        guard var components = URLComponents(string: endpoint.path) else {
            throw NetworkError.invalidURL
        }

        components.queryItems = endpoint.queryItems

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers

        do {
            let (data, response) = try await session.upload(for: request, fromFile: fileURL)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.statusCode(httpResponse.statusCode)
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                return decoded
            } catch {
                throw NetworkError.decodingError(error)
            }
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
    
    public func download(_ endpoint: Endpoint, to destinationURL: URL) async throws {
        guard var components = URLComponents(string: endpoint.path) else {
            throw NetworkError.invalidURL
        }

        components.queryItems = endpoint.queryItems

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.statusCode(httpResponse.statusCode)
            }

            try data.write(to: destinationURL)
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
}
