//
//  UserCell.swift
//  TravelerTalk
//
//  Created by seokhyun kim on 2017-09-18.
//  Copyright © 2017 seokhyun kim. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var userLocation: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
//            profileImageView.translatesAutoresizingMaskIntoConstraints = false
            profileImageView.layer.cornerRadius = 37
            profileImageView.layer.masksToBounds = true
//            profileImageView.contentMode = .scaleAspectFill
        }
    }
    @IBOutlet weak var statusMessage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
