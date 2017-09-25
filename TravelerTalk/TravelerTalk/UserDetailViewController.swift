//
//  UserDetailViewController.swift
//  TravelerTalk
//
//  Created by seokhyun kim on 2017-09-19.
//  Copyright © 2017 seokhyun kim. All rights reserved.
//

import UIKit
import Firebase

class UserDetailViewController: UIViewController {

    var users : UserProfiles?
    
    var snapShotKey : String?
    
    @IBOutlet weak var profileImage: UIImageView?
    
    @IBOutlet weak var userName: UILabel?
    
    @IBOutlet weak var userLocation: UILabel?
    
    @IBOutlet weak var statusMessage: UILabel?
    
    @IBAction func showChatControllerForUser(_ sender: Any) {
        guard let chatPartnerId = self.snapShotKey else {
            return
        }
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            guard let dictionary = snapshot.value as? [String: AnyObject]
                else {
                    return
            }
            let user = UserProfiles()
            user.id = chatPartnerId
            user.setValuesForKeys(dictionary)
//            self.showChatControllerForUser(user: user)
            let chatLogController = ChatLogController(collectionViewLayout : UICollectionViewFlowLayout())
            chatLogController.user = user
            self.navigationController?.pushViewController(chatLogController, animated: true)
        }, withCancel: nil)

//        chatLogController.user =
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("users.name", self.users?.userName ?? "error")
        receiveData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func receiveData() {
        guard let name = self.users?.userName else {
            return
        }
        self.userName?.text = name
        self.userLocation?.text = users?.userLocation
        self.statusMessage?.text = users?.statusMessage
        /*if let profileImageUrl = user.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithString(urlString: profileImageUrl)
        }*/
        if let profileImageUrl = users?.profileImageUrl {
            self.profileImage?.loadImageUsingCacheWithString(urlString: profileImageUrl)
        }
    }
    deinit {
        print("release this view in memory")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
