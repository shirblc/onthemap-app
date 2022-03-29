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
    let apiClient = APIClient.sharedClient
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logOut(_:)))
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(createUserLocation(_:)))
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
    
    // navigateToUserURL
    // Displays an alert allowing the user to navigate to the provided URL
    func navigateToUserURL(userURL: String) {
        let url = self.studentInfoHandler.createUserURLFromAnnotation(urlStr: userURL)
        
        // Display an alert for the user to choose whether to view the link in the browser
        DispatchQueue.main.async {
            let selectAlert = UIAlertController(title: "Visit Student Link", message: "You are about to be redirected to your browser to see the student's link. Continue?", preferredStyle: .alert)
            // if they choose to, try to navigate to the user's URL
            selectAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                if let url = url {
                    UIApplication.shared.open(url, options: [:], completionHandler: {
                        hasOpenedSuccessfully in
                        if(hasOpenedSuccessfully) {
                            return
                        // if there was an issue opening the URL, alert the user
                        } else {
                            self.showErrorAlert(errorStr: "The user did not provide a valid URL or there was a problem opening the URL")
                        }
                    })
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
    
    // createUserLocation
    // Triggers the segue to the view for creating a user location
    @objc func createUserLocation(_ sender: Any) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "editLocationSegue", sender: nil)
        }
    }
    
    // logOut
    // Logs the user out of the current session
    @objc func logOut(_ sender: Any) {
        do {
            let requestURL = try self.apiClient.getUrlRequest(endpoint: .LogOut, requestBody: nil)
            self.apiClient.executeDataTask(url: requestURL, successHandler: { _ in
                // log the user out and return them to login
                self.apiClient.userSession = nil
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }, errorHandler: self.showErrorAlert(errorStr:))
        } catch {
            self.showErrorAlert(errorStr: (error as? APIClientError)?.errorMessage ?? error.localizedDescription)
        }
        
    }
}
