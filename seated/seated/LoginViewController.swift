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
    @IBOutlet weak var newUserButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    var backgroundImageView: UIImageView!
    var backgroundImage:UIImage?
    var forgotPasswordMode:Bool = false
    
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
        
        self.loginButton.setTitleColor(UIColor.textColour(), forState: UIControlState.Normal)
        self.loginButton.setBackgroundImage(UIImage.imageWithColor(UIColor.primaryColour()), forState: UIControlState.Normal)
        self.loginButton.layer.cornerRadius = 5.0
        self.loginButton.layer.masksToBounds = true
        
        self.passwordTextField.secureTextEntry = true
        self.passwordTextField.delegate = self
        self.passwordTextField.required = true

        self.emailTextField.required = true
        self.emailTextField.isEmailField = true
    }
    
    override func viewWillAppear(animated: Bool) {
        self.emailTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.emailTextField.resignFirstResponder()
    }

    @IBAction func action(sender: AnyObject) {
        
        if self.forgotPasswordMode {
            self.resetPassword()
        }
        else {
            self.login()
        }
    }
    
    @IBAction func toggleMode() {
        self.forgotPasswordMode = !self.forgotPasswordMode
        self.passwordTextField.hidden = self.forgotPasswordMode
        self.newUserButton.hidden = self.forgotPasswordMode
        
        if self.forgotPasswordMode {
            self.loginButton.setTitle("Reset Password", forState: UIControlState.Normal)
            self.forgotPasswordButton.setTitle("Remembered Password?", forState: UIControlState.Normal)
        }
        else {
            self.loginButton.setTitle("Login", forState: UIControlState.Normal)
            self.forgotPasswordButton.setTitle("Forgot Password?", forState: UIControlState.Normal)
        }
    }

    func login() {
        if self.emailTextField.validate() && self.passwordTextField.validate() {
            SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Black)
            PFUser.logInWithUsernameInBackground(self.emailTextField.text, password: self.passwordTextField.text) { (user, error) -> Void in
                if error == nil {
                    let loggedInUser = user as SeatedUser
                    
                    loggedInUser.pinInBackgroundWithBlock({ (success, error) -> Void in
                        
                    })
                    
                    let currentInstallation = PFInstallation.currentInstallation()
                    if currentInstallation.channels == nil {
                        currentInstallation.channels = ["global"]
                    }
                    currentInstallation.channels.append(loggedInUser.stripeCustomerId)
                    currentInstallation.saveEventually(nil)
                    
                    SVProgressHUD.dismiss()
                    
                    if loggedInUser.isAdmin {
                        self.performSegueWithIdentifier("adminLoginSuccessSegue", sender: self)
                    }
                    else {
                        self.performSegueWithIdentifier("customerLoginSuccessSegue", sender: self)
                    }
                    
                }
                else {
                    var errorMessage = ""
                    println(error.code)
                    switch error.code {
                    case kPFErrorConnectionFailed:
                        errorMessage = "Connection Failed"
                    case kPFErrorObjectNotFound:
                        errorMessage = "Incorrect Credentials"
                    default:
                        errorMessage = "Please Try Again"
                    }
                    SVProgressHUD.showErrorWithStatus(errorMessage)
                }
            }
        }
    }
    
    func resetPassword() {
        if self.emailTextField.validate() {
            if PFUser.requestPasswordResetForEmail(self.emailTextField.text) {
                let alertController = UIAlertController(title: "Password Reset", message: "Instructions sent to email.", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style: .Cancel) { (action) in
                    self.toggleMode()
                }
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }

    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.login()
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

