//
//  OnTheMapHandler.swift
//  onthemap
//
//  Created by Shir Bar Lev on 26/03/2022.
//

import Foundation

class OnTheMapHandler {
    static var sharedHandler = OnTheMapHandler()
    var studentLocations: [StudentInformation]?
    var currentUser: CurrentUser?
    let apiClient = APIClient.sharedClient
    
    private init() { }
    
    // MARK: StudentLocation Methods
    // fetchStudentLocations
    // Fetches student locations from the server
    func fetchStudentLocations(successCallback: @escaping ([StudentInformation]) -> Void, errorCallback: @escaping (String) -> Void) {
        // Fetch student locations from the API
        self.apiClient.createAndExecuteTask(endpoint: .GetStudentLocation(limit: nil, skip: nil, order: "-updatedAt", uniqueKey: nil), requestBody: nil, successHandler: { responseData in
            // otherwise try to decode the data to an object
            do {
                let studentLocations = try JSONDecoder().decode(StudentInformationArray.self, from: responseData)

                self.studentLocations = studentLocations.results
                successCallback(studentLocations.results)
            // if there's a problem, alert the user
            } catch {
                errorCallback(error.localizedDescription)
            }
        }, errorHandler: errorCallback)
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
    
    // MARK: CurrentUser Methods
    func getUserData(userKey: Int, errorHandler: @escaping (String) -> Void) {
        self.apiClient.createAndExecuteTask(endpoint: .GetUser(id: userKey), requestBody: nil, successHandler: { responseData in
            let response = self.apiClient.parseJsonResponse(responseData: responseData.subdata(in: 5..<responseData.count), errorHandler: errorHandler)
            
            self.currentUser = CurrentUser(userSession: self.apiClient.userSession!, userKey: userKey, userFirstName: response?["first_name"] as! String, userLastName: response?["last_name"] as! String)
        }, errorHandler: errorHandler)
    }
}
