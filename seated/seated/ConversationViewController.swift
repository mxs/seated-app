//
//  ConversationViewController.swift
//  seated
//
//  Created by Michael Shang on 03/01/2015.
//  Copyright (c) 2015 Michael Shang. All rights reserved.
//

import UIKit

class ConversationViewController: UIViewController {
    
    let seatbotId = "seatbot"
    let welcomeMessage = "Hi there, welcome to seated!"
    var stripeCustomerId:String!
    var messagesRef:Firebase!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        Firebase.setOption("persistence", to: true)

        self.stripeCustomerId = PFUser.currentUser()["stripeCustomerId"] as String
        self.setupFirebase()
    }
    
    @IBAction func sendMessage(send:AnyObject) {
        self.messagesRef.childByAutoId().setValue(["sender":self.stripeCustomerId, "text":"stand by me"])
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
        let userStripeId = PFUser.currentUser()["stripeCustomerId"] as String
        
        if userStripeId < otherUserId {
            return userStripeId + "-" + otherUserId
        }
        else {
            return otherUserId + "-" + userStripeId
        }

    }
    
}
