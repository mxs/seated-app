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
    
    func userNoLongerSubscribed() -> UIAlertController {
        
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let window = UIApplication.sharedApplication().delegate?.window!
        
        let alertController = UIAlertController(title: "Subscription Expired", message: "Would you like to re-subscribe?", preferredStyle: .Alert)
        let noAction = UIAlertAction(title: "No", style: .Cancel) { (action) -> Void in
            SeatedUser.logOut()
            let rootVC = storyBoard.instantiateInitialViewController() as RootViewController
            window!.rootViewController = rootVC
        }
        
        let yesAction = UIAlertAction(title: "Yes", style: .Default) { (action) -> Void in
            let rootVC = storyBoard.instantiateInitialViewController() as RootViewController
            window!.rootViewController = rootVC
            window!.rootViewController!.performSegueWithIdentifier("rootToPaymentSegue", sender: self)
        }
        
        alertController.addAction(noAction)
        alertController.addAction(yesAction)

        return alertController
        
    }
    
    func fetchStripeSubscription() {
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
                    self.checkTrialValidity(user)
                }
                else {
                    
                }
            })
            
        })
    }
    
    func checkTrialValidity(user:SeatedUser) {
        let subscription = user.subscription
        if subscription.status == self.trial {
            if subscription.daysUntilTrialEnd <= 3 {
                if user.cardId == nil {
                    
                }
                else {
                    
                }
            }
        }
        
    }

}
