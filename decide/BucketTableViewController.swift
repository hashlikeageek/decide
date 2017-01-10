//
//  BucketTableViewController.swift
//  decide
//
//  Created by Ashutosh Kumar Sai on 10/01/17.
//  Copyright © 2017 Ashish Rajendra Kumar Sai. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import FirebaseAuth
import FirebaseDatabase

class BucketTableViewController: UITableViewController {
    
    var ref: FIRDatabaseReference?
    var query: FIRDatabaseQuery?


    var snapshotsController = FirebaseSnapshotsController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FIRDatabase.database().persistenceEnabled = true
       
        navigationItem.leftBarButtonItem = editButtonItem
        
       
        let imageView = UIImageView(image: UIImage(named: "AppTitleBarLogo"))
        imageView.contentMode =  .scaleAspectFill
        navigationItem.titleView = imageView
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 140
        
        
        guard let user = FIRAuth.auth()?.currentUser else { return }
        ref = FIRDatabase.database().reference().child("bucketlists/\(user.uid)")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       
        tableView.reloadData()
        
        
        query = ref?.queryOrderedByPriority()
        
        query?.observe(.childAdded, with: { (snapshot) -> Void in
            if let index = self.snapshotsController.append(snapshot) {
                let indexPath = IndexPath(row: index, section: 0)
                self.tableView.insertRows(at: [indexPath], with: .automatic)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        })
        
        query?.observe(.childChanged, with: { (snapshot) -> Void in
            if let index = self.snapshotsController.replace(snapshot) {
                let indexPath = IndexPath(row: index, section: 0)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        })
        
        query?.observe(.childRemoved, with: { (snapshot) -> Void in
            if let index = self.snapshotsController.remove(snapshot) {
                print("removedHandle: index = \(index)")
                self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        })
        
        query?.observe(.childMoved, andPreviousSiblingKeyWith: { (snapshot, previousKey) in
            let fromIndex = self.snapshotsController.indexOf(snapshot) ?? 0
            print("The idea with name = \((snapshot.value as? NSDictionary)?.value(forKey: "name") ?? "No Name") and priority = \(snapshot.priority ?? -1) moved from \(fromIndex)")
            
            let previousIndex = self.snapshotsController.indexOf(byKey: previousKey) ?? -1
            // If moving to the beginning, to=0. If moving left, to will be after previous sibling. Otherwise, to will replace previous sibling
            let toIndex = (previousIndex == -1) ? 0 : (previousIndex < fromIndex) ? (previousIndex + 1) : previousIndex
            print("The new position follows index = \(previousIndex) requiring a new index = \(toIndex)")
            
            if let _ = self.snapshotsController.move(from: fromIndex, to: toIndex) {
                let lowerIndex = (fromIndex <= toIndex) ? fromIndex : toIndex
                let upperIndex = (fromIndex <= toIndex) ? toIndex : fromIndex
                var reloadRowsIndexes: [IndexPath] = []
                for index in lowerIndex...upperIndex {
                    reloadRowsIndexes.append(IndexPath(row:index, section: 0))
                }
                print("That idea moved from index = \(fromIndex) to index = \(toIndex), requiring table rows in this range to be reloaded: \(lowerIndex)...\(upperIndex)")
                self.tableView.reloadRows(at: reloadRowsIndexes, with: .automatic)
                self.tableView.scrollToRow(at: IndexPath(row: toIndex, section: 0), at: .bottom, animated: true)
            }
        })
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
       
        query?.removeAllObservers()
        snapshotsController.removeAll()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        
        
        let alertController = UIAlertController(title: "New Thing", message: "An idea to Accomplish", preferredStyle: .alert)
        alertController.addTextField { textField in }
        
       
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            if let text = alertController.textFields?.first?.text {
                
                
                if self.snapshotsController.count == 0 {
                    FIRAnalytics.logEvent(withName: "BucketListNew", parameters: nil)
                }

                self.ref?.childByAutoId().setValue(["name": text], andPriority: self.snapshotsController.maxPriority + 10)
            }
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let snapshotToDelete = snapshotsController.find(byIndex: indexPath.row) {
               
                snapshotToDelete.ref.removeValue()
            }
        }
        else if editingStyle == .insert {
            self.ref?.childByAutoId().setValue(["name": "New Idea"], andPriority: snapshotsController.maxPriority + 10)
        }
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        if let snapshotForMovedRow = snapshotsController.find(byIndex: sourceIndexPath.row) {
            if let newPriority = snapshotsController.calculatePriorityOnMove(from: sourceIndexPath.row, to: destinationIndexPath.row) {
                let dict = snapshotForMovedRow.value as? NSDictionary ?? NSDictionary()
                print ("About to set newPriority = \(newPriority) for moved row with name = \(dict.value(forKey: "name") ?? "No Name") and priority = \(snapshotForMovedRow.priority ?? 0)")
              
                snapshotForMovedRow.ref.setPriority(newPriority)
            }
        }
    }
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return snapshotsController.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt index=\(indexPath.row)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "BucketIdea", for: indexPath) as! BucketIdeaTableViewCell
        
        let snapshot = snapshotsController.find(byIndex: indexPath.row)
        cell.bucketIdea = snapshot?.value as? NSDictionary ?? NSDictionary(dictionary: ["name": "No Name"])

        return cell
    }
    
}

