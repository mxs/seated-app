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
    @IBOutlet weak var subscriptionButton: UIButton!
    
    var nextBillingDate:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        
        if let subscription = SeatedUser.currentUser().subscription {
            let dateFormat = NSDateFormatter()
            dateFormat.dateFormat = "dd MMM YYYY"
            self.nextBillingDate = dateFormat.stringFromDate(subscription.currentPeriodEnd)
            
            self.updateSubscriptionStatusLabels()
            self.fullNameLabel.text = SeatedUser.currentUser().displayName
            self.subscriptionDescriptionLabel.text = "$5 monthly subscription (\(subscription.status))"
            
            self.tableView.tableHeaderView?.frame = CGRectMake(0, 0, self.tableView.frame.width, 125.0)
            
        }
    }
    
    @IBAction func logout(sender: AnyObject) {
        let alertController = UIAlertController(title: "Are you sure?", message: "", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler:nil)
        let yesAction = UIAlertAction(title: "Log out", style: .Default) { (action) -> Void in
            PFUser.logOut()
            Firebase(url: "https://seatedapp.firebaseio.com/").unauth()
            let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let rootVC = storyBoard.instantiateInitialViewController() as UIViewController
            self.presentViewController(rootVC, animated: true, completion: nil)

        }
        alertController.addAction(cancelAction)
        alertController.addAction(yesAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func updateSubscription(sender: AnyObject) {
        if let subscription = SeatedUser.currentUser().subscription {
            let params = ["stripeCustomerId": SeatedUser.currentUser().stripeCustomerId, "subscriptionId":subscription.subscriptionId, "objectId":subscription.objectId]
            
            if self.isTrialCancelled() {
                self.reactivateTrialSubscription(params, subscription:subscription)
            }
            else {
                self.cancelSubscription(params, subscription: subscription)
            }            
        }
    }
    
    //Only used to unwind segues to this view controller
    @IBAction func prepareForSegueUnwind(storyBoardSegue:UIStoryboardSegue) {
        self.updatePaymentRequired()
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
    
    func cancelSubscription(params:[String:String!], subscription:Subscription) {
        let cancelMessage = "Your subscription will still be vaild until \(self.nextBillingDate), are you sure you want to cancel?"
        let alertController = UIAlertController(title: "Cancel Subscription", message: cancelMessage, preferredStyle: .Alert)
        let noAction = UIAlertAction(title: "No", style: .Cancel, handler:nil)
        let yesAction = UIAlertAction(title: "Yes", style: .Default) { (action) -> Void in
            SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Black)
            PFCloud.callFunctionInBackground("cancelSubscription", withParameters:params) { (result, error) -> Void in
                if error == nil {
                    SVProgressHUD.showSuccessWithStatus("Subscription Cancelled")
                    subscription.cancelAtPeriodEnd = true
                    self.updateSubscriptionStatusLabels()
                }
                else {
                    SVProgressHUD.showErrorWithStatus("Cancellation Failed")
                }
            }
        }
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func reactivateTrialSubscription(params:[String:String!], subscription:Subscription) {
        let reactivateMessage = "Your next charge will be on \(self.nextBillingDate)"
        let alertController = UIAlertController(title: "Reactivate Trial", message: reactivateMessage, preferredStyle: .Alert)
        let noAction = UIAlertAction(title: "No", style: .Cancel, handler:nil)
        let yesAction = UIAlertAction(title: "Reactivate", style: .Default) { (action) -> Void in
            SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Black)
            PFCloud.callFunctionInBackground("reactivateTrialSubscription", withParameters:params) { (result, error) in
                if error == nil {
                    SVProgressHUD.showSuccessWithStatus("Trial Subscription Reactivated")
                    subscription.cancelAtPeriodEnd = false
                    self.updateSubscriptionStatusLabels()
                }
                else {
                    SVProgressHUD.showErrorWithStatus("Reactivation Failed")
                }
            }
        }
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func updateSubscriptionStatusLabels() {
        if self.isTrialCancelled() {
            self.nextBillingDateLabel.text = "Trial service ends on \(self.nextBillingDate)"
            self.subscriptionButton.setTitle("Reactivate Subscription", forState: UIControlState.Normal)
            self.cardDetailsLabel.text = "No pending charges"
            self.cardDetailsLabel.textColor = UIColor.blackColor()
        }
        else {
            self.nextBillingDateLabel.text = "Next charge on \(self.nextBillingDate)"
            self.subscriptionButton.setTitle("Cancel Subscription", forState: UIControlState.Normal)
            self.updatePaymentRequired()
        }
        self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func isTrialCancelled() -> Bool {
        if let subscription = SeatedUser.currentUser().subscription {
            return subscription.cancelAtPeriodEnd && subscription.status == "trialing"
        }
        return true
    }
    
    //hides and unhides the payment details cell
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && self.isTrialCancelled() {
            return 0
        }
        else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
}
