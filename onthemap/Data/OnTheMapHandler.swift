//
//  OnTheMapHandler.swift
//  onthemap
//
//  Created by Shir Bar Lev on 26/03/2022.
//

import Foundation
import MapKit

class OnTheMapHandler {
    static var sharedHandler = OnTheMapHandler()
    var studentLocations: [StudentInformation]?
    var currentUser: CurrentUser?
    let apiClient = APIClient.sharedClient
    
    // the converts the data array to an annotation array
    var studentLocationsAnnotations: Array<MKPointAnnotation> {
        var locationAnnotations: Array<MKPointAnnotation> = []
        
        if let studentLocations = self.studentLocations {
            for studentLocation in studentLocations {
                let locationAnnotation = MKPointAnnotation()
                locationAnnotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(studentLocation.latitude), longitude: CLLocationDegrees(studentLocation.longitude))
                locationAnnotation.title = "\(studentLocation.firstName) \(studentLocation.lastName)"
                locationAnnotation.subtitle = studentLocation.mediaURL
                locationAnnotations.append(locationAnnotation)
            }
        }
        
        return locationAnnotations
    }
    
    private init() { }
    
    // MARK: StudentLocation Methods
    // fetchStudentLocations
    // Fetches student locations from the server
    func fetchStudentLocations(successCallback: @escaping () -> Void, errorCallback: @escaping (String) -> Void) {
        // Fetch student locations from the API
        self.apiClient.createAndExecuteTask(endpoint: .GetStudentLocation(limit: nil, skip: nil, order: "-updatedAt", uniqueKey: nil), requestBody: nil, successHandler: { responseData in
            // otherwise try to decode the data to an object
            do {
                let studentLocations = try JSONDecoder().decode(StudentInformationArray.self, from: responseData)

                self.studentLocations = studentLocations.results
                successCallback()
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
    
    // createUserLocation
    // Posts a new StudentInformation to the server
    func createUserLocation(newLocation: StudentInformation, successCallback: @escaping () -> Void, errorCallback: @escaping (String) -> Void) {
        do {
            let data = try JSONEncoder().encode(newLocation)
            self.apiClient.createAndExecuteTask(endpoint: .CreateStudentLocation, requestBody: data, successHandler: { responseData in
                //  if the user posting was successful, add it to the array
                self.studentLocations?.insert(newLocation, at: 0)
                successCallback()
            }, errorHandler: errorCallback)
        } catch {
            errorCallback(error.localizedDescription)
        }
    }
    
    // MARK: CurrentUser Methods
    // getUserData
    // Fetches the User's info (mainly first and last name) from the Udacity API
    func getUserData(userKey: Int, errorHandler: @escaping (String) -> Void) {
        self.apiClient.createAndExecuteTask(endpoint: .GetUser(id: userKey), requestBody: nil, successHandler: { responseData in
            let response = self.apiClient.parseJsonResponse(responseData: responseData.subdata(in: 5..<responseData.count), errorHandler: errorHandler)
            
            // save the current user's info for posting pins
            self.currentUser = CurrentUser(userSession: self.apiClient.userSession!, userKey: userKey, userFirstName: response?["first_name"] as! String, userLastName: response?["last_name"] as! String)
        }, errorHandler: errorHandler)
    }
}
