//
//  Conversation.swift
//  seated
//
//  Created by Michael Shang on 19/01/2015.
//  Copyright (c) 2015 Michael Shang. All rights reserved.
//

import UIKit

class Conversation: NSObject {
    let id:String!
    let title:String!
    let dateFormatter:NSDateFormatter!
    var lastMessage:String!
    var lastMessageTime:Int!
    
    init(id:String, title:String, lastMessage:String, lastMesasgeTime:Int) {
        self.id = id
        self.title = title
        self.lastMessage = lastMessage
        self.lastMessageTime = lastMesasgeTime
        
        let timeZone = NSTimeZone.localTimeZone()
        self.dateFormatter = NSDateFormatter()
        self.dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        self.dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle
        self.dateFormatter.timeZone = timeZone
        self.dateFormatter.locale = NSLocale.currentLocale()

    }
    
    var lastMessageTimePretty:String {
        let date = NSDate(timeIntervalSince1970: Double(self.lastMessageTime)/1000)
        return self.dateFormatter.stringFromDate(date)
    }
}
