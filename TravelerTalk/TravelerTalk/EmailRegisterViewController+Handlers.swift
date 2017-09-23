//
//  EmailRegisterViewController+Handlers.swift
//  TravelerTalk
//
//  Created by seokhyun kim on 2017-09-13.
//  Copyright © 2017 seokhyun kim. All rights reserved.
//

import UIKit
import Firebase

extension EmailRegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker {
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    
    func handleRegister() {
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            print("Form is not valid")
            return
        }
        guard let status = statusMessageTextField.text else {
            return
        }
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
            if error != nil {
                print(error ?? String())
                return
            }
            
            //successfully authenticated user
            let imageName = NSUUID().uuidString
            let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).png")
            if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
                storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print(error ?? String())
                        return
                    }
                    
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                        let values = ["userName" : name, "email": email, "profileImageUrl" : profileImageUrl, "userLocation" : self.currentUserLocation.text, "statusMessage" : status]
                        self.registerUserIntoDatabaseWithUID(uid: (user?.uid)!, values: values as [String : AnyObject])
                    }
                    
                })
            }
            
        })
        print(123)
    }
    
    private func registerUserIntoDatabaseWithUID(uid: String, values: [String: AnyObject]) {
        let ref = FIRDatabase.database().reference()
        let usersReference = ref.child("users").child(uid)
        //
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err ?? String())
                return
            }
            let user = UserProfiles()
            //this setter potentially crashes if keys don't match
            user.setValuesForKeys(values)
//            self.messagesController?.setupNavBarWithUser(user: user)
            
            self.dismiss(animated: true, completion: nil)
        })
    }
}
