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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.paymentView = PTKView(frame: CGRectMake(15, 25, 290, 55))
        self.paymentView.delegate = self
        self.view.addSubview(self.paymentView)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
