//
//  LocationEditViewController.swift
//  onthemap
//
//  Created by Shir Bar Lev on 26/03/2022.
//

import Foundation
import UIKit

class LocationEditViewController: UIViewController {
    var locationText: String?
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var findOnMapButton: UIButton!
    
    // MARK: Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.findOnMapButton.isEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserLocation(textFieldNotification:)), name: UITextField.textDidChangeNotification, object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "enterLinkSegue" {
            let linkEditViewController = segue.destination as! LinkPostViewController
            linkEditViewController.userLocationStr = self.locationText
        }
    }
    
    // updateUserLocation
    // Updates the user's location when the text field's value changes
    @objc func updateUserLocation(textFieldNotification: Notification) {
        self.locationText = (textFieldNotification.object as? UITextField?)??.text
        
        // if the user inputted text, enable the "find on the map" button
        self.findOnMapButton.isEnabled = self.locationText == nil ? false : true
    }
}
