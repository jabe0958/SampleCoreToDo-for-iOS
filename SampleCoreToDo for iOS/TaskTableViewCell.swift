//
//  TaskTableViewCell.swift
//  SampleCoreToDo for iOS
//
//  Created by jabe0958 on 2017/09/13.
//  Copyright © 2017年 jabe0958. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "TaskCell"
    
    // MAKR: -
    
    @IBOutlet weak var taskLabel: UILabel!
    
    // MARK: - Initialization

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
