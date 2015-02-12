//
//  ConversationTableViewCell.swift
//  seated
//
//  Created by Michael Shang on 19/01/2015.
//  Copyright (c) 2015 Michael Shang. All rights reserved.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var unreadCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.unreadCountLabel.layer.cornerRadius = 10.0
        self.unreadCountLabel.layer.masksToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
