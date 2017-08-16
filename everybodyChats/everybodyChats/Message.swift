//
//  Message.swift
//  everybodyChats
//
//  Created by seokhyun kim on 2017-08-14.
//  Copyright © 2017 seokhyun kim. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    var fromId: String?
    var text : String?
    var timestamp: NSNumber?
    var toId: String?
    
    func chatPartnerId() -> String? {
        return fromId == FIRAuth.auth()?.currentUser?.uid ? toId : fromId
    }
}
