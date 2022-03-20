//
//  APIClient.swift
//  onthemap
//
//  Created by Shir Bar Lev on 06/03/2022.
//

import Foundation

// API Client Error type
struct APIClientError: Error {
    let errorType: ErrorType
    
    enum ErrorType {
        case URLParseError(url: String)
    }
    
    var errorMessage: String {
        switch(self.errorType) {
        case .URLParseError(let url):
            return "Failed to parse the given URL: \(url)"
        }
    }
}

extension APIClientError: LocalizedError {}

class APIClient {
    // getUrlRequest
    // Gets the URLRequest object
    func getUrlRequest(endpoint: apiEndpoints) throws -> URLRequest {
        let requestUrlComponents = endpoint.requestUrl
        
        // encode the URL and make sure it's a valid one
        if let requestUrlComponents = requestUrlComponents, let url = requestUrlComponents.url {
            var urlRequest = URLRequest(url: url)
            
            // Set the HTTP method according to the request type
            switch(endpoint) {
            case .LogIn, .CreateStudentLocation:
                urlRequest.httpMethod = "POST"
            case .LogOut:
                urlRequest.httpMethod = "DELETE"
            case .UpdateLocation:
                urlRequest.httpMethod = "PUT"
            default:
                urlRequest.httpMethod = "GET"
            }
            
            return urlRequest
        } else {
            throw APIClientError(errorType: .URLParseError(url: "\(baseAPIUrl)\(endpoint.baseEndpoint)"))
        }
    }
}
