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

class MapViewController: StudentsViewsBaseClass, MKMapViewDelegate {
    // MARK: Variables & Constants
    @IBOutlet weak var mapView: MKMapView?
    
    // MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView?.delegate = self
        self.appDataHandler.fetchStudentLocations(successCallback: self.addStudentLocationsToMap, errorCallback: self.showErrorAlert(errorStr:))
    }
    
    // MARK: User Locations Methods
    // addStudentLocationsToMap
    // Creates the location annotation objects and adds them to the map
    func addStudentLocationsToMap() {
        DispatchQueue.main.async {
            self.mapView?.addAnnotations(self.appDataHandler.studentLocationsAnnotations)
        }
    }
    
    // MARK: MKMapViewDelegate methods
    // Handles creating/updating the annotations as the view changes
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationViewIdentifier)
        
        if annotationView == nil {
            let userDataButton = UIButton(type: .system, primaryAction: UIAction(handler: { action in
                let userProvidedURL = (action.sender as! UIButton).title(for: .normal) ?? ""
                self.navigateToUserURL(userURL: userProvidedURL)
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
