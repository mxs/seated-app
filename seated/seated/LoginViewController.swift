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
        
        var userDefaults = NSUserDefaults.standardUserDefaults()
        if userDefaults.boolForKey("installed") {
            
        }
    }

    @IBAction func loginIn(sender: AnyObject) {
        
        PFUser.logInWithUsernameInBackground(self.emailTextField.text, password: self.passwordTextField.text) { (user, error) -> Void in
            if error == nil {
                println("login success")
                SKTUser.currentUser().firstName = user["firstName"] as String
                SKTUser.currentUser().lastName = user["lastName"] as String
                SupportKit.show()
            }
        }
        
    }
}

