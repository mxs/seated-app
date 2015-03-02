//
//  SettingsViewControllerTableViewController.swift
//  seated
//
//  Created by Michael Shang on 09/01/2015.
//  Copyright (c) 2015 Michael Shang. All rights reserved.
//

import UIKit

class SettingsViewControllerTableViewController: UITableViewController {

    @IBOutlet weak var fullNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        self.fullNameLabel.text = SeatedUser.currentUser().displayName
        self.tableView.tableHeaderView?.frame = CGRectMake(0, 0, self.tableView.frame.width, 25.0)

    }
    
    @IBAction func logout(sender: AnyObject) {
        let alertController = UIAlertController(title: "Are you sure?", message: "", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler:nil)
        let yesAction = UIAlertAction(title: "Log out", style: .Default) { (action) -> Void in
            SeatedUser.currentUser().unpin()
            PFUser.logOut()
            Firebase(url: "https://\(Firebase.applicationName).firebaseio.com/").unauth()
            
            var installation = PFInstallation.currentInstallation()
            installation.channels = []
            installation.saveInBackgroundWithBlock({ (success, error) -> Void in
            })
            
            let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let rootVC = storyBoard.instantiateInitialViewController() as UIViewController
            self.presentViewController(rootVC, animated: true, completion: nil)

        }
        alertController.addAction(cancelAction)
        alertController.addAction(yesAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.destinationViewController is TermPolicyViewController {
            var urlString:String?
            if segue.identifier == "termsSegue" {
                urlString = "http://getseated.com.au/terms"
            }
            else if segue.identifier == "privacySegue" {
                urlString = "http://getseated.com.au/privacy"
            }
            (segue.destinationViewController as TermPolicyViewController).urlString = urlString
        }

    }
    
}
