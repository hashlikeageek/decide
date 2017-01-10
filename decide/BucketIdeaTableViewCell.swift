//
//  BucketIdeaTableViewCell.swift
//  decide
//
//  Created by Ashutosh Kumar Sai on 10/01/17.
//  Copyright © 2017 Ashish Rajendra Kumar Sai. All rights reserved.
//

import UIKit

class BucketIdeaTableViewCell: UITableViewCell {

    var bucketIdea: NSDictionary? {
        didSet {
            self.configureView()
        }
    }

    func configureView () {
        if let bucketIdea = self.bucketIdea {
            textLabel?.text = bucketIdea.value(forKey: "name") as? String ?? "No Name"
        }
    }


}
