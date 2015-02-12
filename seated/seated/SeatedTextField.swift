//
//  SeatedTextField.swift
//  seated
//
//  Created by Michael Shang on 03/02/2015.
//  Copyright (c) 2015 Michael Shang. All rights reserved.
//

import UIKit

class SeatedTextField: MHTextField {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.whiteColor()
        self.textColor = UIColor.textColour()
    }
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 10.0, 10.0);
    }

    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return textRectForBounds(bounds)
    }
    
    override func setNeedsAppearance(sender: AnyObject!) {
        var textField = sender as MHTextField
        println(textField)
        if textField.isValid {
            self.textColor = UIColor.textColour()
        }
        else {
            self.textColor = UIColor.redColor()
        }
    }

}
