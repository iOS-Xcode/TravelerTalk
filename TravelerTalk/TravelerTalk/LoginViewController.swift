//
//  ViewController.swift
//  TravelerTalk
//
//  Created by seokhyun kim on 2017-09-12.
//  Copyright © 2017 seokhyun kim. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import TwitterKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, UITextFieldDelegate {
    
//    var emailRegisterViewController : EmailRegisterViewController?
    
    var usersTableViewController : UsersTableViewController?
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var facebookButton: UIButton! {
        didSet {
            // This is for image of facebook provied by Facebook.
            /*            facebookButton.delegate = self
             //            facebookButton.readPermissions = ["email", "public_profile"] */
            facebookButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
            
        }
    }
    
    //    @IBOutlet weak var twitterButton: TWTRLogInButton!
    //    {
    //        didSet {
    //            let twitterButton = TWTRLogInButton { (session, error) in
    //                if let err = error {
    //                    print("Failed to login via Twitter: ", err)
    //                    return
    //                }
    //        }
    //            view.addSubview(twitterButton)
    //    }
    //    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("did log out of facebook")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
        print("Successfully logged in with facebook.....")
        showEmailAddress()
        //        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields" : "id, name, email"]).start {
        //            (connection, result, error) in
        //            if error != nil {
        //                print("Failed to start graph request:", error ?? String())
        //                return
        //            }
        //            print(result ?? String())
        //            }
    }
    func showEmailAddress() {
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else {
            return
        }
        let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
        FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
            if error != nil {
                print("Something went wrong with out FB user : ", error ?? "")
                return
            }
            print("Successfully logged in with our user: ", user ?? "")
            self.dismiss(animated: true, completion: nil)
        })
        
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields" : "id, name, email"]).start {
            (connection, result, error) in
            if error != nil {
                print("Failed to start graph request:", error ?? "")
                return
            }
            print(result ?? "")
        }
    }
    //Login Using Custom FB Button
    @objc func handleCustomFBLogin() {
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) {
            (result, err) in
            if err != nil {
                print("Custom FB Login failed:", err ?? "")
                return
            }
            self.showEmailAddress()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.email.delegate = self
        self.password.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
            NSLog("Login with UserID and Password")
            self.usersTableViewController?.fetchUserAndSetupNavBarTitle()
            self.presentingViewController?.dismiss(animated: true, completion: nil)
            
        })
    }
}
