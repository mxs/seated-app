//
//  UnsubscribedHelper.swift
//  seated
//
//  Created by Michael Shang on 13/01/2015.
//  Copyright (c) 2015 Michael Shang. All rights reserved.
//

import UIKit

class UnsubscribedHelper: NSObject, UIAlertViewDelegate {
    
    class var sharedInstance: UnsubscribedHelper {
        struct Static {
            static var instance: UnsubscribedHelper?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token, { () -> Void in
            Static.instance = UnsubscribedHelper()
        })
        
        return Static.instance!
    }
    
    func userNoLongerSubscribed() {
        let alertView = UIAlertView(title: "Subscription Expired", message: "Your subscription has expired, would you like to re-subscribe?", delegate: self, cancelButtonTitle: "No", otherButtonTitles: "Yes")
        alertView.show()
    }
    
    //MARK: - UIAlertViewDelegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        let storyBoard = UIStoryboard(name: "Storyboard", bundle: NSBundle.mainBundle())
        let window = UIApplication.sharedApplication().delegate?.window!
        if buttonIndex == 0 {
            SeatedUser.logOut()
            
            //no need to reset rootViewController if we are already there
            if window!.rootViewController!.presentedViewController != nil {
                let rootVC = storyBoard.instantiateInitialViewController() as RootViewController
                window!.rootViewController = rootVC
            }
        }
        else {
            let rootVC = storyBoard.instantiateInitialViewController() as RootViewController
            window!.rootViewController = rootVC

            window!.rootViewController!.performSegueWithIdentifier("rootToPaymentSegue", sender: self)
//            let paymentVC = storyBoard.instantiateViewControllerWithIdentifier("paymentViewController") as UIViewController
//            window!.rootViewController = paymentVC
        }
    }

}
