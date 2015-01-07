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
    
    var stripeCustomerId:String {
        get {
            return self["stripeCustomerId"] as String
        }
        
        set {
            self["stripeCustomerId"] = newValue
        }
    }

    dynamic var firstName:String {
        get {
            return self["firstName"] as String
        }
        set {
            self["firstName"] = newValue
        }
    }

    dynamic var lastName:String {
        get {
            return self["lastName"] as String
        }
        set {
            self["lastName"] = newValue
        }
    }
    
    dynamic var displayName:String {
        return "\(self.firstName) \(self.lastName)"
    }
    
}
