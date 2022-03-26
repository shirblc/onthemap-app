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
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
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
            let urlRequest = try self.apiClient.getUrlRequest(endpoint: .GetStudentLocation(limit: nil, skip: nil, order: "-updatedAt", uniqueKey: nil))
            self.apiClient.executeDataTask(url: urlRequest) { responseData, errorStr in
                // if there was an error, alert the user
                guard errorStr == nil, let responseData = responseData else {
                    self.showErrorAlert(errorStr: errorStr!)
                    return
                }

                // otherwise try to decode the data to an object
                do {
                    let studentLocations = try JSONDecoder().decode(StudentInformationArray.self, from: responseData)

                    self.appDelegate.studentLocations = studentLocations.results
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
    
    // navigateToUserURL
    // Displays an alert allowing the user to navigate to the provided URL
    func navigateToUserURL(_ sender: UIButton) {
        let userURL = sender.title(for: .normal)
        let url = self.createUserURLFromAnnotation(urlStr: userURL)
        
        // Display an alert for the user to choose whether to view the link in the browser
        DispatchQueue.main.async {
            let selectAlert = UIAlertController(title: "Visit Student Link", message: "You are about to be redirected to your browser to see the student's link. Continue?", preferredStyle: .alert)
            // if they choose to, try to navigate to the user's URL
            selectAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                if let url = url {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    // if there's a problem generating a URL, alert the user
                    self.dismiss(animated: true, completion: nil)
                    self.showErrorAlert(errorStr: "The user did not provide a valid URL")
                }
            }))
            // otherwise dismiss the alert
            selectAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(selectAlert, animated: true, completion: nil)
        }
    }
    
    // MARK: MKMapViewDelegate methods
    // Handles creating/updating the annotations as the view changes
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationViewIdentifier)
        
        if annotationView == nil {
            let userDataButton = UIButton(type: .system, primaryAction: UIAction(handler: { action in
                self.navigateToUserURL(action.sender as! UIButton)
            }))
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
