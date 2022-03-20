//
//  APIEndpoints.swift
//  onthemap
//
//  Created by Shir Bar Lev on 20/03/2022.
//

import Foundation

let baseAPIUrl = "https://onthemap-api.udacity.com/v1"

// API Endpoints
enum apiEndpoints {
    case LogIn
    case LogOut
    case GetUser(id: Int)
    case GetStudentLocation(limit: Int?, skip: Int?, order: String?, uniqueKey: String?)
    case CreateStudentLocation
    case UpdateLocation(id: String)
}

// Returns the raw endpoint value
extension apiEndpoints {
    var baseEndpoint: String {
        switch(self) {
        // Authentication endpoint
        case .LogIn, .LogOut:
            return "/session"
        // Getting a user
        case .GetUser(let id):
            return "/users/\(id)"
        // Getting a location
        case .GetStudentLocation:
            return "/StudentLocation"
        // Creating a location
        case .CreateStudentLocation:
            return "/StudentLocation"
        // Updating a location
        case .UpdateLocation(let id):
            return "/StudentLocation/\(id)"
        }
    }
    
    var requestUrl: URLComponents? {
        switch(self) {
        // For GET /location, append the query params and then return the URLComponents
        case .GetStudentLocation(let limit, let skip, let order, let uniqueKey):
            let urlStr = "\(baseAPIUrl)\(self.baseEndpoint)"
            var url = URLComponents(string: urlStr)
            var queryItems: Array<URLQueryItem> = []
            
            // add each query param that exists
            if let limit = limit {
                queryItems.append(URLQueryItem(name: "limit", value: String(limit)))
            }
            
            if let skip = skip {
                queryItems.append(URLQueryItem(name: "skip", value: String(skip)))
            }
            
            if let order = order {
                queryItems.append(URLQueryItem(name: "order", value: order))
            }
            
            if let uniqueKey = uniqueKey {
                queryItems.append(URLQueryItem(name: "uniqueKey", value: uniqueKey))
            }
            
            url?.queryItems = queryItems
            
            return url
        // For everything else, just return the URLComponents
        default:
            let urlStr = "\(baseAPIUrl)\(self.baseEndpoint)"
            return URLComponents(string: urlStr)
        }
    }
}
