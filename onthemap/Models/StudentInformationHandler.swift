//
//  StudentInformationHandler.swift
//  onthemap
//
//  Created by Shir Bar Lev on 26/03/2022.
//

import Foundation

class StudentInformationHandler {
    static var sharedHandler = StudentInformationHandler()
    var studentLocations: [StudentInformation]?
    
    private init() { }
    
    // createUserURLFromAnnotation
    // Creates a URL object from the URL String in the StudentLocations array
    func createUserURLFromAnnotation(urlStr: String?) -> URL? {
        if let urlStr = urlStr {
            let userURL = URL(string: urlStr)
            
            if let userURL = userURL {
                return userURL
            }
        }
        
        return nil
    }
}
