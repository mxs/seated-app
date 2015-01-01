//
//  SignUpViewController.swift
//  seated
//
//  Created by Michael Shang on 27/12/2014.
//  Copyright (c) 2014 Michael Shang. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func createAccount(sender: UIButton) {
        var newUser:PFUser = PFUser()
        newUser.username = emailTextField.text
        newUser.email = emailTextField.text
        newUser.password = passwordTextField.text
        newUser["firstName"] = firstNameTextField.text
        newUser["lastName"] = lastNameTextField.text

        newUser.signUpInBackgroundWithBlock { (success, error) -> Void in
            if success {
                self.performSegueWithIdentifier("paymentsSegue", sender: self)
            }
            else {
                println(error)
            }

        }
        
    }
    
}
