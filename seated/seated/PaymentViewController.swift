//
//  PaymentViewController.swift
//  seated
//
//  Created by Michael Shang on 01/01/2015.
//  Copyright (c) 2015 Michael Shang. All rights reserved.
//

import UIKit


class PaymentViewController: UIViewController, PTKViewDelegate {

    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var paymentViewContainer: UIView!
    @IBOutlet weak var renewLabel: UILabel!
    var paymentView:PTKView!
    var renewSubscription:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Credit Card"
        
        self.paymentViewContainer.backgroundColor = UIColor.clearColor()
        self.paymentView = PTKView(frame: CGRectMake(0, 0, 290, 46))
        self.paymentView.delegate = self
        self.paymentViewContainer.addSubview(self.paymentView)

        self.finishButton.setTitleColor(UIColor.textColour(), forState: UIControlState.Normal)
        self.finishButton.setBackgroundImage(UIImage.imageWithColor(UIColor.primaryColour()), forState: UIControlState.Normal)
        self.finishButton.layer.cornerRadius = 5.0
        self.finishButton.layer.masksToBounds = true
        self.finishButton.enabled = false
       
        self.renewLabel.hidden = !self.renewSubscription
        if !self.renewSubscription {
            self.finishButton.setTitle("Update", forState: UIControlState.Normal)
        }
        else {
            self.finishButton.setTitle("Re-subscribe", forState: UIControlState.Normal)
        }
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
//            card.number = "5555555555554444"
            card.number = "4000056655665556"
            card.expMonth = 12
            card.expYear = 2016
            card.cvc = "478"
            
//            card.number = self.paymentView.card.number
//            card.expMonth = self.paymentView.card.expMonth
//            card.expYear = self.paymentView.card.expYear
//            card.cvc = self.paymentView.card.cvc
//            STPAPIClient.sharedClient().createTokenWithCard(self.paymentView.card, completion: { (token, error) -> Void in

            SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Black)
            
            STPAPIClient.sharedClient().createTokenWithCard(card, completion: { (token, error) -> Void in
                if error != nil {
                    //TODO: handle create Strip token with card error
                }
                else {
                    if self.renewSubscription {
                        self.renewSubscription(token)
                    }
                    else {
                        self.updateCardForCustomerWithToken(token)
                    }
                }
            })
        }
    }
    
    func updateCardForCustomerWithToken(token:STPToken) -> Void {
        var params = ["token_id" : token.tokenId, "customer_id": SeatedUser.currentUser().stripeCustomerId]
        if SeatedUser.currentUser().cardId != nil {
            params["card_id"] = SeatedUser.currentUser().cardId
        }

        PFCloud.callFunctionInBackground("updateCustomerCard", withParameters: params) { (result, error) -> Void in
            if error == nil {
                SeatedUser.currentUser().cardId = result["card_id"] as? String
                SeatedUser.currentUser().cardLabel = result["card_label"] as? String
                SeatedUser.currentUser().saveInBackgroundWithBlock({ (success, error) -> Void in
                    if !success {
                        SeatedUser.currentUser().saveEventually(nil)
                    }
                })
                SVProgressHUD.showSuccessWithStatus("Updated!")
                self.performSegueWithIdentifier("unwindToSettingsSegue", sender: self)
            }
            else {
                //TODO: handle create Stripe customer and subscription error
            }
        }
    }
    
    func renewSubscription(token:STPToken) {
        let user = SeatedUser.currentUser()
        var params = ["token" : token.tokenId, "customer_id": user.stripeCustomerId]
        PFCloud.callFunctionInBackground("createSubscription", withParameters: params) { (subscriptionData, error) -> Void in
            if error == nil {
                var subscription = Subscription()
                subscription.update(subscriptionData as NSDictionary)
                //have to repin as its a new object
                subscription.pinInBackgroundWithBlock({ (success, error) -> Void in
                    //success
                })
                subscription.saveEventually(nil)
                user.subscription = subscription
                user.cardId = subscriptionData["card_id"] as? String
                user.cardLabel = subscriptionData["card_label"] as? String
                user.saveEventually(nil)

                SVProgressHUD.showSuccessWithStatus("Subscription Renewed")
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
}
