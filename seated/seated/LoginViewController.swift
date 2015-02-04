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
    @IBOutlet weak var loginButton: UIButton!
    var backgroundImageView: UIImageView!
    var backgroundImage:UIImage?
    let textColor = UIColor(rgb: "#494949")
    let primaryColour = UIColor(rgb: "#ffdb61")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.backgroundImageView = UIImageView(image: self.backgroundImage)
        self.view.addSubview(self.backgroundImageView)
        self.view.sendSubviewToBack(self.backgroundImageView)
        
        self.passwordTextField.secureTextEntry = true
        self.passwordTextField.backgroundColor = UIColor.whiteColor()
        self.passwordTextField.textColor = self.textColor
        self.emailTextField.backgroundColor = UIColor.whiteColor()
        self.emailTextField.textColor = self.textColor
        
        self.loginButton.setTitleColor(self.textColor, forState: UIControlState.Normal)
        self.loginButton.setBackgroundImage(UIImage.imageWithColor(self.primaryColour), forState: UIControlState.Normal)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.emailTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.emailTextField.resignFirstResponder()
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

