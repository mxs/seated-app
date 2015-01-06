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
    var connected:Bool!
    var stripeCustomerId:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        Firebase.setOption("persistence", to: true)

        self.stripeCustomerId = PFUser.currentUser()["stripeCustomerId"] as String
        
        var connectedRef = Firebase(url:"https://seatedapp.firebaseio.com/.info/connected")
        connectedRef.observeEventType(.Value, withBlock: { snapshot in
            self.connected = snapshot.value as? Bool!
            if self.connected != nil && self.connected! {
                println("Connected")
            } else {
                println("Not connected")
            }
        })
        
//        let ref = Firebase(url:"https://seatedapp.firebaseio.com/conversations")
//        ref.authAnonymouslyWithCompletionBlock { error, authData in
//            if error != nil {
//                println(error)
//            }
//            else {
//                println(authData)
//            }
//        }
    }
    
    @IBAction func sendMessage(send:AnyObject) {
        self.sendGreetingMessageFromSeatBot("cus_5SKZlCsS64s4iK-seatbot")
    }
    
    @IBAction func createConversation(sender: AnyObject) {
        self.currentConversationExists()
    }
    
    @IBAction func createBob(sender: AnyObject) {
        let usersRef = Firebase(url:"https://seatedapp.firebaseio.com/users/\(self.stripeCustomerId)")
        usersRef.setValue([
            "email":"bobby@gmail.com",
            "firstName:":"Bobby",
            "lastName:":"Valentino"
        ])
    }
    
    func sendGreetingMessageFromSeatBot(conversationId:String) -> Void {
        let messagesRef = Firebase(url: "https://seatedapp.firebaseio.com/messages/\(conversationId)")
        messagesRef.observeEventType(FEventType.ChildAdded, withBlock: { (snapshot) -> Void in
            println(snapshot.value)
        })
        messagesRef.childByAutoId().setValue(["sender:":self.seatbotId, "text":self.welcomeMessage])
    }
    
    func currentConversationExists() -> Void {

        let userConversationsRef = Firebase(url:"https://seatedapp.firebaseio.com/users/\(self.stripeCustomerId)/conversations")
        userConversationsRef.observeSingleEventOfType(FEventType.Value, withBlock: { (snapshot) -> Void in
            if snapshot.hasChildren() {
                println(snapshot.value)
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
    

    @IBAction func logout(sender: AnyObject) {
        PFUser.logOut()
        self.performSegueWithIdentifier("logoutSegue", sender: self)
    }
}
