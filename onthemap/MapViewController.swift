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
        self.studentInfoHandler.fetchStudentLocations(successCallback: self.addStudentLocationsToMap(locations:), errorCallback: self.showErrorAlert(errorStr:))
    }
    
    // MARK: User Locations Methods
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
