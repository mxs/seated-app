//
//  IntroPageViewController.swift
//  seated
//
//  Created by Michael Shang on 27/12/2014.
//  Copyright (c) 2014 Michael Shang. All rights reserved.
//

import UIKit

class IntroPageViewController: UIPageViewController , UIPageViewControllerDataSource {

    let introOneVC = IntroOneViewController(nibName:"IntroOneViewController", bundle:NSBundle.mainBundle())
    let introTwoVC = IntroTwoViewController(nibName:"IntroTwoViewController", bundle:NSBundle.mainBundle())
    var index = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.setViewControllers([introOneVC], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
    }
    
    // MARK: - UIPageViewControllerDataSource

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {

        if viewController == self.introOneVC {
            return nil
        }
        else {
            self.index = 0
            return self.introOneVC
        }
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        if viewController == self.introOneVC {
            self.index = 1
            return self.introTwoVC
        }
        else {
            return nil
        }
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 2
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.index
    }
    
    func segueToSignup() {
        self.performSegueWithIdentifier("signupFromIntroSegue", sender: self)
    }
    
    func segueToLogin() {
        self.performSegueWithIdentifier("loginFromIntroSegue", sender: self)
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
