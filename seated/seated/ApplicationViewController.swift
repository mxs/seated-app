//
//  ApplicationViewController.swift
//  seated
//
//  Created by Michael Shang on 26/12/2014.
//  Copyright (c) 2014 Michael Shang. All rights reserved.
//

import UIKit

class ApplicationViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
//        self.performSegueWithIdentifier("loginSegue", sender:self)
        self.performSegueWithIdentifier("introSegue", sender:self)
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "introSegue" {
            
//            if segue.destinationViewController.isKindOfClass(UIPageViewController) {

//                (segue.destinationViewController as UIPageViewController).setViewControllers([introOneVC], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)

//                (segue.destinationViewController as UIPageViewController).setViewControllers([introTwoVC], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)

//            }

        }
    }
    
   


}
