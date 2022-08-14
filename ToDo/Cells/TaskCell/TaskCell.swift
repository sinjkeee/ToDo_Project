//
//  TaskCell.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 10.08.2022.
//

import UIKit

class TaskCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var completedTaskButton: UIButton!
    @IBOutlet weak var importantTaskButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = 6
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func completedTaskTapped(_ sender: UIButton) {
        print("completed")
    }
    
    @IBAction func importantTaskTapped(_ sender: UIButton) {
        print("important")
    }
    
}
