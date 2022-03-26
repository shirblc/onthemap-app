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
    let apiClient = APIClient.sharedClient
    
    private init() { }
    
    // fetchStudentLocations
    // Fetches student locations from the server
    func fetchStudentLocations(successCallback: @escaping ([StudentInformation]) -> Void, errorCallback: @escaping (String) -> Void) {
        do {
            // Fetch student locations from the API
            let urlRequest = try self.apiClient.getUrlRequest(endpoint: .GetStudentLocation(limit: nil, skip: nil, order: "-updatedAt", uniqueKey: nil))
            self.apiClient.executeDataTask(url: urlRequest) { responseData, errorStr in
                // if there was an error, alert the user
                guard errorStr == nil, let responseData = responseData else {
                    errorCallback(errorStr!)
                    return
                }

                // otherwise try to decode the data to an object
                do {
                    let studentLocations = try JSONDecoder().decode(StudentInformationArray.self, from: responseData)

                    self.studentLocations = studentLocations.results
                    successCallback(studentLocations.results)
                // if there's a problem, alert the user
                } catch {
                    errorCallback(error.localizedDescription)
                }
            }
        } catch {
            errorCallback(error.localizedDescription)
        }
    }
    
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
