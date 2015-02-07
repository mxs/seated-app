//
//  Subscription.swift
//  seated
//
//  Created by Michael Shang on 05/02/2015.
//  Copyright (c) 2015 Michael Shang. All rights reserved.
//

import UIKit

class Subscription: PFObject, PFSubclassing {

    override class func load() {
        self.registerSubclass()
    }
    
    class func parseClassName() -> String! {
        return "Subscription"
    }
    
    func update(data:NSDictionary) -> Void {
        self.subscriptionId = data["id"] as String
        self.status = data["status"] as String
        self.cancelAtPeriodEnd = data["cancel_at_period_end"] as Bool
        self.currentPeriodStart = NSDate(timeIntervalSince1970: data["current_period_start"] as Double)
        self.currentPeriodEnd = NSDate(timeIntervalSince1970: data["current_period_end"] as Double)
        self.startDate = NSDate(timeIntervalSince1970: data["start"] as Double)
        self.trialEnd = NSDate(timeIntervalSince1970: data["trial_end"] as Double)
    }
    
    var subscriptionId:String {
        get {
            return self["subscription_id"] as String
        }
        set {
            self["subscription_id"] = newValue
        }
    }
    
    var startDate:NSDate {
        get {
            return self["start"] as NSDate
        }
        set {
            self["start"] = newValue
        }
    }
    
    var currentPeriodEnd:NSDate {
        get {
            let c = self["current_period_end"] as NSDate
            println("current period end: \(c)")
            return self["current_period_end"] as NSDate
        }
        set {
            self["current_period_end"] = newValue
        }
    }
    
    var currentPeriodStart:NSDate {
        get {
            return self["current_period_start"] as NSDate
        }
        set {
            self["current_period_start"] = newValue
        }
    }
    
    var trialEnd:NSDate {
        get {
            return self["trial_end"] as NSDate
        }
        set {
            self["trial_end"] = newValue
        }
    }
    
    var status:String {
        get {
            return self["status"] as String
        }
        set {
            self["status"] = newValue
        }
    }

    var cancelAtPeriodEnd:Bool {
        get {
            return self["cancel_at_period_end"] as Bool
        }
        set {
            self["cancel_at_period_end"] = newValue
        }
    }
    
}
