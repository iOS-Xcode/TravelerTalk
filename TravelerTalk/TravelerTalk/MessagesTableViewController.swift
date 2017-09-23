//
//  MessagesViewController.swift
//  TravelerTalk
//
//  Created by seokhyun kim on 2017-09-19.
//  Copyright © 2017 seokhyun kim. All rights reserved.
//

import UIKit
import Firebase

class MessagesTableViewController: UITableViewController {
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewDidLoad")
//        self.tableView.reloadData()
        self.observeUserMessages()
        // Do any additional setup after loading the view.
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        let message = self.messages[indexPath.row]
        //remove all of messages from the chatPartnerId
        if let chatPartnerId = message.chatPartnerId() {
            FIRDatabase.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue(completionBlock: ({ (error, ref) in
                if error != nil {
                    print("Failed to delete message:", error ?? "")
                }
                self.messagesDictionary.removeValue(forKey: chatPartnerId)
                self.attemptReloadOfTable()
                
            }) )
        }
    }
    
    var timer : Timer?
    
    private func fetchMessageWithMessageId(messageId: String) {
        let messagesReference = FIRDatabase.database().reference().child("messages").child(messageId)
        messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message(dictionary: dictionary)
                
                if let chatPartnerId = message.chatPartnerId() {
                    self.messagesDictionary[chatPartnerId] = message
                    
                }
                self.attemptReloadOfTable()
            }
            
        }, withCancel: nil)
    }
    
    private func attemptReloadOfTable() {
        //This method is the only way to remove a timer from an RunLoop object.
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    @objc func handleReloadTable() {
        //Array(sequence)
        self.messages = Array(self.messagesDictionary.values)
        //Sort descending
        self.messages.sort(by: {(message1, message2) -> Bool in
            return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
        })
        //this will crash because of background thread, so lets call this on dispatch_async main thread
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            //for some reason uid = nil
            return
        }
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.navigationItem.title = dictionary["name"] as? String
                let user = UserProfiles()
                user.setValuesForKeys(dictionary)
                self.setupNavBarWithUser(user: user)
            }
            
        }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(messages.count)
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! MessageCell
        let message = messages[indexPath.row]
        cell.message = message
        print("MessageViewController")
//        cell.lastMessage?.text = message
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        let ref = FIRDatabase.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            guard let dictionary = snapshot.value as? [String: AnyObject]
                else {
                    return
            }
            let user = UserProfiles()
            user.id = chatPartnerId
            user.setValuesForKeys(dictionary)
            self.showChatControllerForUser(user: user)
        })
    }
    
    func setupNavBarWithUser(user: UserProfiles) {
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        observeUserMessages()
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImageUsingCacheWithString(urlString: profileImageUrl)
        }
//        self.navigationItem.titleView = titleView
        
        //        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
    }
    
    func showChatControllerForUser(user: UserProfiles) {
        let chatLogController = ChatLogController(collectionViewLayout : UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
        
    }
    
    func observeUserMessages() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            let userId = snapshot.key
            FIRDatabase.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                let messageId = snapshot.key
                self.fetchMessageWithMessageId(messageId: messageId)
            }, withCancel: nil)
        }, withCancel: nil)
        ref.observe(.childRemoved, with: { (snapshot) in
            print(snapshot.key)
            print(self.messagesDictionary)
            self.messagesDictionary.removeValue(forKey: snapshot.key)
            self.attemptReloadOfTable()
        }, withCancel: nil)
    }
    
}
