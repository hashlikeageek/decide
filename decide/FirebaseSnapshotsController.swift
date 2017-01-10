//
//  FirebaseSnapshotsController.swift
//  decide
//
//  Created by Ashutosh Kumar Sai on 10/01/17.
//  Copyright © 2017 Ashish Rajendra Kumar Sai. All rights reserved.
//

import Foundation
import FirebaseDatabase

class FirebaseSnapshotsController {
    
    
    var handlers: [() -> Void] = []
    var snapshots: [FIRDataSnapshot] = []
    
    var count: Int {
        get { return snapshots.count ?? 0}
    }
    var maxPriority: Int {
        get { return snapshots.last?.priority as? Int ?? 0 }
    }
    
    
    func find (_ snapshot: FIRDataSnapshot) -> FIRDataSnapshot? {
        return find(byKey: snapshot.key)
    }
    
    func find (byIndex index: Int) -> FIRDataSnapshot? {
        if snapshots.count == 0 || index < 0 || index > snapshots.count - 1 { return nil }
        return snapshots[index]
    }
    
    func find (byKey key: String) -> FIRDataSnapshot? {
        for (index, element) in snapshots.enumerated() {
            if element.key == key {
                return snapshots[index]
            }
        }
        
        return nil
    }
    
    func indexOf (_ snapshot: FIRDataSnapshot) -> Int? {
        for (index, element) in snapshots.enumerated() {
            if element.key == snapshot.key {
                return index
            }
        }
        
        return nil
    }
    
    func indexOf (byKey key: String?) -> Int? {
        for (index, element) in snapshots.enumerated() {
            if element.key == key {
                return index
            }
        }
        
        return nil
    }
    
    func append (_ snapshot: FIRDataSnapshot) -> Int? {
        snapshots.append(snapshot)
        return snapshots.count - 1
    }
    
    func replace (_ snapshot: FIRDataSnapshot) -> Int? {
        if let index = indexOf(snapshot) {
            snapshots[index] = snapshot
            return index
        }
        
        return nil
    }
    
    func remove (_ snapshot: FIRDataSnapshot) -> Int? {
        if let index = indexOf(snapshot) {
            snapshots.remove(at: index)
            return index
        }
        
        return nil
    }
    
    func removeAll () -> Void {
        snapshots.removeAll()
    }
    
    func move (from fromIndex: Int, to toIndex: Int) -> Int? {
        if snapshots.count == 0 || fromIndex < 0 || fromIndex > snapshots.count - 1 || toIndex < 0 || toIndex > snapshots.count - 1 { return nil }
        
        
        let snapshot = snapshots.remove(at: fromIndex)
        snapshots.insert(snapshot, at: toIndex)
        
        return toIndex
    }
    
    func move (_ snapshot: FIRDataSnapshot, to toIndex: Int) -> Int? {
        if snapshots.count == 0 || toIndex < 0 || toIndex > snapshots.count - 1 { return nil }
        guard let fromIndex = indexOf(snapshot) else { return nil }
        
        let newIndex = (fromIndex < toIndex) ? toIndex - 1 : toIndex
        snapshots.remove(at: fromIndex)
        snapshots.insert(snapshot, at: newIndex)
        
        return fromIndex
    }
    
    
    func calculatePriorityOnMove (from fromIndex: Int, to toIndex: Int) -> Int? {
        if snapshots.count == 0 || fromIndex < 0 || fromIndex > snapshots.count - 1 || toIndex < 0 || toIndex > snapshots.count - 1 { return nil }
        
        let movedElement = snapshots[fromIndex]
        let movedPriority = movedElement.priority as? Int ?? 0
        print("Calculating priority for idea moving from index = \(fromIndex) with priority = \(movedPriority) to index = \(toIndex)")
        
        let displacedPriority = snapshots[toIndex].priority as? Int ?? 0
        var newPriority: Int
        if toIndex == 0 {
            
            let firstPriority = snapshots.first?.priority as? Int ?? 0
            newPriority = firstPriority / 2
        }
        else if toIndex == snapshots.count - 1 {
            
            let lastPriority = snapshots.last?.priority as? Int ?? 0
            newPriority = lastPriority + ((lastPriority - 0) / snapshots.count)
        }
        else if toIndex > fromIndex {
         
            let succeedingPriority = snapshots[toIndex + 1].priority as? Int ?? 0
            newPriority = ((succeedingPriority - displacedPriority) / 2) + displacedPriority
        }
        else {
            
            let precedingPriority = snapshots[toIndex - 1].priority as? Int ?? 0
            newPriority = ((displacedPriority - precedingPriority) / 2) + precedingPriority
        }
        print("Calculated priority for idea moving from index = \(fromIndex) with priority = \(movedPriority) to index = \(toIndex) as new priority = \(newPriority)")
        
        return newPriority
    }
    
    func childValueAsString (in snapshot: FIRDataSnapshot, for key: String) -> String? {
        guard let dictionary = snapshot.value as? NSDictionary else { return nil }
        guard let value = dictionary.value(forKey: key) as? String else { return nil }
        
        return value
    }
    
}

