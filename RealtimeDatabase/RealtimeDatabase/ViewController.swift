//
//  ViewController.swift
//  RealtimeDatabase
//
//  Created by seokhyun kim on 2017-08-01.
//  Copyright © 2017 seokhyun kim. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    //class FIRDatabaseReference : FIRDatabaseQuery
    var ref : FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //make to refer realtime database
        self.ref = FIRDatabase.database().reference()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

