//
//  PaymentViewController.swift
//  seated
//
//  Created by Michael Shang on 01/01/2015.
//  Copyright (c) 2015 Michael Shang. All rights reserved.
//

import UIKit


class PaymentViewController: UIViewController, PTKViewDelegate {

    @IBOutlet var paymentView:PTKView!
    @IBOutlet weak var finishButton: UIButton!
    var newUser:SeatedUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.paymentView = PTKView(frame: CGRectMake(15, 25, 290, 55))
        self.paymentView.delegate = self
        self.view.addSubview(self.paymentView)
        
        if self.newUser == nil {
            self.newUser = SeatedUser.currentUser()
        }
        
        //TODO: finishButton should be disabled by default
//        self.finishButton.enabled = false

    }

    // MARK: - PTKViewDelegate
    func paymentView(paymentView: PTKView!, withCard card: PTKCard!, isValid valid: Bool) {
        self.finishButton.enabled = valid
    }
    
    
    // MARK: - Actions
    @IBAction func finishPayment(sender: AnyObject) {
        if self.paymentView.card != nil {
            var card = STPCard()
            
            //TODO: Remove test card details for PROD
            card.number = "4000056655665556"
            card.expMonth = 12
            card.expYear = 2016
            card.cvc = "478"
//            card.number = self.paymentView.card.number
//            card.expMonth = self.paymentView.card.expMonth
//            card.expYear = self.paymentView.card.expYear
//            card.cvc = self.paymentView.card.cvc
            
            STPAPIClient.sharedClient().createTokenWithCard(card, completion: { (token, error) -> Void in
                if error != nil {
                    //TODO: handle create Strip token with card error
                }
                else {
                    self.createSubscriptWithToken(token)
                }
            })
        }
    }
    
    func createSubscriptWithToken(token: STPToken) -> Void {
        var params = ["tokenId" : token.tokenId, "email": self.newUser?.email]
        params["trial"] = self.newUser!.isAuthenticated() ? "no" : "yes" // params have to be [NSObject : AnyObject] and Bool is NOT AnyObject type
        
        PFCloud.callFunctionInBackground("createCustomerAndSubscribe", withParameters: params) { (result, error) -> Void in
            if error != nil {
                //TODO: handle create Strip customer and subscription error
            }
            else {
                
                if self.newUser != nil {
                    self.newUser?.stripeCustomerId = result["id"] as String
                    let subscriptions = result["subscriptions"] as NSDictionary
                    if let dataArray = subscriptions["data"] as? NSArray {
                        if dataArray.count > 0 {
                            if let data = dataArray[0] as? NSDictionary {
                                if let subscriptionId = data["id"] as? String {
                                    self.newUser?.subscriptionId = subscriptionId
                                }
                            }
                        }
                    }
                    
                    if self.newUser!.isAuthenticated() { //user re-subscribed
                        self.newUser?.saveInBackgroundWithBlock({ (saved, error) -> Void in
                            if error != nil {
                                self.newUser?.saveEventually()
                            }
                        })
                        self.createFirebaseUser(self.newUser!)
                        self.performSegueWithIdentifier("paymentSetupSuccessSegue", sender: self)
                    }
                    else {
                        self.newUser?.signUpInBackgroundWithBlock({ (success, error) -> Void in
                            if success {
                                //:TODO show alert with success then segue
                                
                                self.createFirebaseUser(self.newUser!)
                                self.performSegueWithIdentifier("paymentSetupSuccessSegue", sender: self)
                            }
                            else {
                                //TODO: handle create Parse customer error
                            }
                        })
                    }
                    
                }
            }
        }
    }
    
    func createFirebaseUser(user:SeatedUser) -> Void {
        let usersRef = Firebase(url:"https://seatedapp.firebaseio.com/users/\(user.stripeCustomerId)")
        usersRef.setValue([
            "email":user.email,
            "firstName":user["firstName"],
            "lastName":user["lastName"]
            ])
    }
}
