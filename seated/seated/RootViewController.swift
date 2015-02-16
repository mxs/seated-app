//
//  IntroViewController.swift
//  seated
//
//  Created by Michael Shang on 31/12/2014.
//  Copyright (c) 2014 Michael Shang. All rights reserved.
//

import UIKit

class RootViewController: UIViewController, UIPageViewControllerDataSource {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var signupButton: UIButton!
    
    var introMainCopyOne = "No more chasing dinner reservations."
    var introMainCopyTwo = "Need some ideas?"
    var introMainCopyThree = "Try for free."
    var introSubtextOne = "Send us a message and we will get your table booked."
    var introSubtextTwo = "We can provide suggestions based on cuisine and location, always here to help."
    var introSubtextThree = "No credit card required to try, $5 a month after first month, cancel anytime."
    var pageViewController:UIPageViewController?
    var introContentVCs: [IntroContentViewController]!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.signupButton.setTitleColor(UIColor.textColour(), forState: UIControlState.Normal)
        self.signupButton.setBackgroundImage(UIImage.imageWithColor(UIColor.primaryColour()), forState: UIControlState.Normal)
        self.signupButton.layer.cornerRadius = 5.0
        self.signupButton.layer.masksToBounds = true

        let config = PFConfig.currentConfig()
        if config["intro_one_copy"] != nil {
            updateIntros(config)
        }
        self.introContentVCs = self.createIntroContentViewControllers()
        self.pageControl.numberOfPages = self.introContentVCs.count
        if let pageVC = self.pageViewController {
            pageVC.setViewControllers([self.introContentVCs[0]], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("configUpdated"), name: "ConfigUpdated", object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {

        let vcIndex = find(self.introContentVCs, viewController as IntroContentViewController)
        self.pageControl.currentPage = vcIndex!
        
        let prevIndex = vcIndex! - 1
        if prevIndex < 0 {
            return nil
        }
        else {
            let vc = self.introContentVCs[prevIndex] as UIViewController
            return vc
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let vcIndex = find(self.introContentVCs, viewController as IntroContentViewController)
        self.pageControl.currentPage = vcIndex!

        let nextIndex = vcIndex! + 1
        if nextIndex == self.introContentVCs.count {
            return nil
        }
        else {
            let vc = self.introContentVCs[nextIndex] as UIViewController
            return vc
        }
    }
    
    func createIntroContentViewControllers() -> [IntroContentViewController] {
        let introMainCopies = [self.introMainCopyOne, self.introMainCopyTwo, self.introMainCopyThree]
        let introSubtexts = [self.introSubtextOne, self.introSubtextTwo, self.introSubtextThree]
        var introContentVCs:[IntroContentViewController] = []
        for var i = 0; i < introMainCopies.count; i++ {
            let mainCopy = introMainCopies[i]
            let subtext = introSubtexts[i]
            var introContentVC = IntroContentViewController(nibName: "IntroContentViewController", bundle:NSBundle.mainBundle())
            introContentVC.introMainCopy = mainCopy
            introContentVC.introSubText = subtext
            introContentVCs.append(introContentVC)
        }
        
        return introContentVCs
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pageViewControllerSegue" {
            var destVC = segue.destinationViewController as UIPageViewController
            destVC.dataSource = self
            self.pageViewController = destVC
        }
        else if segue.destinationViewController.conformsToProtocol(BlurBackgroundProtocol) {
            var destVC = segue.destinationViewController as? BlurBackgroundProtocol
            destVC?.blurredBackgroundImage = takeSnapshotAndBlur(self.view)
        }
        
        if segue.identifier == "signupSegue" {
            Flurry.logEvent("Signup_Pressed")
        }
    }
    
    //Only used to unwind segues to this view controller
    @IBAction func prepareForSegueUnwind(storyBoardSegue:UIStoryboardSegue) {
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func takeSnapshotAndBlur(view:UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, true, 1)
        view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let blurImage = screenshot.applyBlurWithRadius(30, tintColor: UIColor.whiteColor().colorWithAlphaComponent(0.2), saturationDeltaFactor: 1.5, maskImage: nil)
        return blurImage
    }
    
    func updateIntros(config:PFConfig) {
        self.introMainCopyOne = config["intro_one_copy"] as String
        self.introSubtextOne = config["intro_one_subtext"] as String
        self.introMainCopyTwo = config["intro_two_copy"] as String
        self.introSubtextTwo = config["intro_two_subtext"] as String
        self.introMainCopyThree = config["intro_three_copy"] as String
        self.introSubtextThree = config["intro_three_subtext"] as String
    }
    
    func configUpdated() {
        let config = PFConfig.currentConfig()
        self.updateIntros(config)
        let introMainCopies = [self.introMainCopyOne, self.introMainCopyTwo, self.introMainCopyThree]
        let introSubtexts = [self.introSubtextOne, self.introSubtextTwo, self.introSubtextThree]
        for var i = 0; i < introMainCopies.count; i++ {
            let mainCopy = introMainCopies[i]
            let subtext = introSubtexts[i]
            println(mainCopy)
            var introContentVC = self.introContentVCs[i] as IntroContentViewController
            introContentVC.introMainCopy = mainCopy
            introContentVC.introSubText = subtext
            introContentVC.updateLabels()
        }
    }

}
