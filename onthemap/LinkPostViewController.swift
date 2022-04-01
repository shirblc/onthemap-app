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
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var linkPostActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.geocodeUserLocation()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(redirectToMapView))
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
                self.linkPostActivityIndicator.stopAnimating()
                self.submitButton.isEnabled = true
                self.userLocationMap.alpha = 1
                self.userLocationMap.setRegion(MKCoordinateRegion(center: placemarkLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: CLLocationDegrees(0.5), longitudeDelta: CLLocationDegrees(0.5))), animated: true)
                self.userLocationMap.addAnnotation(locationAnnotation)
            }
            })
    }
    
    // showErrorAlert
    // Displays an alert controller with the given error message
    func showErrorAlert(errorStr: String) {
        DispatchQueue.main.async {
            self.linkPostActivityIndicator.stopAnimating()
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
        
        DispatchQueue.main.async {
            self.linkPostActivityIndicator.startAnimating()
        }
        
        self.appDataHandler.createUserLocation(newLocation: userLocation, successCallback: self.setupMapControllerAndRedirect, errorCallback: self.showErrorAlert(errorStr:))
    }
    
    // setupMapControllerAndRedirect
    // Upon successfully posting the data, adjusts the map to show the user's location and returns the user to the map view
    func setupMapControllerAndRedirect() {
        DispatchQueue.main.async {
            self.linkPostActivityIndicator.stopAnimating()
            let tabBarController = self.navigationController?.viewControllers[1] as! UITabBarController
            let mapViewController = tabBarController.viewControllers?[0] as! MapViewController
            // set the region of the map to the area of the user
            mapViewController.mapView?.setRegion(MKCoordinateRegion(center: self.userLocation!.coordinate, span: MKCoordinateSpan(latitudeDelta: CLLocationDegrees(0.5), longitudeDelta: CLLocationDegrees(0.5))), animated: true)
            mapViewController.addStudentLocationsToMap()
        }
        
        self.redirectToMapView()
    }
    
    // redirectToMapView
    // Redirects the user back to the tab bar controller
    @objc func redirectToMapView() {
        DispatchQueue.main.async {
            let tabBarController = self.navigationController?.viewControllers[1] as! UITabBarController
            self.navigationController?.popToViewController(tabBarController, animated: true)
        }
    }
}
