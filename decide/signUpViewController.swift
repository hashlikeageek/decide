//
//  signUpViewController.swift
//  decide
//
//  Created by Ashutosh Kumar Sai on 10/01/17.
//  Copyright © 2017 Ashish Rajendra Kumar Sai. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
class signUpViewController : UIViewController,UITextFieldDelegate
{
    
    @IBOutlet weak var error: UIButton!
    @IBOutlet weak var em: UITextField!
    @IBOutlet weak var pass: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        error.isHidden = true
        em.delegate = self
        pass.delegate = self
    }
    
    
    @IBAction func signUp(_ sender: Any) {
        
        let email = self.em.text
        let passowrd = self.pass.text
        
        if email != "" && passowrd != ""
        {
            FIRAuth.auth()?.createUser(withEmail: email!, password: passowrd!, completion: { (UID, errors) in
                print("yahoo done")
                self.error.setTitle("Sign Up Successful", for: .normal)
                self.error.isHidden = false
                
            })
            }
        else
        {
           
            error.setTitle("Invalid Entries", for: .normal)
            error.isHidden = false
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
     override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }


    
}
