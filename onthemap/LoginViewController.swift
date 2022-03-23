//
//  LoginViewController.swift
//  onthemap
//
//  Created by Shir Bar Lev on 18/07/2021.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    // MARK: Variables & Constants
    let apiClient = APIClient()
    var sessionId: String?
    
    // MARK: Outlets
    @IBOutlet weak var usernameTextFIeld: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorTextLabel: UILabel!

    // MARK: Lifecycle Methods
    override func viewWillAppear(_ animated: Bool) {
        self.errorTextLabel.text = ""
        self.passwordTextField.isSecureTextEntry = true
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
            self.apiClient.executeDataTask(url: loginUrl) { (responseData, errorStr) in
                // if there was an error, alert the user
                guard errorStr == nil, let responseData = responseData else {
                    DispatchQueue.main.async {
                        self.errorTextLabel.text = errorStr
                    }
                    return
                }
                
                // otherwise handle handle login
                self.handleSuccessfulLogin(responseData: responseData)
            }
        } catch let error {
            DispatchQueue.main.async {
                self.errorTextLabel.text = error.localizedDescription
            }
        }
    }

    // handleLogin
    // Handles a successful login
    // Gets the session ID from the response and send the user to the main view controller
    func handleSuccessfulLogin(responseData: Data) {
        do {
            // Get the session ID from the response, as specified in their API docs
            let response = try JSONSerialization.jsonObject(with: responseData.subdata(in: 5..<responseData.count), options: []) as! [String: [String: Any]]
            self.sessionId = response["session"]?["id"] as? String
            
            // send the user to the next view
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "continueToAppSegue", sender: nil)
            }
        } catch {
            DispatchQueue.main.async {
                self.errorTextLabel.text = error.localizedDescription
            }
        }
    }
}

