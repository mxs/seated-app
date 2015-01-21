//
//  ConversationListViewController.swift
//  seated
//
//  Created by Michael Shang on 16/01/2015.
//  Copyright (c) 2015 Michael Shang. All rights reserved.
//

import UIKit

class ConversationListViewController: UITableViewController {

    let cellReuseId = "conversationCell"
    var conversationsRef:Firebase!
    var conversations = [Conversation]()
    var conversationCount:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.conversationsRef = Firebase(url: "https://seatedapp.firebaseio.com/users/seatbot/conversations")
        self.conversationsRef.observeEventType(FEventType.Value, withBlock: { (snapshot) -> Void in
            if snapshot.value != nil {
                println(snapshot.value.count)
                let dic = snapshot.value as NSDictionary
                let keys = dic.allKeys
                self.conversationCount = keys.count
                for conversationId in keys {
                    self.getConversation(conversationId as String)
                }
            }
        })
        
    }

    func getConversation(conversationId:String) -> Void {
        let conversationRef = Firebase(url: "https://seatedapp.firebaseio.com/conversations/\(conversationId)")
        conversationRef.observeSingleEventOfType(FEventType.Value, withBlock: { (snapshot) -> Void in
            if snapshot.value != nil {
                let title = snapshot.value["title"] as String
                let lastMessage = snapshot.value["lastMessage"] as String
                let lastMessageTime = snapshot.value["lastMessageTime"] as Int
                var conversation = Conversation(id: conversationId, title: title, lastMessage: lastMessage, lastMesasgeTime: lastMessageTime)
                self.conversations.append(conversation)
                
                if self.conversations.count == self.conversationCount {
                    
                    self.conversations.sort({ (first:Conversation, second:Conversation) -> Bool in
                        return first.lastMessageTime > second.lastMessageTime
                    })
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                    })
                }
            }
        })
    }
    
    //MARK: - TableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.conversations.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:ConversationTableViewCell = tableView.dequeueReusableCellWithIdentifier(self.cellReuseId) as ConversationTableViewCell

        let conversation = self.conversations[indexPath.row] as Conversation
        cell.lastMessageLabel.text = conversation.lastMessage
        cell.titleLabel.text = conversation.title
        cell.timeStampLabel.text = conversation.lastMessageTimePretty
        
        return cell
    }

}
