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
        if textField.isValid {
            self.textColor = UIColor.textColour()
            self.attributedPlaceholder = self.placeHolder(textField.placeholder, colour: UIColor.validPlaceholderColour())
        }
        else {
            if textField.isEmailField {
                self.textColor = UIColor.redColor()
                if textField.text == "" {
                    self.attributedPlaceholder = self.placeHolder(textField.placeholder, colour:UIColor.invalidPlaceholderColour())
                }
            }
            else if textField.required {
                self.attributedPlaceholder = self.placeHolder(textField.placeholder, colour:UIColor.invalidPlaceholderColour())
            }
        }
    }
    
    override func validate() -> Bool {
        var valid = super.validate()
        if valid {
            if self.secureTextEntry {
                return countElements(self.text) >= 8
            }
        }
        return valid
    }
    
    func placeHolder(placeHolder:String?, colour:UIColor) -> NSAttributedString {
        if let placeHolder = placeholder {
            return NSAttributedString(string: placeHolder, attributes: [NSForegroundColorAttributeName:colour])
        }
        else {
            return NSAttributedString(string: "", attributes: [NSForegroundColorAttributeName:UIColor.validPlaceholderColour()])
        }

    }
}
