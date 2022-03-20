//
//  APIEndpoints.swift
//  onthemap
//
//  Created by Shir Bar Lev on 20/03/2022.
//

import Foundation

// API Endpoints
enum apiEndpoints {
    case Auth
    case GetUser(id: Int)
    case GetStudentLocation(limit: Int?, skip: Int?, order: String?, uniqueKey: String?)
    case CreateStudentLocation
    case UpdateLocation(id: String)
}

// Returns the raw endpoint value
extension apiEndpoints {
    var endpoint: String {
        switch(self) {
        // Authentication endpoint
        case .Auth:
            return "/session"
        // Getting a user
        case .GetUser(let id):
            return "/users/\(id)"
        // Getting a location
        case .GetStudentLocation(let limit, let skip, let order, let uniqueKey):
            let endpointBase = "/StudentLocation"
            var queryParams: String = ""
            
            // add each query param that exists
            if let limit = limit {
                queryParams += "limit=\(String(limit))&"
            }
            
            if let skip = skip {
                queryParams += "skip=\(String(skip))&"
            }
            
            if let order = order {
                queryParams += "order=\(order)&"
            }
            
            if let uniqueKey = uniqueKey {
                queryParams += "uniqueKey=\(uniqueKey)"
            }
            
            if(queryParams.count > 0) {
                return "\(endpointBase)?\(queryParams)"
            } else {
                return endpointBase
            }
        // Creating a location
        case .CreateStudentLocation:
            return "/StudentLocation"
        // Updating a location
        case .UpdateLocation(let id):
            return "/StudentLocation/\(id)"
        }
    }
}
