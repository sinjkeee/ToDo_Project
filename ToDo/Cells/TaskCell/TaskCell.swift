//
//  TaskCell.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 10.08.2022.
//

import UIKit

class TaskCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var completedTaskButton: UIButton!
    @IBOutlet weak var importantTaskButton: UIButton!
    
    @IBOutlet weak var calendarImage: UIImageView!
    @IBOutlet weak var calendarLabel: UILabel!
    
    @IBOutlet weak var bellImage: UIImageView!
    @IBOutlet weak var bellLabel: UILabel!
    
    @IBOutlet weak var noteImage: UIImageView!
    @IBOutlet weak var filesImage: UIImageView!
    
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
    
    func configure(with task: TaskModel) {
        taskNameLabel.text = task.name
        noteImage.tintColor = task.note.isEmpty ? .systemGray2 : .systemPink
    }
    
}
