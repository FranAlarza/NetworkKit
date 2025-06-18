//
//  NetworkError.swift
//  NetworkKit
//
//  Created by Fran Alarza on 18/6/25.
//

import Foundation

public enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingError(Error)
    case statusCode(Int)
}
