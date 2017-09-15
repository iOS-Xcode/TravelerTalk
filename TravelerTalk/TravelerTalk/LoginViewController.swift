//
//  ViewController.swift
//  TravelerTalk
//
//  Created by seokhyun kim on 2017-09-12.
//  Copyright © 2017 seokhyun kim. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    var emailRegisterViewController : EmailRegisterViewController?
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func handleLogin(_ sender: Any) {
        guard let email = email.text, let password = password.text else {
            print("Form is not valid")
            return
        }
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                print(error ?? String())
                return
            }
            //successfully logged in our user
            //            self.messagesController?.fetchUserAndSetupNavBarTitle()
            //            self.dismiss(animated: true, completion: nil)
            NSLog("Login with UserID and Password")
        })
    }
}
