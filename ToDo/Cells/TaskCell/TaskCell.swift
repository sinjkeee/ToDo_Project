//
//  TaskCell.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 10.08.2022.
//

import UIKit

class TaskCell: UITableViewCell {
    
    //MARK: - @IBOutlet
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
    
    //MARK: - let/var
    private var completedAttributeString: NSMutableAttributedString!
    private var notCompletedAttributeString: NSMutableAttributedString!
    var task: TaskModel = TaskModel() {
        didSet {
            completedAttributeString = NSMutableAttributedString(string: task.name)
            completedAttributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSRange(location: 0, length: completedAttributeString.length))
            
            notCompletedAttributeString = NSMutableAttributedString(string: task.name)
            notCompletedAttributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 0, range: NSRange(location: 0, length: notCompletedAttributeString.length))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = 6
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func completedTaskTapped(_ sender: UIButton) {
        RealmManager.shared.updateCompletedState(task: task)
        print("completed")
    }
    
    @IBAction func importantTaskTapped(_ sender: UIButton) {
        RealmManager.shared.updateImportantState(task: task)
        print("important")
    }
    
    func configure(with task: TaskModel) {
        taskNameLabel.attributedText = task.isCompleted ? completedAttributeString : notCompletedAttributeString
        noteImage.tintColor = task.note.isEmpty ? .systemGray2 : .systemPink
        importantTaskButton.setImage(UIImage(systemName: task.isImportant ? "star.fill" : "star"), for: .normal)
        completedTaskButton.setImage(UIImage(systemName: task.isCompleted ? "circle.slash" : "circle"), for: .normal)
    }
    
}
