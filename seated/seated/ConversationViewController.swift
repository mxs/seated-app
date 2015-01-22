//
//  ConversationViewController.swift
//  seated
//
//  Created by Michael Shang on 03/01/2015.
//  Copyright (c) 2015 Michael Shang. All rights reserved.
//

import UIKit

class ConversationViewController: JSQMessagesViewController {
    
    let kFirebaseServerValueTimestamp = [".sv":"timestamp"]
    let seatbotId = "seatbot"
    let welcomeMessage = "Hi there, welcome to seated!"
    var stripeCustomerId:String!
    var conversationId:String!
    var messagesRef:Firebase!
    var conversationRef:Firebase!
    var conversation:Conversation?
    var messages = [JSQMessage]()
    var outgoingMessageBubbleImage:JSQMessagesBubbleImage!
    var incomingMessageBubbleImage:JSQMessagesBubbleImage!
    var incomingMessageAvatarImage:JSQMessagesAvatarImage!
    var alertController: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Firebase.setOption("persistence", to: true)
        
        self.stripeCustomerId = SeatedUser.currentUser().stripeCustomerId
        if self.conversation != nil { //admin mode
            self.title = self.conversation?.title
            self.conversationId = self.conversation?.id
            self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
            self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        }
        else {
            self.title = "Lets get you seated!"
           
            self.incomingMessageAvatarImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "incoming-avatar"), diameter: 40)
            self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize(width:40.0, height:40.0)
            self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        }
        
        self.outgoingMessageBubbleImage = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        self.incomingMessageBubbleImage = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        self.inputToolbar.contentView.leftBarButtonItem = nil
        self.senderId = self.stripeCustomerId
        self.senderDisplayName = SeatedUser.currentUser().displayName
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.jsq_defaultTypingIndicatorImage(), style: UIBarButtonItemStyle.Bordered, target: self, action: "showSettings")

        //User's subscription is no longer valid
        if self.stripeCustomerId == "" {
            self.alertController = UnsubscribedHelper.sharedInstance.userNoLongerSubscribed()
        }
        else {
            self.setupFirebase()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.messagesRef.removeAllObservers()
        self.conversationRef.removeAllObservers()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let alertController = self.alertController {
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func showSettings() {
        self.performSegueWithIdentifier("settingsSegue", sender: self)
    }
    
    func observeMessagesForConversation(conversationId:String) -> Firebase {
        self.messagesRef = Firebase(url: "https://seatedapp.firebaseio.com/messages/\(conversationId)")
        self.messagesRef.observeEventType(FEventType.ChildAdded, withBlock: { (snapshot) -> Void in
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
        let authData = userConversationsRef.authData
        
        if authData == nil {
            userConversationsRef.authAnonymouslyWithCompletionBlock({ (error, authData) -> Void in
                if error == nil {
                    self.getUserConversations(userConversationsRef)
                }
            })
        }
        else {
            self.getUserConversations(userConversationsRef)
        }
    }
    
    func getUserConversations(userConversationsRef:Firebase) -> Void {
        var firstRun = true
        userConversationsRef.observeEventType(FEventType.Value, withBlock: { (snapshot) -> Void in
            if firstRun { //HACK to get around this: http://stackoverflow.com/a/24516952/919533
                if snapshot.hasChildren() {

                    //assume only one conversation for customer
                    if self.conversationId == nil && !SeatedUser.currentUser().isAdmin {
                        self.conversationId = (snapshot.value as NSDictionary).allKeys[0] as String
                    }
                    self.conversationRef = Firebase(url: "https://seatedapp.firebaseio.com/conversations/\(self.conversationId)")
                    self.observeMessagesForConversation(self.conversationId)
                }
                else {
                    self.startConversationWithSeatBot(userConversationsRef)
                }
                firstRun = false
            }
            
        })
    }
    
    func startConversationWithSeatBot(userConversationsRef:Firebase) -> Void {

        self.conversationId = self.generateConversationId(seatbotId)
        userConversationsRef.childByAppendingPath(self.conversationId).setValue(true)
        let seatbotConversationRef = Firebase(url: "https://seatedapp.firebaseio.com/users/\(self.seatbotId)/conversations")
        seatbotConversationRef.childByAppendingPath(self.conversationId).setValue(true)
        
        self.conversationRef = Firebase(url: "https://seatedapp.firebaseio.com/conversations/\(self.conversationId)")
        conversationRef.childByAppendingPath("/title").setValue(SeatedUser.currentUser().displayName)
        conversationRef.childByAppendingPath("/lastMessage").setValue(self.welcomeMessage)
        conversationRef.childByAppendingPath("/participants").setValue([self.stripeCustomerId:true, self.seatbotId:true])

        
        //sets self.messagesRef
        self.observeMessagesForConversation(self.conversationId)
        
        //Send first welcome message
        self.messagesRef.childByAutoId().setValue(["sender":self.seatbotId, "text":self.welcomeMessage, "senderDisplayName":"Seat Bot", "timestamp":self.kFirebaseServerValueTimestamp])
    }
    
    func generateConversationId(otherUserId:String) -> String {
        return self.stripeCustomerId < otherUserId ? "\(self.stripeCustomerId)-\(otherUserId)" : "\(otherUserId)-\(self.stripeCustomerId)"
    }
    
    func sendMessage(senderId:String!, text:String!, senderDisplayName:String!) -> Void {
        self.messagesRef.childByAutoId().setValue(["sender":senderId, "text":text, "senderDisplayName":senderDisplayName, "timestamp":self.kFirebaseServerValueTimestamp])
        self.conversationRef.updateChildValues(["lastMessage":text])
        self.conversationRef.updateChildValues(["lastMessageTime": self.kFirebaseServerValueTimestamp])
        finishSendingMessage()
    }

    
    //MARK: - JSQMessageViewController Overrides
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        let authData = self.messagesRef.authData
        if authData != nil {
            self.sendMessage(senderId, text: text, senderDisplayName: senderDisplayName)
        }
        else {
            
            //firebase session expired, very rare.
            self.messagesRef.authAnonymouslyWithCompletionBlock({ (error, authData) -> Void in
                if error == nil {
                    self.observeMessagesForConversation(self.conversationId)
                    self.sendMessage(senderId, text: text, senderDisplayName: senderDisplayName)
                }
            })
        }
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
        let message = self.messages[indexPath.item] as JSQMessage
        if message.senderId != self.senderId {
            return self.incomingMessageAvatarImage
        }
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
            cell.textView.textColor = UIColor.whiteColor()
        }
        else {
            cell.textView.textColor = UIColor.blackColor()
        }
        
        cell.textView.linkTextAttributes = [NSForegroundColorAttributeName: cell.textView.textColor, NSUnderlineStyleAttributeName:1] //NSUnderlineStyle.StyleSingle
        
        return cell
    }
    
    
}
