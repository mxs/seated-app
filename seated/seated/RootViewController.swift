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
    
    let introMainCopyOne = "No more chasing dinner reservations."
    let introMainCopyTwo = "Need some ideas?"
    let introMainCopyThree = "Give it a try!"
    let introSubtextOne = "Send us a message and we will get your booked."
    let introSubtextTwo = "We can provide suggestions based on cuisine and location, always here to help."
    let introSubtextThree = "Help with something other than dinner reservations? You might be pleasantly surprised."
    var pageViewController:UIPageViewController?
    var introContentVCs: [IntroContentViewController]!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.introContentVCs = self.createIntroContentViewControllers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pageControl.numberOfPages = self.introContentVCs.count
        if let pageVC = self.pageViewController {
            pageVC.setViewControllers([self.introContentVCs[0]], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        }
        
        self.signupButton.setTitleColor(UIColor.textColour(), forState: UIControlState.Normal)
        self.signupButton.setBackgroundImage(UIImage.imageWithColor(UIColor.primaryColour()), forState: UIControlState.Normal)
        self.signupButton.layer.cornerRadius = 5.0
        self.signupButton.layer.masksToBounds = true

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

}
