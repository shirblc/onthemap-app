//
//  MapViewController.swift
//  onthemap
//
//  Created by Shir Bar Lev on 21/03/2022.
//

import Foundation
import UIKit
import MapKit

let annotationViewIdentifier = "onTheMapAV"

class MapViewController: UIViewController, MKMapViewDelegate {
    // MARK: Variables & Constants
    let apiClient = APIClient.sharedClient
    @IBOutlet weak var mapView: MKMapView?
    
    // MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView?.delegate = self
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
    // Creates the location annotation objects and adds them to the map
    func addStudentLocationsToMap(locations: Array<StudentInformation>) {
        var locationAnnotations: Array<MKPointAnnotation> = []

        for studentLocation in locations {
            let locationAnnotation = MKPointAnnotation()
            locationAnnotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(studentLocation.latitude), longitude: CLLocationDegrees(studentLocation.longitude))
            locationAnnotation.title = "\(studentLocation.firstName) \(studentLocation.lastName)"
            locationAnnotation.subtitle = studentLocation.mediaURL
            locationAnnotations.append(locationAnnotation)
        }
        
        DispatchQueue.main.async {
            self.mapView?.addAnnotations(locationAnnotations)
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
    
    // MARK: MKMapViewDelegate methods
    // Handles creating/updating the annotations as the view changes
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationViewIdentifier)
        
        if annotationView == nil {
            let userDataButton = UIButton(type: .system)
            userDataButton.setTitle(annotation.subtitle ?? "", for: .normal)
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: annotationViewIdentifier)
            annotationView?.canShowCallout = true
            annotationView?.detailCalloutAccessoryView = userDataButton
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
}
