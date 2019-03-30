//
//  SignUpViewController.swift
//  TruMove
//
//  Created by Damon on 2019-03-28.
//  Copyright © 2019 ece1778. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // sign up button tabbed, start user registration processes
    @IBAction func signUpButtonTabbed(_ sender: Any) {
        let userUsername = usernameTextField.text
        let userEmail = emailTextField.text
        let userPassword = passwordTextField.text
        let userConfirmPassword = confirmPasswordTextField.text
        
        if (userEmail!.isEmpty || userPassword!.isEmpty || userConfirmPassword!.isEmpty || userUsername!.isEmpty){
            // Display alert message
            displayMyAlertMessage(view: self, userMessage: "All fields are required!")
            return;
        }
        
        if (!isValidEmail(email: userEmail!)) {
            // display alert message
            displayMyAlertMessage(view: self, userMessage: "Please input a valid email!")
            return;
        }
        
        // check passwords matches each other
        if (userPassword != userConfirmPassword) {
            // Display alert message
            displayMyAlertMessage(view: self, userMessage: "Passwords do not match!")
            return;
        }
        
        displayLoadingOverlay(view: self)
        createUser(email: userEmail!, password: userPassword!, username: userUsername!)
    }
    
    // create user and upload user data into firestore
    func createUser(email: String, password: String, username: String) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
                self.dismiss(animated: false, completion: nil)
                displayMyAlertMessage(view: self, userMessage: error?.localizedDescription ?? "Error creating user")
            } else {
                Auth.auth().signIn(withEmail: email, password: password)
                Firestore.firestore().collection("register").document((Auth.auth().currentUser?.uid)!).setData([
                    "new": true
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        self.dismiss(animated: false, completion: nil)
                        self.performSegue(withIdentifier: "signUpToSport", sender: self)
                    }
                }
            }
        }
    }

}
