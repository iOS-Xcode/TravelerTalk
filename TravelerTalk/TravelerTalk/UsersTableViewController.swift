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
    
    //    let cellId = "cellId"
    var users = [UserProfiles]()
    var snapShotKeys = Array<String>()
    
    @IBAction func handleLogout(_ sender: Any) {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print("really?", logoutError)
        }
        
        guard let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else {
            return
        }
        loginViewController.usersTableViewController = self
        self.present(loginViewController, animated: true, completion: nil)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUser()
        checkIfUserIsLoggedIn()
    }
    var snapShotKey : String?
    
    func fetchUser() {
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            print(snapshot)
            print("called")
            //A FIRDataSnapshot contains data from a Firebase Database location. Any time you read Firebase data, you receive the data as a FIRDataSnapshot.
            
            //Returns the contents of this data snapshot as native types. var value: Any? { get }
            if let dictionary = snapshot.value as? [String:AnyObject] {
                let users = UserProfiles()
                print("SNAP KEY", snapshot.key) //unique string
                self.snapShotKeys.append(snapshot.key)
//                print("SNAP Value", snapshot.value) //dictionary
                //The key of the location that generated this FIRDataSnapshot.
                //                users.userName = snapshot.key
                
                //if you use this setter, your app will crash if your class properties don't exactly match up with the firebase dictionary keys
                users.setValuesForKeys(dictionary)
                print("users = ", users)
                self.users.append(users)
                print("SEIF USER = ",self.users)
                //this will crash because of background thread, so lets use dispatch_async to fix
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    func checkIfUserIsLoggedIn() {
        //user is not logged in`
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        } else {
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            //for some reason uid = nil
            return
        }
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.navigationItem.title = dictionary["userName"] as? String
//                print("userName.navi = ", self.navigationItem.title)
                let user = UserProfiles()
                user.setValuesForKeys(dictionary)
                //                self.setupNavBarWithUser(user: user)
            }
            
        }, withCancel: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // let use a hack for now, we actually need to dequeue our cells for memory efficiency
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell.userName.text = user.userName
        cell.userLocation.text = user.userLocation
        cell.statusMessage.text = user.statusMessage
        
        if let profileImageUrl = user.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithString(urlString: profileImageUrl)
        }
        // Configure the cell...
        
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
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
