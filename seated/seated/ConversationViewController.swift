//
//  ConversationViewController.swift
//  seated
//
//  Created by Michael Shang on 03/01/2015.
//  Copyright (c) 2015 Michael Shang. All rights reserved.
//

import UIKit

class ConversationViewController: JSQMessagesViewController {
    
    let seatbotId = "seatbot"
    let welcomeMessage = "Hi there, welcome to seated!"
    var stripeCustomerId:String!
    var messagesRef:Firebase!
    var messages = [JSQMessage]()
    var outgoingMessageBubbleImage:JSQMessagesBubbleImage!
    var incomingMessageBubbleImage:JSQMessagesBubbleImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        Firebase.setOption("persistence", to: true)

        self.stripeCustomerId = SeatedUser.currentUser().stripeCustomerId
        self.title = "Lets get you seated!"
        self.senderId = self.stripeCustomerId
        self.senderDisplayName = SeatedUser.currentUser().displayName
        self.outgoingMessageBubbleImage = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        self.incomingMessageBubbleImage = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;

        self.setupFirebase()
    }
    
    @IBAction func sendMessage(send:AnyObject) {
        self.messagesRef.childByAutoId().setValue(["sender":self.stripeCustomerId, "text":"stand by me", "senderDisplayName":SeatedUser.currentUser().displayName])
    }
    
    @IBAction func logout(sender: AnyObject) {
        PFUser.logOut()
        self.performSegueWithIdentifier("logoutSegue", sender: self)
    }
    
    //TODO: Remove
    @IBAction func createConversation(sender: AnyObject) {
        self.setupFirebase()
    }
    
    //TODO: Remove
    @IBAction func createBob(sender: AnyObject) {
        let usersRef = Firebase(url:"https://seatedapp.firebaseio.com/users/\(self.stripeCustomerId)")
        usersRef.setValue([
            "email":"bobby@gmail.com",
            "firstName:":"Bobby",
            "lastName:":"Valentino"
        ])
    }
    
    func observeMessagesForConversation(conversationId:String) -> Firebase {
        self.messagesRef = Firebase(url: "https://seatedapp.firebaseio.com/messages/\(conversationId)")
        self.messagesRef.observeEventType(FEventType.ChildAdded, withBlock: { (snapshot) -> Void in
              println(snapshot.value)
            let senderId = snapshot.value["sender"] as String
            let senderDisplayName = snapshot.value["senderDisplayName"] as String
            let text = snapshot.value["text"] as String
            let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
            self.messages.append(message)
            self.finishReceivingMessage()
          
        })
        return self.messagesRef
    }
    
    // Sets up new user or starts listening to messages in current conversations
    func setupFirebase() -> Void {

        let userConversationsRef = Firebase(url:"https://seatedapp.firebaseio.com/users/\(self.stripeCustomerId)/conversations")
        userConversationsRef.observeSingleEventOfType(FEventType.Value, withBlock: { (snapshot) -> Void in
            if snapshot.hasChildren() {
                //assume only one conversation for user
                let conversationId = (snapshot.value as NSDictionary).allKeys[0] as String
                self.observeMessagesForConversation(conversationId)
            }
            else {
                println("snapshot is empty")
                self.startConversationWithSeatBot(userConversationsRef)
            }
        })
    }
    
    func startConversationWithSeatBot(userConversationsRef:Firebase) -> Void {

        let conversationId = self.generateConversationId(seatbotId)
        userConversationsRef.setValue([conversationId:true])
        let seatbotConversationRef = Firebase(url: "https://seatedapp.firebaseio.com/users/\(self.seatbotId)/conversations")
        seatbotConversationRef.setValue([conversationId:true])
        
        let conversationRef = Firebase(url: "https://seatedapp.firebaseio.com/conversations")
        conversationRef.childByAppendingPath("\(conversationId)/participants").setValue([self.stripeCustomerId:true, self.seatbotId:true])
        
        //sets self.messagesRef
        self.observeMessagesForConversation(conversationId)
        
        //Send first welcome message
        self.messagesRef.childByAutoId().setValue(["sender:":self.seatbotId, "text":self.welcomeMessage])
    }
    
    func generateConversationId(otherUserId:String) -> String {
        return self.stripeCustomerId < otherUserId ? "\(self.stripeCustomerId)-\(otherUserId)" : "\(otherUserId)-\(self.stripeCustomerId)"
    }

    
    //MARK: - JSQMessageViewController Overrides
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        self.messagesRef.childByAutoId().setValue(["sender":senderId, "text":text, "senderDisplayName":senderDisplayName])
        
        finishSendingMessage()
    }
    
    
    //MARK: - JSQMessagesCollectionViewDataSource
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return self.messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = self.messages[indexPath.item] as JSQMessage
        if message.senderId == self.senderId {
            return self.outgoingMessageBubbleImage
        }
        else {
            return self.incomingMessageBubbleImage
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    
    //MARK: - UICollectionViewDataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as JSQMessagesCollectionViewCell
        let message = self.messages[indexPath.item] as JSQMessage
        if message.senderId == self.senderId {
            cell.textView.textColor = UIColor.blackColor()
        }
        else {
            cell.textView.textColor = UIColor.whiteColor()
        }
        
        cell.textView.linkTextAttributes = [NSForegroundColorAttributeName: cell.textView.textColor, NSUnderlineStyleAttributeName:1] //NSUnderlineStyle.StyleSingle
        
        return cell
    }
    
    
}
