//
//  NetworkSession.swift
//  AnalogProcess
//
//  Created by Maxim Eliseyev on 12.07.2025.
//

import Foundation

// MARK: - Network Session Protocol
public protocol NetworkSession {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

// MARK: - URLSession Extension
extension URLSession: NetworkSession {}

// MARK: - Mock Network Session for Testing
public class MockNetworkSession: NetworkSession {
    public var mockData: Data?
    public var mockResponse: URLResponse?
    public var mockError: Error?
    
    public init(mockData: Data? = nil, mockResponse: URLResponse? = nil, mockError: Error? = nil) {
        self.mockData = mockData
        self.mockResponse = mockResponse
        self.mockError = mockError
    }
    
    public func data(from url: URL) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }
        
        guard let data = mockData, let response = mockResponse else {
            throw NetworkError.invalidResponse
        }
        
        return (data, response)
    }
}

// MARK: - Network Errors
public enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError
    case serverError(Int)
    case noData
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError:
            return "Failed to decode response data"
        case .serverError(let code):
            return "Server error with code: \(code)"
        case .noData:
            return "No data received"
        }
    }
}
