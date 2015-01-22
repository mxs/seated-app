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
        
        Firebase.setOption("persistence", to: true)
        
        self.conversationsRef = Firebase(url: "https://seatedapp.firebaseio.com/users/\(SeatedUser.currentUser().stripeCustomerId)/conversations")
        
        let authData = self.conversationsRef.authData
        if authData == nil {
            self.conversationsRef.authAnonymouslyWithCompletionBlock({ (error, authData) -> Void in
                if error == nil {
                    self.observeConversationValueEvent()
                }
            })
        }
        else {
            self.observeConversationValueEvent()
        }
    }
    
    func observeConversationValueEvent() -> Void {
        self.conversationsRef.observeEventType(FEventType.Value, withBlock: { (snapshot) -> Void in
            if snapshot.hasChildren() {
                
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
            if snapshot.hasChildren() {
                let title = snapshot.value["title"] as String
                let lastMessage = snapshot.value["lastMessage"] as String
                let lastMessageTime = snapshot.value["lastMessageTime"] as Int
                let participants = snapshot.value["participants"] as NSDictionary
                
                var conversation = Conversation(id: conversationId, title: title, lastMessage: lastMessage, lastMesasgeTime: lastMessageTime, participants:participants)

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
    
    //MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.conversations.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:ConversationTableViewCell = tableView.dequeueReusableCellWithIdentifier(self.cellReuseId) as ConversationTableViewCell

        let conversation = self.conversations[indexPath.row] as Conversation
        cell.lastMessageLabel.text = conversation.lastMessage
        cell.titleLabel.text = conversation.title
        cell.timeStampLabel.text = conversation.lastMessageTimePretty
        cell.unreadCountLabel.text = String(conversation.unreadCountForParticipant(SeatedUser.currentUser().stripeCustomerId))
        
        return cell
    }
    
    //MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("conversationSegue", sender: indexPath)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "conversationSegue" {
            var vc = segue.destinationViewController as ConversationViewController
            vc.conversation = self.conversations[(sender as NSIndexPath).row]
        }
    }

}
