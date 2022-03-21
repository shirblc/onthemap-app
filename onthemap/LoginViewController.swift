//
//  LoginViewController.swift
//  onthemap
//
//  Created by Shir Bar Lev on 18/07/2021.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameTextFIeld: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorTextLabel: UILabel!


    override func viewWillAppear(_ animated: Bool) {
        self.errorTextLabel.text = ""
        self.passwordTextField.isSecureTextEntry = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    @IBAction func login(_ sender: UIButton) {
        // login
    }
}

