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
            return "The given url is invalid: \(url)"
        }
    }
}

class APIClient {
    let apiBase = "https://onthemap-api.udacity.com/v1"
    
    // getUrlRequest
    // Gets the URLRequest object
    func getUrlRequest(endpoint: apiEndpoints) throws -> URLRequest {
        let strUrl = self.apiBase + endpoint.endpoint
        
        // encode the URL and make sure it's a valid one
        if let requestUrl = URL(string: strUrl) {
            return URLRequest(url: requestUrl)
        } else {
            throw APIClientError(errorType: .URLParseError(url: strUrl))
        }
    }
}
