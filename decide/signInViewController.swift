//
//  signInViewController.swift
//  decide
//
//  Created by Ashutosh Kumar Sai on 10/01/17.
//  Copyright © 2017 Ashish Rajendra Kumar Sai. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

class signInViewController : UIViewController,UITextFieldDelegate
{
    
    @IBOutlet weak var ema: UITextField!
    @IBOutlet weak var pass: UITextField!
    @IBOutlet weak var error: UIButton!
  
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        error.isHidden = true
        ema.delegate = self
        pass.delegate = self
        activityIndicator.isHidden = true
    }
    
    @IBAction func goBackHome(_ sender: Any) {
       dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signIn(_ sender: Any) {
        let email = self.ema.text
        let passowrd = self.pass.text
       activityIndicator.isHidden = false
        
        activityIndicator.startAnimating()
        
        if Reachability.sharedInstance().isInternetAvailable() {
        
            if email != "" && passowrd != ""
        {
            
            
                FIRAuth.auth()?.signIn(withEmail: email!, password: passowrd!, completion: { (UID, errors) in
                    if errors == nil
                    {
                        print("yahoo done")
                        self.error.setTitle("Sign In Successful", for: .normal)
                        self.error.isHidden = false
                        self.activityIndicator.stopAnimating()
                        self.performSegue(withIdentifier: "signInHome", sender: self)
                    }
                    else{
                        self.error.setTitle("Error Occured ", for: .normal)
                        self.error.isHidden = false
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true


                    }
                    
                })
            }
            else
            {
                
                error.setTitle("Invalid Entries", for: .normal)
                error.isHidden = false
                self.activityIndicator.stopAnimating()
                activityIndicator.isHidden = true

            }
            

            
        }
        else {
            
            error.setTitle("No Internet Connection", for: .normal)
            error.isHidden = false
            self.activityIndicator.stopAnimating()
            activityIndicator.isHidden = true

            let alert = UIAlertController(title: "Connection Error", message: "Please Try Again", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: {(action) in
            }))
            self.present(alert, animated: true, completion: {() -> Void in })

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
