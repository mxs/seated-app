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
    
    var backgroundImageView: UIImageView!
    var backgroundImage:UIImage?

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
        
        self.nextButton.setTitleColor(UIColor.textColour(), forState: UIControlState.Normal)
        self.nextButton.setBackgroundImage(UIImage.imageWithColor(UIColor.primaryColour()), forState: UIControlState.Normal)
        self.nextButton.layer.cornerRadius = 5.0
        self.nextButton.layer.masksToBounds = true

    }
    
    override func viewWillAppear(animated: Bool) {
        self.firstNameTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.firstNameTextField.resignFirstResponder()
    }

    @IBAction func validateSignup(sender: AnyObject) {
        if self.validateFormLocally() {
            self.checkIfUserAlreadyExists()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var newUser = SeatedUser()
        newUser.username = emailTextField.text
        newUser.email = emailTextField.text
        newUser.password = passwordTextField.text
        newUser.firstName = firstNameTextField.text
        newUser.lastName = lastNameTextField.text
        
        if segue.destinationViewController.isKindOfClass(PaymentViewController) {
            (segue.destinationViewController as PaymentViewController).newUser = newUser
        }
        
    }
    
    func validateFormLocally() -> Bool {
        return true
    }
    
    func checkIfUserAlreadyExists() -> Void {
        var query = PFUser.query()
        query.whereKey("email", equalTo: self.emailTextField.text)
        query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            if error == nil {
                if results.count == 0 {
                    self.performSegueWithIdentifier("signupToPaymentSegue", sender: self)
                }
                else {
                    //TOOD: show alert
                }
            }
        }
    }
    
}
