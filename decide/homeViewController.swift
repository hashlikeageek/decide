//
//  homeViewController.swift
//  decide
//
//  Created by Ashutosh Kumar Sai on 10/01/17.
//  Copyright © 2017 Ashish Rajendra Kumar Sai. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase


class homeViewController : UIViewController
{

var refHandle:FIRDatabaseHandle?
var ref: FIRDatabaseReference?
private var pindata : FIRDatabaseReference!

    
    @IBAction func signOut(_ sender: Any) {
        try! FIRAuth.auth()!.signOut()
        performSegue(withIdentifier: "welcomeFromHome", sender: self)
        }
    

    
    func getdata()
    {
        ref = FIRDatabase.database().reference()
        
        refHandle = (ref?.observe(FIRDataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            
            print(postDict)
            
           
            
            
            // ...
        }))!
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference()
        getdata()
    }
 
    
    }

