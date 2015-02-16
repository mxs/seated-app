//
//  SignUpViewController.swift
//  seated
//
//  Created by Michael Shang on 27/12/2014.
//  Copyright (c) 2014 Michael Shang. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController, BlurBackgroundProtocol {

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

            self.checkIfUserAlreadyExists(newUser)
            
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
    
    func checkIfUserAlreadyExists(newUser:SeatedUser) -> Void {
        SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Black)
        
        var query = PFUser.query()
        query.whereKey("email", equalTo: self.emailTextField.text)
        query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            if error == nil {
                if results.count == 0 {
                    self.createStripeCustomerAndTrialSubscription(newUser)
                }
                else {
                    SVProgressHUD.showErrorWithStatus("Email Already Exists")
                }
            }
        }
    }
    
    func createSubscriptionObject(data:NSDictionary) -> Subscription {
        var subscription:Subscription = Subscription()
        subscription.update(data)
        return subscription
    }
    
    func createStripeCustomerAndTrialSubscription(newUser:SeatedUser) -> Void {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("performSuccessSegue"), name: "SVProgressHUDDidDisappearNotification", object: nil)

        var params = ["email": newUser.email]
        
        PFCloud.callFunctionInBackground("createCustomerAndSubscribe", withParameters: params) { (result, error) -> Void in
            if error != nil {
                SVProgressHUD.showErrorWithStatus("Sign Up Failed")
            }
            else {
                
                newUser.stripeCustomerId = result["id"] as String
                newUser.isAdmin = false
                let subscriptions = result["subscriptions"] as NSDictionary
                
                if let dataArray = subscriptions["data"] as? NSArray {
                    if dataArray.count > 0 {
                        if let data = dataArray[0] as? NSDictionary {
                            newUser.subscription = self.createSubscriptionObject(data)
                        }
                    }
                }
                
                newUser.signUpInBackgroundWithBlock({ (success, error) -> Void in
                    if success {
                        newUser.pinInBackgroundWithBlock({ (success, error) -> Void in
                        })
                        self.setUpPushNotification(newUser.stripeCustomerId)
                        self.createFirebaseUser(newUser)
                        let eventParams = ["stripeId":newUser.stripeCustomerId]
                        Flurry.setUserID(newUser.email)
                        Flurry.logEvent("Signup_To_Trial", withParameters:eventParams)
                    }
                    else {
                        SVProgressHUD.showErrorWithStatus("Sign Up Failed")
                    }
                })
            }
        }
    }
    
    func createFirebaseUser(user:SeatedUser) -> Void {
        let userRef = Firebase(url:"https://seatedapp.firebaseio.com/users/\(user.stripeCustomerId)")
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
            })
        }
        else {
            userRef.setValue(userValues)
            SVProgressHUD.showSuccessWithStatus("You're In!")
        }
    }
    
    func setUpPushNotification(stripeCustomerId:String) {
        let currentInstallation = PFInstallation.currentInstallation()
        if currentInstallation.channels != nil {
            currentInstallation.channels.append(stripeCustomerId)
        }
        else {
            currentInstallation.channels = ["global"]
        }
        currentInstallation.saveEventually(nil)
    }
    
    func performSuccessSegue() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "SVProgressHUDDidDisappearNotification", object: nil)
        self.performSegueWithIdentifier("signupCompleteSegue", sender: self)
    }
    
}
