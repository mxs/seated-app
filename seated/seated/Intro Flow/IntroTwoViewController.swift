//
//  IntroTwoViewController.swift
//  seated
//
//  Created by Michael Shang on 27/12/2014.
//  Copyright (c) 2014 Michael Shang. All rights reserved.
//

import UIKit

class IntroTwoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func newUser(sender: AnyObject) {
        let vc:UIViewController! = self.parentViewController
        if vc.isKindOfClass(IntroPageViewController) {
            (vc as IntroPageViewController).segueToSignup()
        }
    }
    
    @IBAction func currentUser(sender: AnyObject) {
        let vc:UIViewController! = self.parentViewController
        if vc.isKindOfClass(IntroPageViewController) {
            (vc as IntroPageViewController).segueToLogin()
        }
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
