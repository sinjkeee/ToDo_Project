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
        noteImage.tintColor = task.note.isEmpty ? .systemGray2 : .systemBlue
        filesImage.tintColor = task.images.isEmpty ? .systemGray2 : .systemBlue
        
        importantTaskButton.setImage(UIImage(systemName: task.isImportant ? "star.fill" : "star"), for: .normal)
        completedTaskButton.setImage(UIImage(systemName: task.isCompleted ? "circle.slash" : "circle"), for: .normal)
        
        calendarImage.tintColor = task.dateOfCompletion == nil ? .systemGray2 : .systemBlue
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd, MMM, YY"
        calendarLabel.text = task.dateOfCompletion == nil ? "" : formatter.string(from: task.dateOfCompletion ?? Date())
        calendarLabel.textColor = .systemBlue
        
        bellLabel.text = task.reminderTime == nil ? "" : ""
        let smallConfig = UIImage.SymbolConfiguration(scale: .small)
        bellImage.image = task.reminderTime == nil ? UIImage(systemName: "bell.slash", withConfiguration: smallConfig) : UIImage(systemName: "bell.badge", withConfiguration: smallConfig)
        
        bellImage.tintColor = task.reminderTime == nil ? .systemGray2 : .systemPink
    }
}
