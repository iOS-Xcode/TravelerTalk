//
//  ChatLogController.swift
//  everybodyChats
//
//  Created by seokhyun kim on 2017-08-12.
//  Copyright © 2017 seokhyun kim. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class ChatLogController :  UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var user : User? {
        didSet {
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    var messages = [Message]()
    
    func observeMessages() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid, let toId = user?.id else {
            return
        }
        
        let userMessagesRef = FIRDatabase.database().reference().child("user-messages").child(uid).child(toId)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messagesRef = FIRDatabase.database().reference().child("messages").child(messageId)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String:AnyObject] else {
                    return
                }
                
                //do we need to attempt filtering anymore?
                self.messages.append(Message(dictionary: dictionary))
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                        //scroll to the last index
                        let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                        self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                    }
                
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.contentInset = UIEdgeInsetsMake(8, 0, 8, 0)
//        collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 50, 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive

        setupKeyboardObservers()
        
    }
    lazy var inputContainerView : ChatInputContainerView = {
        let chatInputContainerView = ChatInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        chatInputContainerView.chatLogController = self
        return chatInputContainerView
    }()
    
    func handleUploadTap() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
        present(imagePickerController, animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? NSURL {
            //we selected a video
            handleVideoSelectedForUrl(url: videoUrl)
            
        } else {
            //we selected an image
            handleImageSelectedForInfo(info: info)

        }
        dismiss(animated: true, completion: nil)
    }
    private func handleVideoSelectedForUrl(url: NSURL) {
        let filename = NSUUID().uuidString + "mov"
        let uploadTask = FIRStorage.storage().reference().child("message_movies").child(filename).putFile(url as URL, metadata: nil, completion: { (metadata, error) in
            if error != nil {
                print("Failed upload of video:", error ?? String())
                return
            }
            if let videoUrl = metadata?.downloadURL()?.absoluteString {

                if let thumbnailImage = self.thumbnailImageForFileUrl(fileUrl: url) {
                    self.uploadToFirebaseStorageUsingImage(image: thumbnailImage, completion: { (imageUrl) in
                        
                        //all we're missing now is imageUrl
                        //"imageUrl": imageUrl
                        let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": thumbnailImage.size.width as AnyObject, "imageHeight": thumbnailImage.size.height as AnyObject, "videoUrl": videoUrl as AnyObject]
                        self.sendMessageWithProperties(properties: properties)
                        
                    })

                }
            }
        })
        uploadTask.observe(.progress) { (snapshot) in
            if let completedUnitCount = snapshot.progress?.completedUnitCount {
                self.navigationItem.title = String(completedUnitCount)
            }
            print(snapshot.progress?.completedUnitCount ?? String())
        }
        uploadTask.observe(.success) { (snapshot) in
            self.navigationItem.title = self.user?.name
        }

    }
    private func thumbnailImageForFileUrl(fileUrl: NSURL) -> UIImage? {
        let asset = AVAsset(url: fileUrl as URL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch let err {
            print(err)
        }
        return nil
    }
    private func handleImageSelectedForInfo(info: [String: AnyObject]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker {
            uploadToFirebaseStorageUsingImage(image: selectedImage, completion: { (imageUrl) in
                self.sendMessageWithImageUrl(imageUrl: imageUrl, image: selectedImage)
            })
        }
    }
    //check this function.
    private func uploadToFirebaseStorageUsingImage(image: UIImage, completion: @escaping (_ imageUrl: String) -> ()) {
        let imageName = NSUUID().uuidString
        let ref = FIRStorage.storage().reference().child("message_images").child(imageName)
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            ref.put(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print("Failed to upload image", error ?? String())
                    return
                }
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    completion(imageUrl)
//                    self.sendMessageWithImageUrl(imageUrl: imageUrl, image: image)
                }
        })
        }
    }

    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    override var canBecomeFirstResponder: Bool {
        return true
    }
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: .UIKeyboardDidShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    func handleKeyboardDidShow() {
        if messages.count > 0 {
            let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
            self.collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    //Ep15 12:55
    func handleKeyboardWillShow(notification: NSNotification) {
         let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
         let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        containerViewBottomAnchor?.constant = -(keyboardFrame!.height)
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    func handleKeyboardWillHide(notification: NSNotification) {
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
        containerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        
    }
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        cell.chatLogController = self
        
        
        let message = messages[indexPath.item]
        cell.message = message
        cell.textView.text = message.text
        
        setupCell(cell: cell, message: message)
        if let text = message.text {
            //a text message
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text:text).width + 32
            cell.textView.isHidden = false
        } else if message.imageUrl != nil {
            //fall in here if its an image message
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }

        cell.playButton.isHidden = message.videoUrl == nil
        
        return cell
    }
    private func setupCell(cell: ChatMessageCell, message: Message) {
        if let profileImageUrl = self.user?.profileImageUrl {
            cell.profileIamgeView.loadImageUsingCacheWithString(urlString: profileImageUrl)
        }

        if message.fromId == FIRAuth.auth()?.currentUser?.uid {
            //outgoing blue
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = UIColor.white
            cell.profileIamgeView.isHidden = true
            
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        } else {
            //incoming gray
            cell.bubbleView.backgroundColor = UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = UIColor.black
            cell.profileIamgeView.isHidden = false
            
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
        if let messageImageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCacheWithString(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
        } else {
            cell.messageImageView.isHidden = true
        }
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        let message = messages[indexPath.item]
        if let text = message.text {
            height = estimateFrameForText(text: text).height + 20
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageWidth?.floatValue {
            // h1 / w1 = h2 / w2
            // solve for h1
            // h1 = h2 / w2 * w1
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    func handleSend() {
        let properties = ["text" : inputContainerView.inputTextField.text!]
        sendMessageWithProperties(properties: properties as [String : AnyObject])
    }
    
    private func sendMessageWithImageUrl(imageUrl: String, image: UIImage) {
        let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": image.size.width as AnyObject, "imageHeight": image.size.height as AnyObject]
        sendMessageWithProperties(properties: properties)
    }
    
    private func sendMessageWithProperties(properties: [String: AnyObject]) {
        let ref = FIRDatabase.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        //is it there best thing to inclue the name inside of the message node.
        let toId = user!.id!
        let fromId = FIRAuth.auth()!.currentUser!.uid
        let timestamp = NSNumber(value: Int(Date().timeIntervalSince1970))
        
        var values: [String: AnyObject] = ["toId": toId as AnyObject, "fromId": fromId as AnyObject, "timestamp" :timestamp as AnyObject]
        //append properties dictonary onto values somehow?
        //key $0, value $1
        properties.forEach({values[$0] = $1 as? NSObject})
        
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error ?? String())
                return
            }
            self.inputContainerView.inputTextField.text = nil
            let userMessageRef = FIRDatabase.database().reference().child("user-messages").child(fromId).child(toId)
            let messageId = childRef.key
            userMessageRef.updateChildValues([messageId: 1])
            let recipientUserMessagesRef = FIRDatabase.database().reference().child("user-messages").child(toId).child(fromId)
            recipientUserMessagesRef.updateChildValues([messageId: 1])
            
        }
    }

    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    //my costom zooming logic
    func performZoomInForStartingImageView(startingImageView: UIImageView) {
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackBackgroundView?.alpha = 1
                self.inputContainerView.alpha = 0

            }, completion: { (completed) in
//                zoomOutImageView.removeFromSuperview()
            })
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.blackBackgroundView?.alpha = 1
                self.inputContainerView.alpha = 0
                //math?
                // h2 / w1 = h1 /w1
                //h2 = h1 / w1 * w1
                let height = self.startingFrame!.height / (self.startingFrame?.width)! * keyWindow.frame.width
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
            }, completion: { (completed) in
//                do nothing
            })
        }
        
    }
    func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            //need to animate back out to controller
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
            }, completion: { (completed) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
        }
        
    }
}
