//
//  LinkPostViewController.swift
//  onthemap
//
//  Created by Shir Bar Lev on 28/03/2022.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

class LinkPostViewController: UIViewController {
    var userLocationStr: String!
    var userLocation: CLLocation?
    let geocoder = CLGeocoder()
    let apiClient = APIClient.sharedClient
    let appDataHandler = OnTheMapHandler.sharedHandler
    @IBOutlet weak var linkTextFIeld: UITextField!
    @IBOutlet weak var userLocationMap: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.geocodeUserLocation()
    }
    
    // geocodeUserLocation
    // Geocodes the given location and adjusts the map to show it
    func geocodeUserLocation() {
        geocoder.geocodeAddressString(self.userLocationStr, completionHandler: { placemark, error in
            guard error == nil, let placemark = placemark else {
                self.showErrorAlert(errorStr: error!.localizedDescription)
                return
            }
            
            guard let placemarkLocation = placemark[0].location else {
                self.showErrorAlert(errorStr: "There is no location associated with that name")
                return
            }
            
            self.userLocation = placemark[0].location
            
            // Generate the annotation for the map
            let locationAnnotation = MKPointAnnotation()
            locationAnnotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(placemarkLocation.coordinate.latitude), longitude: CLLocationDegrees(placemarkLocation.coordinate.longitude))
            locationAnnotation.title = "\(self.appDataHandler.currentUser!.userFirstName) \(self.appDataHandler.currentUser!.userLastName)"
            
            // Set the map centre to the given location and add the annotation
            DispatchQueue.main.async {
                self.userLocationMap.setRegion(MKCoordinateRegion(center: placemarkLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: CLLocationDegrees(0.5), longitudeDelta: CLLocationDegrees(0.5))), animated: true)
                self.userLocationMap.addAnnotation(locationAnnotation)
            }
            })
    }
    
    // showErrorAlert
    // Displays an alert controller with the given error message
    func showErrorAlert(errorStr: String) {
        DispatchQueue.main.async {
            let errorAlert = UIAlertController(title: "An Error Occurred", message: "There was a problem locaing you: \(errorStr). Please try again.", preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                self.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(errorAlert, animated: true, completion: nil)
        }
    }
    
    // submitUserLocation
    // Submits the user's data to the API
    @IBAction func submitUserLocation(_ sender: Any) {
        guard let locationCoords = self.userLocation else {
            return
        }
        
        let currentDateTime = Date().formatted()
        
        // create the new StudentInformation object and send it to the server
        let userLocation = StudentInformation(objectId: "", uniqueKey: String(self.apiClient.userKey!), firstName: self.appDataHandler.currentUser!.userFirstName, lastName: self.appDataHandler.currentUser!.userLastName, mapString: self.userLocationStr, mediaURL: self.linkTextFIeld.text ?? "", latitude: Float(locationCoords.coordinate.latitude), longitude: Float(locationCoords.coordinate.longitude), createdAt: currentDateTime, updatedAt: currentDateTime)
        
        self.appDataHandler.createUserLocation(newLocation: userLocation, successCallback: self.redirectToMapView, errorCallback: self.showErrorAlert(errorStr:))
    }
    
    // redirectToMapView
    // Upon successfully posting the data, returns the user to the map view
    func redirectToMapView() {
        DispatchQueue.main.async {
            let tabBarController = self.navigationController?.viewControllers[1] as! UITabBarController
            let mapViewController = tabBarController.viewControllers?[0] as! MapViewController
            // set the region of the map to the area of the user
            mapViewController.mapView?.setRegion(MKCoordinateRegion(center: self.userLocation!.coordinate, span: MKCoordinateSpan(latitudeDelta: CLLocationDegrees(0.5), longitudeDelta: CLLocationDegrees(0.5))), animated: true)
            // navigate back to the tab bar controller
            self.navigationController?.popToViewController(tabBarController, animated: true)
        }
    }
}
