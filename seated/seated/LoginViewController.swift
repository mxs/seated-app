//
//  ViewController.swift
//  seated
//
//  Created by Michael Shang on 23/12/2014.
//  Copyright (c) 2014 Michael Shang. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func loginIn(sender: AnyObject) {
        
        PFUser.logInWithUsernameInBackground(self.emailTextField.text, password: self.passwordTextField.text) { (user, error) -> Void in
            if error == nil {
                let loggedInUser = user as SeatedUser
                
                let currentInstallation = PFInstallation.currentInstallation()
                if currentInstallation.channels == nil {
                    currentInstallation.channels = ["global"]
                }
                currentInstallation.channels.append(loggedInUser.stripeCustomerId)
                currentInstallation.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if error != nil {
                        //TODO: handle error
                    }
                })
                
                
                if loggedInUser.isAdmin {
                    self.performSegueWithIdentifier("adminLoginSuccessSegue", sender: self)
                }
                else {
                    self.performSegueWithIdentifier("customerLoginSuccessSegue", sender: self)
                }

            }
            else {
                //TODO: handle login fail error
            }
        }
        
    }
}

