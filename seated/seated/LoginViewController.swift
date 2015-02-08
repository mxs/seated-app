//
//  ViewController.swift
//  seated
//
//  Created by Michael Shang on 23/12/2014.
//  Copyright (c) 2014 Michael Shang. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController, UITextFieldDelegate, BlurBackgroundProtocol {

    @IBOutlet weak var emailTextField: SeatedTextField!
    @IBOutlet weak var passwordTextField: SeatedTextField!
    @IBOutlet weak var loginButton: UIButton!
    var backgroundImageView: UIImageView!
    var backgroundImage:UIImage?
    
    //MARK: - BlurBackgroundProtocol
    var blurredBackgroundImage:UIImage? {
        get {
            return self.backgroundImage
        }
        set {
            self.backgroundImage = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.backgroundImageView = UIImageView(image: self.backgroundImage)
        self.view.addSubview(self.backgroundImageView)
        self.view.sendSubviewToBack(self.backgroundImageView)
        
        self.passwordTextField.secureTextEntry = true
        self.passwordTextField.delegate = self

        self.loginButton.setTitleColor(UIColor.textColour(), forState: UIControlState.Normal)
        self.loginButton.setBackgroundImage(UIImage.imageWithColor(UIColor.primaryColour()), forState: UIControlState.Normal)
        self.loginButton.layer.cornerRadius = 5.0
        self.loginButton.layer.masksToBounds = true
    }
    
    override func viewWillAppear(animated: Bool) {
        self.emailTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.emailTextField.resignFirstResponder()
    }

    @IBAction func loginIn(sender: AnyObject) {
        
        SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Black)
        
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
                        currentInstallation.saveEventually()
                    }
                })
                
                SVProgressHUD.dismiss()
                
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
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.loginIn(self)
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "newUserSegue" {
            if segue.destinationViewController.conformsToProtocol(BlurBackgroundProtocol) {
                var destVC = segue.destinationViewController as BlurBackgroundProtocol
                destVC.blurredBackgroundImage = self.blurredBackgroundImage
            }
        }
    }
}

