//
//  IntroViewController.swift
//  seated
//
//  Created by Michael Shang on 01/01/2015.
//  Copyright (c) 2015 Michael Shang. All rights reserved.
//

import UIKit

class IntroContentViewController: UIViewController {

    @IBOutlet weak var introMainCopyLabel: UILabel!
    @IBOutlet weak var introSubtextLabel: UILabel!
    
    var introMainCopy:String?
    var introSubText:String?
    
    override func viewDidLoad() {
        self.introMainCopyLabel.text = self.introMainCopy
        self.introSubtextLabel.text = self.introSubText
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
