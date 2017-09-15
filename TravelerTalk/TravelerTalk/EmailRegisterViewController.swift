//
//  EmailRegisterViewController.swift
//  TravelerTalk
//
//  Created by seokhyun kim on 2017-09-13.
//  Copyright © 2017 seokhyun kim. All rights reserved.
//

import UIKit
import MapKit

class EmailRegisterViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var currentUserLocation: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView! {
        didSet {
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView))
            profileImageView.addGestureRecognizer(tap)
            profileImageView.isUserInteractionEnabled = true
            
        }
    }
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameTextField.delegate = self
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
//        self.usernameTextField.becomeFirstResponder()
    }
    
    @IBAction func saveProfile(_ sender: Any) {
        self.handleRegister()
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func searchLocation(_ sender: Any) {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //Using Info of Location, output into label
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last
        CLGeocoder().reverseGeocodeLocation(lastLocation!, completionHandler: {
            (placemarks, error) -> Void in
            NSLog("\(placemarks!.first!)")
            if let pm = placemarks?.first {
                let addressString = pm.locality! + ", " + pm.administrativeArea! + ", " + pm.country!
                self.currentUserLocation.text = addressString
            }

        })
        
        locationManager.stopUpdatingLocation()
    }
}
