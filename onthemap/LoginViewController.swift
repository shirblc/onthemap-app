//
//  LoginViewController.swift
//  onthemap
//
//  Created by Shir Bar Lev on 18/07/2021.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    // MARK: Variables & Constants
    let apiClient = APIClient.sharedClient
    
    // MARK: Outlets
    @IBOutlet weak var usernameTextFIeld: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorTextLabel: UILabel!

    // MARK: Lifecycle Methods
    override func viewWillAppear(_ animated: Bool) {
        self.errorTextLabel.text = ""
        self.passwordTextField.isSecureTextEntry = true
        self.usernameTextFIeld.text = ""
        self.passwordTextField.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: Login Handling
    // login
    @IBAction func login(_ sender: UIButton) {
        let username = usernameTextFIeld.text!
        let password = passwordTextField.text!
        
        // Try to login
        do {
            var loginUrl = try self.apiClient.getUrlRequest(endpoint: .LogIn)
            loginUrl.httpBody = "{\"udacity\": { \"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: .utf8)
            self.apiClient.executeDataTask(url: loginUrl, successHandler: self.handleSuccessfulLogin(responseData:), errorHandler: self.handleLoginError(errorStr:))
        } catch let error {
            self.handleLoginError(errorStr: error.localizedDescription)
        }
    }

    // handleSuccessfulLogin
    // Handles a successful login
    // Gets the session ID from the response and send the user to the main view controller
    func handleSuccessfulLogin(responseData: Data) {
        do {
            // Get the session ID from the response, as specified in their API docs
            let response = try JSONSerialization.jsonObject(with: responseData.subdata(in: 5..<responseData.count), options: []) as! [String: [String: Any]]
            self.apiClient.userSession = response["session"]?["id"] as? String
            self.apiClient.userKey = response["account"]?["key"] as? String
            
            // send the user to the next view
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "continueToAppSegue", sender: nil)
            }
        } catch {
            self.handleLoginError(errorStr: error.localizedDescription)
        }
    }
    
    // handleLoginError
    // Alerts the user there was an issue logging in
    func handleLoginError(errorStr: String) {
        DispatchQueue.main.async {
            self.errorTextLabel.text = errorStr
        }
    }
}

