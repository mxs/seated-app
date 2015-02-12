//
//  SeatedUser.swift
//  seated
//
//  Created by Michael Shang on 07/01/2015.
//  Copyright (c) 2015 Michael Shang. All rights reserved.
//

import UIKit

class SeatedUser: PFUser, PFSubclassing {
    
    override class func load() {
        self.registerSubclass()
    }
    
    func update(user:SeatedUser) -> Void {
        self.stripeCustomerId = user.stripeCustomerId
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.cardId = user.cardId
        self.cardLabel = user.cardLabel
        self.isAdmin = user.isAdmin
        self.subscription = user.subscription
    }
    
    var stripeCustomerId:String {
        get {
            return self["stripeCustomerId"] as String
        }
        
        set {
            self["stripeCustomerId"] = newValue
        }
    }

    var firstName:String {
        get {
            return self["firstName"] as String
        }
        set {
            self["firstName"] = newValue
        }
    }

    var lastName:String {
        get {
            return self["lastName"] as String
        }
        set {
            self["lastName"] = newValue
        }
    }
    
    var displayName:String {
        return "\(self.firstName) \(self.lastName)"
    }
    
    var cardId:String? {
        get {
            return self["card_id"] as String?
        }
        set {
            self["card_id"] = newValue
        }
    }
    
    var cardLabel:String? {
        get {
            return self["card_label"] as String?
        }
        set {
            self["card_label"] = newValue
        }
    }
    
    var isAdmin:Bool {
        get {
            return self["isAdmin"] as Bool
        }
        set {
            self["isAdmin"] = newValue
        }
    }
    
    var subscription:Subscription? {
        get {
            return self["subscription"] as? Subscription
        }
        set {
            self["subscription"] = newValue
        }
    }
    
}
