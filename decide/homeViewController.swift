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

class homeViewController : UIViewController
{
    @IBAction func signOut(_ sender: Any) {
        try! FIRAuth.auth()!.signOut()
        performSegue(withIdentifier: "welcomeFromHome", sender: self)
        }
    }
    
