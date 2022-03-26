//
//  StudentsViewsBaseClass.swift
//  onthemap
//
//  Created by Shir Bar Lev on 26/03/2022.
//

import Foundation
import UIKit

class StudentsViewsBaseClass: UIViewController {
    let studentInfoHandler = StudentInformationHandler.sharedHandler
    
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
    
    // navigateToUserURL
    // Displays an alert allowing the user to navigate to the provided URL
    func navigateToUserURL(_ sender: UIButton) {
        let userURL = sender.title(for: .normal)
        let url = self.studentInfoHandler.createUserURLFromAnnotation(urlStr: userURL)
        
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
}
