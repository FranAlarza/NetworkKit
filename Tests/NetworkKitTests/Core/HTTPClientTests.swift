//
//  HTTPClientTests.swift
//  NetworkKit
//
//  Created by Fran Alarza on 18/6/25.
//

import XCTest
import Testing
import Foundation
@testable import NetworkKit

@Test func test_send_successfullyDecodesData() async throws {
    let mock = MockHTTPClient()
    let json = #"{"message":"Hello"}"#.data(using: .utf8)!
    mock.result = .success(json)

    struct TestResponse: Decodable, Equatable {
        let message: String
    }

    struct DummyEndpoint: Endpoint {
        var path: String = "https://example.com"
        var method: HTTPMethod = .get
        var headers: [String : String]? = nil
        var body: Data? = nil
        var queryItems: [URLQueryItem]? = nil
    }

    let result = try await mock.send(DummyEndpoint(), as: TestResponse.self)

    #expect(result == TestResponse(message: "Hello"))
}

@Test func test_send_throwsError() async {
    let mock = MockHTTPClient()
    mock.result = .failure(NetworkError.invalidResponse)

    struct Dummy: Decodable {}

    struct DummyEndpoint: Endpoint {
        var path: String = "https://example.com"
        var method: HTTPMethod = .get
        var headers: [String : String]? = nil
        var body: Data? = nil
        var queryItems: [URLQueryItem]? = nil
    }

    do {
        _ = try await mock.send(DummyEndpoint(), as: Dummy.self)
        XCTFail("Expected error to be thrown")
    } catch let error as NetworkError {
        if case .invalidResponse = error {
            // success
        } else {
            XCTFail("Expected .invalidResponse but got \(error)")
        }
    } catch {
        XCTFail("Unexpected error type: \(error)")
    }
}


@Test func test_upload_successfullyDecodesResponse() async throws {
    let mock = MockHTTPClient()
    let expectedResponse = UploadResponse(status: "ok")
    let json = try JSONEncoder().encode(expectedResponse)
    mock.result = .success(json)

    struct DummyEndpoint: Endpoint {
        var path: String = "https://example.com/upload"
        var method: HTTPMethod = .post
        var headers: [String : String]? = nil
        var body: Data? = nil
        var queryItems: [URLQueryItem]? = nil
    }

    struct UploadResponse: Codable, Equatable {
        let status: String
    }

    let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("dummy.txt")
    try "dummy data".write(to: fileURL, atomically: true, encoding: .utf8)

    let result = try await mock.upload(DummyEndpoint(), fileURL: fileURL, as: UploadResponse.self)
    #expect(result == expectedResponse)
}

@Test func test_upload_throwsError() async {
    let mock = MockHTTPClient()
    mock.result = .failure(NetworkError.invalidResponse)

    struct DummyEndpoint: Endpoint {
        var path: String = "https://example.com/upload"
        var method: HTTPMethod = .post
        var headers: [String : String]? = nil
        var body: Data? = nil
        var queryItems: [URLQueryItem]? = nil
    }

    struct UploadResponse: Decodable {}

    let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("dummy.txt")
    try? "dummy data".write(to: fileURL, atomically: true, encoding: .utf8)

    do {
        _ = try await mock.upload(DummyEndpoint(), fileURL: fileURL, as: UploadResponse.self)
        XCTFail("Expected error to be thrown")
    } catch let error as NetworkError {
        if case .invalidResponse = error {
            // success
        } else {
            XCTFail("Expected .invalidResponse but got \(error)")
        }
    } catch {
        XCTFail("Unexpected error type: \(error)")
    }
}

@Test func test_download_successfullyWritesFile() async throws {
    let mock = MockHTTPClient()
    let fileContents = "downloaded file content"
    let fileData = fileContents.data(using: .utf8)!
    mock.result = .success(fileData)

    struct DummyEndpoint: Endpoint {
        var path: String = "https://example.com/file"
        var method: HTTPMethod = .get
        var headers: [String : String]? = nil
        var body: Data? = nil
        var queryItems: [URLQueryItem]? = nil
    }

    let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try await mock.download(DummyEndpoint(), to: destinationURL)

    let downloadedContents = try String(contentsOf: destinationURL)
    #expect(downloadedContents == fileContents)
}

@Test func test_download_throwsError() async {
    let mock = MockHTTPClient()
    mock.result = .failure(NetworkError.invalidResponse)

    struct DummyEndpoint: Endpoint {
        var path: String = "https://example.com/file"
        var method: HTTPMethod = .get
        var headers: [String : String]? = nil
        var body: Data? = nil
        var queryItems: [URLQueryItem]? = nil
    }

    do {
        try await mock.download(DummyEndpoint(), to: FileManager.default.temporaryDirectory.appendingPathComponent("dummy.txt"))
        XCTFail("Expected error to be thrown")
    } catch let error as NetworkError {
        if case .invalidResponse = error {
            // success
        } else {
            XCTFail("Expected .invalidResponse but got \(error)")
        }
    } catch {
        XCTFail("Unexpected error type: \(error)")
    }
}
