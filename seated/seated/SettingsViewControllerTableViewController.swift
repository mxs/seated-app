//
//  SettingsViewControllerTableViewController.swift
//  seated
//
//  Created by Michael Shang on 09/01/2015.
//  Copyright (c) 2015 Michael Shang. All rights reserved.
//

import UIKit

class SettingsViewControllerTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func logout(sender: AnyObject) {
        let alertController = UIAlertController(title: "Are you sure?", message: "", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler:nil)
        let yesAction = UIAlertAction(title: "Log out", style: .Default) { (action) -> Void in
            PFUser.logOut()
            Firebase(url: "https://seatedapp.firebaseio.com/").unauth()
            self.performSegueWithIdentifier("logoutSegue", sender: self)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(yesAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func cancelSubscription(sender: AnyObject) {
        PFCloud.callFunctionInBackground("cancelSubscription",
            withParameters: ["stripeCustomerId": SeatedUser.currentUser().stripeCustomerId, "subscriptionId":SeatedUser.currentUser().subscriptionId]) { (result, error) -> Void in
                if error != nil {
                    //TODO: display error
                }
                else {
                    PFUser.logOut()
                }
        }

    }
}
