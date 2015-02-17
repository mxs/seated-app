//
//  FirebaseExtension.swift
//  seated
//
//  Created by Michael Shang on 17/02/2015.
//  Copyright (c) 2015 Michael Shang. All rights reserved.
//

import UIKit

extension Firebase {
    class var applicationName:String {
        get {
            #if DEBUG
                return "seated-dev"
            #elseif RELEASE
                return "seated-prod"
            #endif
        }
    }
}
