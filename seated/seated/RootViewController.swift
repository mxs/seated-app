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
        let introTexts = ["Intro One", "Intro Two", "Intro Three"]
        var introContentVCs:[IntroContentViewController] = []
        for text in introTexts {
            var introContentVC = IntroContentViewController(nibName: "IntroContentViewController", bundle:NSBundle.mainBundle())
            introContentVC.introCopy = text
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
    }
    
    //Only used to unwind segues to this view controller
    @IBAction func prepareForSegueUnwind(storyBoardSegue:UIStoryboardSegue) {
        
    }

}
