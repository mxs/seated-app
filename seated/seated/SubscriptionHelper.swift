//
//  UnsubscribedHelper.swift
//  seated
//
//  Created by Michael Shang on 13/01/2015.
//  Copyright (c) 2015 Michael Shang. All rights reserved.
//

import UIKit

class SubscriptionHelper: NSObject {
    
    let trial = "trialing"
    let active = "active"
    let pastDue = "past_due"
    let canceled = "canceled"
    let noValidCardAlertCountKey = "noValidCardAlertCount"
    let warnBeforeChargeAlertCountKey = "warnBeforeChargeAlertCount"
    
    class var sharedInstance: SubscriptionHelper {
        struct Static {
            static var instance: SubscriptionHelper?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token, { () -> Void in
            Static.instance = SubscriptionHelper()
        })
        
        return Static.instance!
    }
    
    func fetchStripeSubscription(presentingViewController:UIViewController) {
        let user = SeatedUser.currentUser()
        var query = SeatedUser.query()
        
        // local query just to populate subscription property of user as SeatedUser.current() does not do that
        query.fromLocalDatastore()
        query.includeKey("subscription")
        query.getObjectInBackgroundWithId(user.objectId, block: { (resultUser, error) -> Void in
            
            let params = ["stripeCustomerId":user.stripeCustomerId, "subscriptionId":user.subscription.subscriptionId, "objectId":user.subscription.objectId]
            // This cloud function pull in data from Stripe also updates the subscription in Parse so we don't need to save to Parse again
            PFCloud.callFunctionInBackground("retrieveSubscription", withParameters:params, block: { (subscriptionData, error) -> Void in
                if error == nil {
                    user.subscription.update(subscriptionData as NSDictionary)
                    self.checkTrialValidity(user, presentingViewController: presentingViewController)
                }
                else {
                    
                }
            })
            
        })
    }
    
    func checkTrialValidity(user:SeatedUser, presentingViewController:UIViewController) {
        let subscription = user.subscription
        if subscription.status == self.trial {
            if user.subscription.daysUntilTrialEnd <= 3 {
                if user.cardId == nil {
                    self.noValidCard(user.subscription, presentingViewController: presentingViewController)
                }
                else {
                    self.haveValidCard(user.subscription, presentingViewController: presentingViewController)
                }
            }
        }
        
    }
    
    // Only show alert once
    func haveValidCard(subscription:Subscription, presentingViewController:UIViewController) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        var alertCount = defaults.integerForKey(self.warnBeforeChargeAlertCountKey)

        if alertCount < 1 {
            let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let window = UIApplication.sharedApplication().delegate?.window!
            let dateFormat = NSDateFormatter()
            dateFormat.dateFormat = "dd MMM YYYY"
            let chargeDate = dateFormat.stringFromDate(subscription.trialEnd)
            let alertController = UIAlertController(title: "Trial ends in \(subscription.daysUntilTrialEnd) days", message: "First charge to occur on \(chargeDate)", preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            
            alertController.addAction(okAction)

            defaults.setInteger(++alertCount, forKey: self.warnBeforeChargeAlertCountKey)
            
            presentingViewController.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // Only show alert twice
    func noValidCard(subscription:Subscription, presentingViewController:UIViewController) {
        let defaults = NSUserDefaults.standardUserDefaults()
        var alertCount = defaults.integerForKey(self.noValidCardAlertCountKey)
        
        if alertCount < 2 {
            let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let window = UIApplication.sharedApplication().delegate?.window!
            
            let alertController = UIAlertController(title: "Trial ends in \(subscription.daysUntilTrialEnd) days", message: "Would you like to add payment method?", preferredStyle: .Alert)
            let noAction = UIAlertAction(title: "No", style: .Cancel, handler: nil)
            
            let yesAction = UIAlertAction(title: "Yes", style: .Default) { (action) -> Void in
                let navigationVC = window!.rootViewController as UINavigationController
                let settingsVC = storyBoard.instantiateViewControllerWithIdentifier("settingsViewController") as UIViewController
                navigationVC.pushViewController(settingsVC, animated: true)
            }
            
            alertController.addAction(noAction)
            alertController.addAction(yesAction)
            
            defaults.setInteger(++alertCount, forKey: self.noValidCardAlertCountKey)
            
            presentingViewController.presentViewController(alertController, animated: true, completion: nil)

        }
    }

}
