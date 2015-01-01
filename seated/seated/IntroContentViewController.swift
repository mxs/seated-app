//
//  IntroViewController.swift
//  seated
//
//  Created by Michael Shang on 01/01/2015.
//  Copyright (c) 2015 Michael Shang. All rights reserved.
//

import UIKit

class IntroContentViewController: UIViewController {

    @IBOutlet weak var introLabel: UILabel!
    
    var introCopy:String?
    
    override func viewDidLoad() {
        println(self.introLabel)
        self.introLabel.text = self.introCopy
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
