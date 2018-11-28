//
//  ToDoListTableViewCell.swift
//  ToDoList
//
//  Created by Apple on 11/27/18.
//  Copyright © 2018 Faris. All rights reserved.
//

import UIKit

class ToDoListTableViewCell: UITableViewCell {
    
    @IBOutlet var taskDetailLabel: UILabel!
    @IBOutlet var finishTaskButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setUpCellItems(toDo: ToDo, index: Int) {
        self.taskDetailLabel.text = toDo.name
        self.accessoryType = .none
        if toDo.status == finishedState.notFinished.rawValue {
            self.finishTaskButton.setImage(UIImage(named: "unmark"), for: .normal)
        } else {
            self.finishTaskButton.setImage(UIImage(named: "mark"), for: .normal)
        }
        // Set tag for identifying tap actions
        self.taskDetailLabel.tag = index + Constants.toDoTitleTag
        self.finishTaskButton.tag = index + Constants.toDoFinishButtonTag
    }
    
}
