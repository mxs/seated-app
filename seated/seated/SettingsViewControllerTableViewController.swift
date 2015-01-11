//
//  SettingsViewControllerTableViewController.swift
//  seated
//
//  Created by Michael Shang on 09/01/2015.
//  Copyright (c) 2015 Michael Shang. All rights reserved.
//

import UIKit

class SettingsViewControllerTableViewController: UITableViewController, UIAlertViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func logout(sender: AnyObject) {
        let alertView = UIAlertView(title: "", message: "Are you sure?", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Log out")
        alertView.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            PFUser.logOut()
            self.performSegueWithIdentifier("logoutSegue", sender: self)
        }
    }
}
