//
//  MessageCell.swift
//  TravelerTalk
//
//  Created by seokhyun kim on 2017-09-19.
//  Copyright © 2017 seokhyun kim. All rights reserved.
//

import UIKit
import Firebase

class MessageCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var lastMessage: UILabel?
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    var message: Message? {
        didSet {
            setupNameAndProfileImage()
            lastMessage?.text = message?.text
            print("lastMessage = ",(lastMessage?.text)!)
            if let seconds = message?.timestamp?.doubleValue {
                let timestampDate = NSDate.init(timeIntervalSince1970: seconds)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                timeLabel.text = dateFormatter.string(from: timestampDate as Date)
            }
        }
    }
    
    private func setupNameAndProfileImage() {
        
        if let id = message?.chatPartnerId() {
            let ref = Database.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.userName.text = dictionary["userName"] as? String
                    if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                        self.profileImageView.loadImageUsingCacheWithString(urlString: profileImageUrl)
                    }
                    
                }
            }, withCancel: nil)
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
