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
        self.firstName = user.firstName
        self.lastName = user.lastName
        self.isAdmin = user.isAdmin
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
    
    var isAdmin:Bool {
        get {
            return self["isAdmin"] as Bool
        }
        set {
            self["isAdmin"] = newValue
        }
    }
    
    //firebase Id (keys) cannot contain special characters so lets remove them
    //this id is also used as channel in Parse for push notificaiton values for 
    //channels must be alpha numeric and start with a character
    var firebaseId:String {
        if self.isAdmin {
            return "\(self.firstName)\(self.lastName)".lowercaseString
        }
        else {
            return "FIRE" + self.objectId
        }
        
    }
    
}
