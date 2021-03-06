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
        case RequestError
        case HTTPError(code: Int, message: String)
    }
    
    var errorMessage: String {
        switch(self.errorType) {
        case .URLParseError(let url):
            return "Failed to parse the given URL: \(url)"
        case .RequestError:
            return "There was an error sending the request"
        case .HTTPError(let code, let message):
            return "\(code) Error: \(message)"
        }
    }
}

extension APIClientError: LocalizedError {}

typealias jsonResponse = [String: Any]

class APIClient {
    static var currentClient: APIClient?
    var urlSession: URLSession
    var userSession: String?
    var userKey: Int?
    
    private init() {
        self.urlSession = URLSession.shared
    }
    
    // shared API client
    static var sharedClient: APIClient {
        if let currentClient = currentClient {
            return currentClient
        } else {
            currentClient = APIClient()
            return currentClient!
        }
    }
    
    // MARK: Generic Data Task Methods
    // getUrlRequest
    // Gets the URLRequest object
    func getUrlRequest(endpoint: apiEndpoints, requestBody: Data?) throws -> URLRequest {
        let requestUrlComponents = endpoint.requestUrl
        
        // Make sure it's a valid URL
        guard let requestUrlComponents = requestUrlComponents, let url = requestUrlComponents.url else {
            throw APIClientError(errorType: .URLParseError(url: "\(baseAPIUrl)\(endpoint.baseEndpoint)"))
        }
        
        // Create the URL Request
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
        
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let userSession = self.userSession {
            urlRequest.addValue(userSession, forHTTPHeaderField: "Authorization")
        }
        
        if let requestBody = requestBody {
            urlRequest.httpBody = requestBody
        }
        
        return urlRequest
    }
    
    // executeDataTask
    // Executes a network request
    func executeDataTask(url: URLRequest, successHandler: @escaping (Data) -> Void, errorHandler: @escaping (String) -> Void) {
        let getTask = self.urlSession.dataTask(with: url) { (data, response, error) in
            // Check there's been no internal error and we got back an HTTP response
            guard error == nil, let httpResponse = response as? HTTPURLResponse else {
                let errorStr = self.getErrorData(responseData: data, error: error, code: nil)
                errorHandler(errorStr)
                return
            }
            
            // Check we got back a success HTTP status code
            guard (200...399).contains(httpResponse.statusCode) else {
                let errorStr = self.getErrorData(responseData: data, error: error, code: httpResponse.statusCode)
                errorHandler(errorStr)
                return
            }
            
            // If all went well, return the data
            if let data = data {
                successHandler(data)
            }
        }
        getTask.resume()
    }
    
    // createAndExecuteTask
    // Shortcut method for creating the URLRequest for the data task and executing it
    func createAndExecuteTask(endpoint: apiEndpoints, requestBody: Data?, successHandler: @escaping (Data) -> Void, errorHandler: @escaping (String) -> Void) {
        do {
            let urlRequest = try self.getUrlRequest(endpoint: endpoint, requestBody: requestBody)
            self.executeDataTask(url: urlRequest, successHandler: successHandler, errorHandler: errorHandler)
        } catch {
            let errorMessage = (error as? APIClientError)?.errorMessage ?? error.localizedDescription
            errorHandler(errorMessage)
        }
    }
    
    // getErrorData
    // Gets the string describing the error
    func getErrorData(responseData: Data?, error: Error?, code: Int?) -> String {
        var errorResponse: String
        
        // if it's an internal error
        if let error = error {
            errorResponse = error.localizedDescription
        // if it's a non-200/300 status code
        } else if let responseData = responseData {
            do {
                let response = try JSONSerialization.jsonObject(with: responseData.subdata(in: 5..<responseData.count), options: []) as! [String: Any]
                let externalServerResponse = response["error"] as! String
                errorResponse = APIClientError(errorType: .HTTPError(code: code ?? 0, message: externalServerResponse)).errorMessage
            } catch {
                errorResponse = "There was a problem handling the remote server's response"
            }
        // otherwise
        } else {
            errorResponse = "An unknown error occurred"
        }
        
        return errorResponse
    }
    
    // parseJsonResponse
    // Parses the response data and return the JSON
    func parseJsonResponse(responseData: Data, errorHandler: (String) -> Void) -> jsonResponse? {
        do {
            let response = try JSONSerialization.jsonObject(with: responseData, options: []) as! jsonResponse
            return response
        } catch {
            errorHandler(error.localizedDescription)
            return nil
        }
    }
}
