//
//  Conversation.swift
//  seated
//
//  Created by Michael Shang on 19/01/2015.
//  Copyright (c) 2015 Michael Shang. All rights reserved.
//

import UIKit

class Conversation: NSObject, Equatable {
    let id:String!
    let title:String!
    var lastMessage:String!
    var lastMessageTime:Int!
    var participants:NSDictionary!
    
    init(id:String, title:String, lastMessage:String, lastMesasgeTime:Int, participants:NSDictionary) {
        self.id = id
        self.title = title
        self.lastMessage = lastMessage
        self.lastMessageTime = lastMesasgeTime
        self.participants = participants
    }
    
    var lastMessageTimePretty:String {
        var date = NSDate(timeIntervalSince1970: Double(self.lastMessageTime)/1000)
        let daysAgo = date.daysAgo()
        if daysAgo > 7 {
            return date.formattedDateWithFormat("d MMMM")
        }
        else if daysAgo < 1 {
            return date.formattedDateWithFormat("hh:mm aaa")
        }
        else {
            return date.formattedDateWithFormat("EEE")
        }
    }
    
    func unreadCountForParticipant(participant:String) -> Int {
        if let unreadCount = self.participants[participant] as? NSDictionary {
            return  unreadCount["unread-count"] as Int
        }
        return 0
    }
}

func ==(lhs: Conversation, rhs: Conversation) -> Bool {
    return lhs.id == rhs.id
}

