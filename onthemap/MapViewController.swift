//
//  MapViewController.swift
//  onthemap
//
//  Created by Shir Bar Lev on 21/03/2022.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    // MARK: Variables & Constants
    let apiClient = APIClient.sharedClient
    @IBOutlet weak var mapView: MKMapView?
    
    // MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchStudentLocations()
    }
    
    // MARK: User Locations Methods
    // fetchStudentLocations
    // Fetches student locations from the server
    func fetchStudentLocations() {
        do {
            // Fetch student locations from the API
            let urlRequest = try self.apiClient.getUrlRequest(endpoint: .GetStudentLocation(limit: nil, skip: nil, order: nil, uniqueKey: nil))
            self.apiClient.executeDataTask(url: urlRequest) { responseData, errorStr in
                // if there was an error, alert the user
                guard errorStr == nil, let responseData = responseData else {
                    self.showErrorAlert(errorStr: errorStr!)
                    return
                }

                // otherwise try to decode the data to an object
                do {
                    let studentLocations = try JSONDecoder().decode(StudentInformationArray.self, from: responseData)

                    self.addStudentLocationsToMap(locations: studentLocations.results)
                // if there's a problem, alert the user
                } catch {
                    self.showErrorAlert(errorStr: error.localizedDescription)
                }
            }
        } catch {
            self.showErrorAlert(errorStr: error.localizedDescription)
        }
        
    }
    
    // addStudentLocationsToMap
    // Creates the location annonation objects and adds them to the map
    func addStudentLocationsToMap(locations: Array<StudentInformation>) {
        var locationAnnonations: Array<MKPointAnnotation> = []

        for studentLocation in locations {
            let locationAnnonation = MKPointAnnotation()
            locationAnnonation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(studentLocation.latitude), longitude: CLLocationDegrees(studentLocation.longitude))
            locationAnnonation.title = "\(studentLocation.firstName) \(studentLocation.lastName)"
            locationAnnonation.subtitle = studentLocation.mediaURL
            locationAnnonations.append(locationAnnonation)
        }
        
        DispatchQueue.main.async {
            self.mapView?.addAnnotations(locationAnnonations)
        }
    }
    
    // showErrorAlert
    // Displays an alert controller with the given error message
    func showErrorAlert(errorStr: String) {
        DispatchQueue.main.async {
            let errorAlert = UIAlertController(title: "An Error Occurred", message: errorStr, preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(errorAlert, animated: true, completion: nil)
        }
    }
}
