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
        let requestBody = "{\"udacity\": { \"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        
        // Try to login
        self.apiClient.createAndExecuteTask(endpoint: .LogIn, requestBody: requestBody, successHandler: self.handleSuccessfulLogin(responseData:), errorHandler: self.handleLoginError(errorStr:))
    }

    // handleSuccessfulLogin
    // Handles a successful login
    // Gets the session ID from the response and send the user to the main view controller
    func handleSuccessfulLogin(responseData: Data) {
        // Get the session ID from the response, as specified in their API docs
        let response = self.apiClient.parseJsonResponse(responseData: responseData.subdata(in: 5..<responseData.count), errorHandler: self.handleLoginError(errorStr:)) as? [String: [String: Any]]
        
        self.apiClient.userSession = response?["session"]?["id"] as? String
        self.apiClient.userKey = response?["account"]?["key"] as? String
        
        // send the user to the next view
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "continueToAppSegue", sender: nil)
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

