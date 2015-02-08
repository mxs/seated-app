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
    @IBOutlet weak var subscriptionDescriptionLabel: UILabel!
    @IBOutlet weak var nextBillingDateLabel: UILabel!
    @IBOutlet weak var cardDetailsLabel: UILabel!
    @IBOutlet weak var paymentDetailsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        
        let subscription = SeatedUser.currentUser().subscription
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "dd MMM YYYY"
        let nextBillingDate = dateFormat.stringFromDate(subscription.currentPeriodEnd)

        self.nextBillingDateLabel.text = "Next charge on \(nextBillingDate)"
        self.fullNameLabel.text = SeatedUser.currentUser().displayName
        self.subscriptionDescriptionLabel.text = "$5 monthly subscription (\(subscription.status))"
        
        self.tableView.tableHeaderView?.frame = CGRectMake(0, 0, self.tableView.frame.width, 125.0)
        self.updatePaymentRequired()
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
//        PFCloud.callFunctionInBackground("cancelSubscription",
//            withParameters: ["stripeCustomerId": SeatedUser.currentUser().stripeCustomerId, "subscriptionId":SeatedUser.currentUser().subscription.subscriptionId]) { (result, error) -> Void in
//                if error != nil {
//                    //TODO: display error
//                }
//                else {
//                    PFUser.logOut()
//                }
//        }
    }
    
    func updatePaymentRequired() -> Void {
        if SeatedUser.currentUser().cardId == nil {
            self.paymentDetailsLabel.text = "Add Payment Details"
            self.paymentDetailsLabel.textColor = UIColor.redColor()
            self.cardDetailsLabel.text = "Payment Details Required"
            self.cardDetailsLabel.textColor = UIColor.redColor()
        }
        else {
            self.paymentDetailsLabel.text = "Update Payment Details"
            self.paymentDetailsLabel.textColor = UIColor.darkGrayColor()
            self.cardDetailsLabel.text = SeatedUser.currentUser().cardLabel
            self.cardDetailsLabel.textColor = UIColor.blackColor()
        }
    }
    
    //Only used to unwind segues to this view controller
    @IBAction func prepareForSegueUnwind(storyBoardSegue:UIStoryboardSegue) {
        self.updatePaymentRequired()
    }

    
}
