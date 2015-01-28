//
//  UnsubscribedHelper.swift
//  seated
//
//  Created by Michael Shang on 13/01/2015.
//  Copyright (c) 2015 Michael Shang. All rights reserved.
//

import UIKit

class UnsubscribedHelper: NSObject {
    
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

}
