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
    var userLocation: String!
    let geocoder = CLGeocoder()
    @IBOutlet weak var linkTextFIeld: UITextField!
    @IBOutlet weak var userLocationMap: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.geocodeUserLocatiom()
    }
    
    // geocodeUserLocatiom
    // Geocodes the given location and adjusts the map to show it
    func geocodeUserLocatiom() {
        geocoder.geocodeAddressString(self.userLocation, completionHandler: { placemark, error in
            guard error == nil, let placemark = placemark else {
                self.showErrorAlert(errorStr: error!.localizedDescription)
                return
            }
            
            guard let placemarkLocation = placemark[0].location else {
                self.showErrorAlert(errorStr: "There is no location associated with that name")
                return
            }
            
            // Generate the annotation for the map
            let locationAnnotation = MKPointAnnotation()
            locationAnnotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(placemarkLocation.coordinate.latitude), longitude: CLLocationDegrees(placemarkLocation.coordinate.longitude))
            
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
}
