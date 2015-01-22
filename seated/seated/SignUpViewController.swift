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
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
                    self.errorMessageLabel.text = "Someone's already using that email address."
                }
            }
        }
    }
    
}
