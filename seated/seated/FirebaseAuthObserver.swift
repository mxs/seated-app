//
//  FirebaseAuthObserver.swift
//  seated
//
//  Created by Michael Shang on 03/03/2015.
//  Copyright (c) 2015 Michael Shang. All rights reserved.
//

import UIKit

class FirebaseAuthObserver: NSObject {
    
    let kFirebaseConnected = "FirebaseConnected"
    private var started:Bool = false
    private var _authenticated:Bool = false
    var isAuthenticated:Bool {
        get {
            return _authenticated
        }
    }
    
    class var sharedInstance: FirebaseAuthObserver {
        struct Static {
            static var instance: FirebaseAuthObserver?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token, { () -> Void in
            Static.instance = FirebaseAuthObserver()
        })
        
        return Static.instance!
    }
    
    func startObserver() {
        if !started {
            let ref = Firebase(url: "https://\(Firebase.applicationName).firebaseio.com")
            ref.observeAuthEventWithBlock({ authData in
                if authData != nil {
                    self._authenticated = true
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: self.kFirebaseConnected, object: nil))
                }
                else {
                    self._authenticated = false
                    ref.authAnonymouslyWithCompletionBlock({ (error, authData) -> Void in
                    })
                }
            })
            started = true
        }
    }

}
