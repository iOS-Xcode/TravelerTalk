//
//  UsersTableViewController.swift
//  TravelerTalk
//
//  Created by seokhyun kim on 2017-09-17.
//  Copyright © 2017 seokhyun kim. All rights reserved.
//

import UIKit
import Firebase

class UsersTableViewController: UITableViewController {
    // First View Controller
    //    let cellId = "cellId"
    var users = [UserProfiles]()
    var snapShotKeys = Array<String>()
    var currentUserProfile : UserProfiles?
    
    @IBAction func handleLogout(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print("really?", logoutError)
        }
        
        guard let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else {
            return
        }
        loginViewController.usersTableViewController = self
        self.present(loginViewController, animated: true, completion: nil)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.users.removeAll()
        fetchUser()
        print("viewWillAppear")
        
    }
    override func viewDidLoad() {
        checkIfUserIsLoggedIn()
    }
    var snapShotKey : String?
    
    func fetchUser() {
        //Read on path and observe
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            print(snapshot)
            print("called")
            
            //A FIRDataSnapshot contains data from a Firebase Database location. Any time you read Firebase data, you receive the data as a FIRDataSnapshot.
            
            //Returns the contents of this data snapshot as native types. var value: Any? { get }
            if let dictionary = snapshot.value as? [String:AnyObject] {
                let user = UserProfiles()
                print("SNAP KEY", snapshot.key) //unique string
                self.snapShotKeys.append(snapshot.key)
                //                print("SNAP Value", snapshot.value) //dictionary
                //The key of the location that generated this FIRDataSnapshot.
                //                users.userName = snapshot.key
                
                //if you use this setter, your app will crash if your class properties don't exactly match up with the firebase dictionary keys
                //All of keys and values matching
                user.setValuesForKeys(dictionary)
                print("users = ", user)
                self.users.append(user)
                print("SEIF USER = ",self.users)
                //this will crash because of background thread, so lets use dispatch_async to fix
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
        self.fetchUserAndSetupNavBarTitle()
    }
    
        func checkIfUserIsLoggedIn() {
            //user is not logged in`
            if Auth.auth().currentUser?.uid == nil {
                perform(#selector(handleLogout), with: nil, afterDelay: 0)
            }
        }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else {
            //for some reason uid = nil
            return
        }
        //Read data only once without observe becouse of SingleEvent
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.navigationItem.title = dictionary["userName"] as? String
                self.currentUserProfile?.userName = dictionary["userName"] as? String
                let user = UserProfiles()
                user.setValuesForKeys(dictionary)
                self.setupNavBarWithUser(user: user)
            }
            
        }, withCancel: nil)
    }
    
    func setupNavBarWithUser(user: UserProfiles) {
        //tableView.reloadData()
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        //        titleView.backgroundColor = UIColor.red
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImageUsingCacheWithString(urlString: profileImageUrl)
        }
        containerView.addSubview(profileImageView)
        //iOS 9 constraint anchors
        //need x, y, width, height anchors
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        
        containerView.addSubview(nameLabel)
        nameLabel.text = user.userName
//        self.currentUserString = user.userName!
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        //need x, y, width, height anchors
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        self.navigationItem.titleView = titleView
        
        //        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        print("users.count", users.count)
//        if section == 1 {
//            return self.users.count - 1
//        } else {
//            return 1
//        }
        return users.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt")
        // let use a hack for now, we actually need to dequeue our cells for memory efficiency
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! UserCell
        let user = users[indexPath.row]
            cell.userName.text = user.userName
            cell.userLocation.text = user.userLocation
            cell.statusMessage.text = user.statusMessage
        print("user.id = ", user.id ?? "")
            if let profileImageUrl = user.profileImageUrl {
                cell.profileImageView.loadImageUsingCacheWithString(urlString: profileImageUrl)
            }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue_detail" {
            let cell = sender as! UserCell
            let path = self.tableView.indexPath(for: cell)
            let detailVC = segue.destination as? UserDetailViewController
            detailVC?.users = self.users[path!.row]
            detailVC?.snapShotKey = self.snapShotKeys[path!.row]
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "My Profile"
        } else {
            return "Frineds"
        }
    }
    
}
