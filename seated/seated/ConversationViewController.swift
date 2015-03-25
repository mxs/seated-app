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
    let welcomeMessage = "Hi there, welcome to Seated!"
    
    var user:SeatedUser!
    var conversationId:String!
    var messagesRef:Firebase!
    var conversationRef:Firebase!
    var unreadCountRef:Firebase!
    var conversation:Conversation?
    var messages = [JSQMessage]()
    var outgoingMessageBubbleImage:JSQMessagesBubbleImage!
    var incomingMessageBubbleImage:JSQMessagesBubbleImage!
    var incomingMessageAvatarImage:JSQMessagesAvatarImage!
    var participants:[String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var navBar = self.navigationController?.navigationBar
        navBar?.barTintColor = UIColor.primaryColour()
        navBar?.tintColor = UIColor.textColour()
        navBar?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.textColour()]
        
        Firebase.setOption("persistence", to: true)
        
        self.user = SeatedUser.currentUser()
        if self.user.isAdmin {
            self.title = self.conversation?.title
            self.conversationId = self.conversation?.id
            self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
            self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        }
        else {
            self.updateTitle()
           
            self.incomingMessageAvatarImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "incoming-avatar"), diameter: 40)
            self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize(width:40.0, height:40.0)
            self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        }

        self.outgoingMessageBubbleImage = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.primaryColour())
        self.incomingMessageBubbleImage = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        self.inputToolbar.contentView.leftBarButtonItem = nil
        self.senderId = self.user.email
        self.senderDisplayName = SeatedUser.currentUser().displayName
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.jsq_defaultTypingIndicatorImage(), style: UIBarButtonItemStyle.Bordered, target: self, action: "showSettings")
        
        self.checkFirebaseAuth()
        
        if !self.user.isAdmin {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateTitle"), name: "ConfigUpdated", object: nil)
        }
     
        self.setupFirstTimerOverlay()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.removeFirebaseObservers()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        clearUnreadCount()
    }
    
    func checkFirebaseAuth() {
        if FirebaseAuthObserver.sharedInstance.isAuthenticated {
            self.setupFirebase()
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("setupFirebase"), name: FirebaseAuthObserver.sharedInstance.kFirebaseConnected, object: nil)
        FirebaseAuthObserver.sharedInstance.startObserver()
    }
    
    // Sets up new user or starts listening to messages in current conversations
    func setupFirebase() -> Void {
        self.removeFirebaseObservers()
        let userConversationsRef = Firebase(url:"https://\(Firebase.applicationName).firebaseio.com/users/\(self.user.firebaseId)/conversations")
        var firstRun = true
        userConversationsRef.observeEventType(FEventType.Value, withBlock: { (snapshot) -> Void in
            if firstRun { //HACK to get around this: http://stackoverflow.com/a/24516952/919533
                if snapshot.hasChildren() {
                    
                    //assume only one conversation for customer
                    if self.conversationId == nil && !SeatedUser.currentUser().isAdmin {
                        self.conversationId = (snapshot.value as NSDictionary).allKeys[0] as String
                    }
                    self.conversationRef = Firebase(url: "https://\(Firebase.applicationName).firebaseio.com/conversations/\(self.conversationId)")
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
        let seatbotConversationRef = Firebase(url: "https://\(Firebase.applicationName).firebaseio.com/users/\(self.seatbotId)/conversations")
        seatbotConversationRef.childByAppendingPath(self.conversationId).setValue(true)
        
        self.conversationRef = Firebase(url: "https://\(Firebase.applicationName).firebaseio.com/conversations/\(self.conversationId)")
        conversationRef.childByAppendingPath("/title").setValue(SeatedUser.currentUser().displayName)
        conversationRef.childByAppendingPath("/lastMessage").setValue(self.welcomeMessage)
        conversationRef.childByAppendingPath("/lastMessageTime").setValue(self.kFirebaseServerValueTimestamp)
        conversationRef.childByAppendingPath("/participants/\(self.user.firebaseId)").setValue(["unread-count":0])
        conversationRef.childByAppendingPath("/participants/\(self.seatbotId)").setValue(["unread-count":0])
        
        //sets self.messagesRef
        self.observeMessagesForConversation(self.conversationId)
        
        //Send first welcome message
        self.messagesRef.childByAutoId().setValue(["sender":self.seatbotId, "text":self.welcomeMessage, "senderDisplayName":"Seat Bot", "timestamp":self.kFirebaseServerValueTimestamp])
    }

    
    func observeMessagesForConversation(conversationId:String) -> Firebase {
        self.messagesRef = Firebase(url: "https://\(Firebase.applicationName).firebaseio.com/messages/\(conversationId)")
        self.messagesRef.observeEventType(FEventType.ChildAdded, withBlock: { (snapshot) -> Void in
            let senderId = snapshot.value["sender"] as String
            let senderDisplayName = snapshot.value["senderDisplayName"] as String
            let text = snapshot.value["text"] as String
            let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
            self.messages.append(message)
            self.finishReceivingMessage()
        })
        
        self.observeUnreadCount()
        
        self.setParticipants()
        
        return self.messagesRef
    }
    
    func observeUnreadCount() {
        self.unreadCountRef = Firebase(url:"https://\(Firebase.applicationName).firebaseio.com/conversations/\(self.conversationId)/participants/\(self.user.firebaseId)/unread-count")
        self.unreadCountRef.observeEventType(FEventType.Value, withBlock: { (snapshot) -> Void in
            
            //only clear if current view is the top view and count is greater than zero
            if self.view.window != nil {
                if snapshot.value as Int > 0 {
                    self.clearUnreadCount()
                }
            }
        })
    }
    
    func generateConversationId(otherUserId:String) -> String {
        return self.user.firebaseId < otherUserId ? "\(self.user.firebaseId)-\(otherUserId)" : "\(otherUserId)-\(self.user.firebaseId)"
    }
    
    func sendMessage(senderId:String!, text:String!, senderDisplayName:String!) -> Void {
        self.messagesRef.childByAutoId().setValue(["sender":senderId, "text":text, "senderDisplayName":senderDisplayName, "timestamp":self.kFirebaseServerValueTimestamp])
        self.conversationRef.updateChildValues(["lastMessage":text])
        self.conversationRef.updateChildValues(["lastMessageTime": self.kFirebaseServerValueTimestamp])
        incrementUnreadCount()
        sendPushNotification(text)
        incrementUserMessageCount()
        finishSendingMessage()
        Flurry.logEvent("Message_Sent")
    }
    
    //This version doesn't reload the scroll view compared to the super version, nor does it scroll to the bottom.
    //Those calls are unnecessary since using Firebase with persistence turned will fire the observer immediately and in the receiving code
    //the collection view reloading and scrolling happens.
    override func finishSendingMessageAnimated(animate:Bool) {
        var textView = self.inputToolbar.contentView.textView
        textView.text = nil
        textView.undoManager?.removeAllActions()
        
        self.inputToolbar.toggleSendButtonEnabled()
        NSNotificationCenter.defaultCenter().postNotificationName(UITextViewTextDidChangeNotification, object: textView)
    }
    
    func incrementUserMessageCount() {
        let messagesCountRef = Firebase(url: "https://\(Firebase.applicationName).firebaseio.com/users/\(self.user.firebaseId)/messagescount")
        messagesCountRef.runTransactionBlock { (currentData) -> FTransactionResult! in
            var value = currentData.value as? Int
            if value == nil {
                value = 0
            }
            currentData.value = value! + 1
            return FTransactionResult.successWithValue(currentData)
        }
    }
    
    func sendPushNotification(message:String) {
        for participant in self.participants {
            if participant != self.user.firebaseId {
                var push = PFPush()
                push.setChannel(participant)
                push.setData(["alert":message, "badge":"Increment", "sound":"clink.caf"])
                push.sendPushInBackgroundWithBlock { (success, error) -> Void in
                    //success
                }
            }
        }
    }
    
    func incrementUnreadCount() -> Void {
        var recipientId:String?
        if self.conversation != nil { //admin mode
            for firebaseId in self.conversation!.participants.allKeys {
                if firebaseId as? String != self.user.firebaseId {
                    recipientId = firebaseId as? String
                }
            }
        }
        else {
            recipientId = self.seatbotId
        }

        let unreadRef = self.conversationRef.childByAppendingPath("/participants/\(recipientId!)/unread-count")
        unreadRef.runTransactionBlock { (currentData:FMutableData!) -> FTransactionResult! in
            var count = currentData.value as? Int
            if count == nil {
                count = 0
            }
            else {
                currentData.value = count! + 1
            }
            return FTransactionResult.successWithValue(currentData)
        }
    }
    
    func clearUnreadCount() {
        if self.unreadCountRef != nil {
            self.unreadCountRef.runTransactionBlock { (currentData:FMutableData!) -> FTransactionResult! in
                currentData.value = 0
                return FTransactionResult.successWithValue(currentData)
            }
        }
    }
    
    func removeFirebaseObservers() {
        if self.messagesRef != nil {
            self.messagesRef.removeAllObservers()
        }

        if self.conversationRef != nil {
            self.conversationRef.removeAllObservers()
        }
        
        if self.unreadCountRef != nil {
            self.unreadCountRef.removeAllObservers()
        }
    }
    
    func setParticipants() {
        self.conversationRef.childByAppendingPath("/participants").observeSingleEventOfType(FEventType.Value, withBlock: { (snapshot) -> Void in
            if snapshot.hasChildren() {
                self.participants = snapshot.value.allKeys as [String]
            }
        })
    }
    
    //MARK: - JSQMessageViewController Overrides
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.sendMessage(senderId, text: text, senderDisplayName: senderDisplayName)
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
            cell.textView.textColor = UIColor.textColour()
        }
        else {
            cell.textView.textColor = UIColor.blackColor()
        }
        
        cell.textView.linkTextAttributes = [NSForegroundColorAttributeName: cell.textView.textColor, NSUnderlineStyleAttributeName:1] //NSUnderlineStyle.StyleSingle
        
        return cell
    }
    
    //MARK: - Misc
    func setupFirstTimerOverlay() {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let shownOverlay = defaults.boolForKey("shown_intro_overlay")
        
        if !shownOverlay {
            let loadedViews = NSBundle.mainBundle().loadNibNamed("overlay", owner: self, options: nil)
            let v = loadedViews.last as UIView
            let touch = UITapGestureRecognizer(target: self, action: Selector("dismissOverlay:"))
            v.addGestureRecognizer(touch)
            
            v.frame = self.navigationController!.view.bounds
            self.navigationController?.view.addSubview(v)
            
            defaults.setBool(true, forKey: "shown_intro_overlay")
        }
    }
    
    func dismissOverlay(gesture:UIGestureRecognizer) {
        gesture.view?.removeFromSuperview()
    }
    
    func showSettings() {
        self.performSegueWithIdentifier("settingsSegue", sender: self)
    }

    func updateTitle() {
        let config = PFConfig.currentConfig()
        let titles = config["conversation_titles"] as NSArray
        let index = arc4random_uniform(UInt32(titles.count))
        self.title = titles[Int(index)] as? String
    }
    
    
}
