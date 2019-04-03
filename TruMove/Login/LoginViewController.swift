//
//  LoginViewController.swift
//  TruMove
//
//  Created by Damon on 2019-03-28.
//  Copyright © 2019 ece1778. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "toSports", sender: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func loginButtonTabbed(_ sender: Any) {
        let email = emailTextField.text
        let password = passwordTextField.text
        
        if (email!.isEmpty) || (password!.isEmpty) {
            displayMyAlertMessage(view: self, userMessage: "Please fill all fields!")
        }
        
        Auth.auth().signIn(withEmail: email!, password: password!) { (user, error) in
            if error == nil {
                self.performSegue(withIdentifier: "toSports", sender: self)
            } else {
                displayMyAlertMessage(view: self, userMessage: error?.localizedDescription ?? "Error logging in")
            }
        }
    }
}
