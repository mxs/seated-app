//
//  RestPasswordViewController.swift
//  seated
//
//  Created by Michael Shang on 02/01/2015.
//  Copyright (c) 2015 Michael Shang. All rights reserved.
//

import UIKit

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func resetPassword(sender: AnyObject) {
        if PFUser.requestPasswordResetForEmail(self.emailTextField.text) {
        
            let alertController = UIAlertController(title: "Password Reset", message: "Instructions sent to email.", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Cancel, handler: { (action) -> Void in
                println("OK")
            })
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
        
    }
    
}
