//
//  BlurBackgroundProtocol.swift
//  seated
//
//  Created by Michael Shang on 05/02/2015.
//  Copyright (c) 2015 Michael Shang. All rights reserved.
//

import UIKit

@objc protocol BlurBackgroundProtocol {
    var blurredBackgroundImage:UIImage? {get set}
}