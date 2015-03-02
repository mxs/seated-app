//
//  SignUpViewController.swift
//  seated
//
//  Created by Michael Shang on 27/12/2014.
//  Copyright (c) 2014 Michael Shang. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController, BlurBackgroundProtocol, UITextFieldDelegate {

    @IBOutlet weak var firstNameTextField: SeatedTextField!
    @IBOutlet weak var lastNameTextField: SeatedTextField!
    @IBOutlet weak var emailTextField: SeatedTextField!
    @IBOutlet weak var passwordTextField: SeatedTextField!
    @IBOutlet weak var nextButton: UIButton!
    
    var backgroundImageView:UIImageView!
    var backgroundImage:UIImage?
    var textFields:[SeatedTextField]?

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
        
        self.nextButton.setTitleColor(UIColor.textColour(), forState: UIControlState.Normal)
        self.nextButton.setBackgroundImage(UIImage.imageWithColor(UIColor.primaryColour()), forState: UIControlState.Normal)
        self.nextButton.layer.cornerRadius = 5.0
        self.nextButton.layer.masksToBounds = true
        
        self.firstNameTextField.required = true
        self.lastNameTextField.required = true
        self.emailTextField.required = true
        self.emailTextField.isEmailField = true
        self.passwordTextField.secureTextEntry = true
        self.passwordTextField.required = true
        self.passwordTextField.delegate = self
        
        self.textFields = [self.firstNameTextField, self.lastNameTextField, self.emailTextField, self.passwordTextField]
    }
    
    override func viewWillAppear(animated: Bool) {
        self.firstNameTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.firstNameTextField.resignFirstResponder()
    }

    @IBAction func validateSignup(sender: AnyObject) {
        if self.validateFormLocally() {

            var newUser = SeatedUser()
            newUser.username = emailTextField.text
            newUser.email = emailTextField.text
            newUser.password = passwordTextField.text
            newUser.firstName = firstNameTextField.text
            newUser.lastName = lastNameTextField.text

            self.signup(newUser)
            
        }
    }
    
    func validateFormLocally() -> Bool {
        for textField in self.textFields! {
            if !textField.validate() {
                return false
            }
        }
        return true
    }

    func signup(newUser:SeatedUser) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("performSuccessSegue"), name: "SVProgressHUDDidDisappearNotification", object: nil)

        SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Black)
        newUser.isAdmin = false
        newUser.signUpInBackgroundWithBlock({ (success, error) -> Void in
            if success {
                newUser.pinInBackgroundWithBlock({ (success, error) -> Void in
                })
                self.setUpPushNotification(newUser.objectId)
                self.createFirebaseUser(newUser)
                Flurry.setUserID(newUser.email)
                Flurry.logEvent("Signup")
            }
            else {
                //TOOD: check for user name taken error code
                SVProgressHUD.showErrorWithStatus("Sign Up Failed")
            }
        })
    }
    
    func createFirebaseUser(user:SeatedUser) -> Void {
        let userRef = Firebase(url:"https://\(Firebase.applicationName).firebaseio.com/users/\(user.firebaseId)")
        let userValues = [
            "email":user.email,
            "firstName":user["firstName"],
            "lastName":user["lastName"]
        ]
        
        if userRef.authData == nil {
            userRef.authAnonymouslyWithCompletionBlock({ (error, authData) -> Void in
                if error == nil {
                    userRef.setValue(userValues)
                    SVProgressHUD.showSuccessWithStatus("You're In!")
                }
                else {
                    println(error)
                }
            })
        }
        else {
            userRef.setValue(userValues)
            SVProgressHUD.showSuccessWithStatus("You're In!")
        }
    }
    
    func setUpPushNotification(objectId:String) {
        let currentInstallation = PFInstallation.currentInstallation()
        if currentInstallation.channels != nil {
            currentInstallation.channels.append(objectId)
        }
        else {
            currentInstallation.channels = ["global"]
        }
        currentInstallation.saveInBackgroundWithBlock { (success, error) -> Void in
            if error != nil {
                currentInstallation.saveEventually(nil)
            }
        }

    }
    
    func performSuccessSegue() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "SVProgressHUDDidDisappearNotification", object: nil)
        self.performSegueWithIdentifier("signupCompleteSegue", sender: self)
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.validateSignup(self)
        return false
    }

}
