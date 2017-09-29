//
//  NewMessageController.swift
//  everybodyChats
//
//  Created by seokhyun kim on 2017-08-08.
//  Copyright © 2017 seokhyun kim. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {
    let cellId = "cellId"
    
    var users = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()
        print("newMessageController")
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        fetchUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear in NewMessageController")
    }
    
    func fetchUser() {
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] {
                let user = User()
                user.id = snapshot.key
                //if you use this setter, your app will crash if your class properties don't exactly match up with the firebase dictionary keys
                user.setValuesForKeys(dictionary)
                self.users.append(user)
                //this will crash because of background thread, so lets use dispatch_async to fix
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            //print(snapshot)
        }, withCancel: nil)
    }
    func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // let use a hack for now, we actually need to dequeue our cells for memory efficiency
        //        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        //        cell.imageView?.image = UIImage(named: "profileIcon")
        //        cell.imageView?.contentMode = .scaleAspectFill
        
        if let profileImageUrl = user.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithString(urlString: profileImageUrl)
            //            let url = URL(string: profileImageUrl)
            //            URLSession.shared.dataTask(with: url!, completionHandler: { (data, responese, error) in
            //
            //                //download hit an error so lets return out
            //                if error != nil {
            //                    print(error ?? String())
            //                    return
            //                }
            //                DispatchQueue.main.async{
            ////                    cell.imageView?.image = UIImage(data: data!)
            //                    cell.profileImageView.image = UIImage(data: data!)
            //                }
            ////                cell.imageView?.image = UIImage(data: data!)
            //            }).resume()
            
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    var messagesController: MessagesController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true, completion: { Void in
            let user = self.users[indexPath.row]
            self.messagesController?.showChatControllerForUser(user: user)
        })
    }
}


