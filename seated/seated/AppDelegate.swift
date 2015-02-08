
//  AppDelegate.swift
//  seated
//
//  Created by Michael Shang on 23/12/2014.
//  Copyright (c) 2014 Michael Shang. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        Parse.enableLocalDatastore()
        Parse.setApplicationId("m8LgO3jYklu06JwdSXqwDh0WpC4hQXei4iDRl5CO", clientKey: "Yz7k5c4YGQ0SGtCM0xFVVNJXwmor0E5c8x6tGh3V")
        Stripe.setDefaultPublishableKey("pk_test_p4io3YSiR5p1F4f5XsGmtxSN")
        
        let userNotificationTypes = UIUserNotificationType.Alert | UIUserNotificationType.Sound | UIUserNotificationType.Badge
        let notificationSettings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
        application.registerForRemoteNotifications()
        
        var user = SeatedUser.currentUser()
        if (user != nil) {
            
            //always update user from Parse
            user.fetchInBackgroundWithBlock({ (result, error) -> Void in
                println("from fetch: \(user)")
                if error != nil {
                    //TODO:Alert about fetch latest user info
                }
            })
            
            SubscriptionHelper.sharedInstance.fetchStripeSubscription()
            
            let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            var rootNavigationVC:UINavigationController
            if user.isAdmin {
                rootNavigationVC = storyBoard.instantiateViewControllerWithIdentifier("conversationListNavigationController") as UINavigationController
            }
            else {
                rootNavigationVC = storyBoard.instantiateViewControllerWithIdentifier("conversationNavigationController") as UINavigationController
            }
            
            self.window?.rootViewController = rootNavigationVC
        }
        
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        var currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.channels = ["global"]
        if SeatedUser.currentUser() != nil {
            currentInstallation.channels.append(SeatedUser.currentUser().stripeCustomerId)
        }
        
        currentInstallation.saveInBackgroundWithBlock { (success, error) -> Void in
            if error != nil {
                //TODO: handle error
            }
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        var currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.badge = 0
        currentInstallation.saveEventually()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}

