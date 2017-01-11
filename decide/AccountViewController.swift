//
//  AccountViewController.swift
//  decide
//
//  Created by Ashutosh Kumar Sai on 10/01/17.
//  Copyright © 2017 Ashish Rajendra Kumar Sai. All rights reserved.
//

import FirebaseAnalytics
import FirebaseAuth
import FirebaseStorage
import UIKit
import FirebaseDatabase

class AccountViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBAction func unwindFromSignIn(segue: UIStoryboardSegue) {
        self.profileImageView.image = nil

    }
    
    @IBAction func signOutButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Log Out of decide?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Log Out", style: .default, handler: {(action) in
            do {
                try FIRAuth.auth()?.signOut()
                self.profileImageView.image = nil
                
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            self.dismiss(animated: true, completion: nil)
            

        }))
        self.present(alert, animated: true, completion: {() -> Void in })
    }
    
    
    
    @IBAction func changePictureButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Change Profile Picture", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Remove Profile Picture", style: .destructive, handler: {(action) in
            self.profileImageView.image = nil
            guard let user = FIRAuth.auth()?.currentUser else { return }
            let storageRef = FIRStorage.storage().reference()
            storageRef.child("shared/\(user.uid)/profile-400x400.png").delete {(error) in
                print("Error occurred deleting profile image from Firebase Storage: \(error?.localizedDescription)")
            }
            storageRef.child("shared/\(user.uid)/profile-80x80.png").delete {(error) in
                print("Error occurred deleting profile thumbnail image from Firebase Storage: \(error?.localizedDescription)")
            }
        }))
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: {(action) in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.modalPresentationStyle = .popover
            picker.popoverPresentationController?.sourceView = sender
            picker.popoverPresentationController?.sourceRect = sender.bounds
            picker.delegate = self
            self.present(picker, animated: true, completion: {() -> Void in })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) in
        }))
        self.present(alert, animated: true, completion: {() -> Void in })
    }
    
    @IBOutlet weak var profileImageView: UIImageView!
    
   
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
      func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage,
              let user = FIRAuth.auth()?.currentUser else {
            picker.dismiss(animated: true, completion: nil)
            return
        }

        guard let image = pickedImage.scaleAndCrop(withAspect: true, to: 200),
              let imageData = UIImagePNGRepresentation(image) else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
       
        self.profileImageView.image = image
            
        
        let storageRef = FIRStorage.storage().reference().child("shared/\(user.uid)/profile-400x400.png")
        let metadata = FIRStorageMetadata(dictionary: ["contentType": "image/png"])
        
        activityIndicator.startAnimating()
        let uploadTask = storageRef.put(imageData, metadata: metadata) { (metadata, error) in
            guard metadata != nil else {
                print("Error uploading image to Firebase Storage: \(error?.localizedDescription)")
                return
            }
             self.activityIndicator.stopAnimating()
           
            FIRAnalytics.logEvent(withName: "User-NewProfileImage", parameters: nil)

                       guard let image = pickedImage.scaleAndCrop(withAspect: true, to: 40),
                let imageData = UIImagePNGRepresentation(image) else {
                    return
            }
            let storageRef = FIRStorage.storage().reference().child("shared/\(user.uid)/profile-80x80.png")
            storageRef.put(imageData, metadata: FIRStorageMetadata(dictionary: ["contentType": "image/png"]))
        }
            
        picker.dismiss(animated: true, completion: nil)
    }
    
    
  
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FIRDatabase.database().persistenceEnabled = true


        FIRAuth.auth()?.addStateDidChangeListener({(auth, user) in
            
            if user == nil {
                self.performSegue(withIdentifier: "welcome", sender: self)
                
            }
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

       
        if let user = FIRAuth.auth()?.currentUser {
            
            nameLabel.text = user.displayName ?? user.email
            
            if profileImageView.image == nil {
               
                activityIndicator.startAnimating()
                let imageStorageRef = FIRStorage.storage().reference().child("shared/\(user.uid)/profile-400x400.png")
                let downloadTask = imageStorageRef.data(withMaxSize: 2 * 1024 * 1024) { data, error in
                   
                    self.activityIndicator.stopAnimating()
                    if error == nil, let data = data {
                        self.profileImageView.image = UIImage(data: data)
                    }
                }
                         }
        }
        
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

