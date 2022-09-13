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
    @IBOutlet weak var stackView: UIStackView!
    
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
        
        self.selectionStyle = .none
        self.cornerAndShadow(cornerRadius: 6,
                             shadowRadius: 2,
                             shadowOffset: CGSize(width: 3, height: 2))
        containerView.layer.cornerRadius = 6
    }
    
    @IBAction func completedTaskTapped(_ sender: UIButton) {
        RealmManager.shared.updateCompletedState(task: task)
    }
    
    @IBAction func importantTaskTapped(_ sender: UIButton) {
        RealmManager.shared.updateImportantState(task: task)
    }
    
    func configure(with task: TaskModel, color: UIColor?) {
        self.task = task
        
        importantTaskButton.setImage(UIImage(systemName: task.isImportant ? "star.fill" : "star"), for: .normal)
        completedTaskButton.setImage(UIImage(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle"), for: .normal)
        
        completedTaskButton.tintColor = task.isCompleted ? color : .systemGray
        importantTaskButton.tintColor = task.isImportant ? color : .systemGray
        
        taskNameLabel.attributedText = task.isCompleted ? completedAttributeString : notCompletedAttributeString
        
        noteImage.isHidden = task.note.isEmpty
        
        filesImage.isHidden = task.images.isEmpty
        
        let currendDate = Date()
        bellImage.tintColor = currendDate > task.reminderTime ?? Date() ? .systemPink : .systemGray
        bellImage.isHidden = task.reminderTime == nil
        bellLabel.isHidden = true
        
        let smallConfig = UIImage.SymbolConfiguration(scale: .small)
        bellImage.image = UIImage(systemName: task.reminderTime == nil ? "bell.slash" : "bell.badge", withConfiguration: smallConfig)
        
        // если дата выполнения задачи сегодня, то подсвечиваем ярким, если в будущем, то синим цветом
        calendarImage.tintColor = currendDate > task.dateOfCompletion ?? Date() ? .systemPink : .systemGray
        calendarLabel.textColor = currendDate > task.dateOfCompletion ?? Date() ? .systemPink : .systemGray
        
        calendarImage.isHidden = task.dateOfCompletion == nil
        calendarLabel.isHidden = task.dateOfCompletion == nil

        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "dd, MMM, YY"
        calendarLabel.text = task.dateOfCompletion == nil ? "" : formatter.string(from: task.dateOfCompletion ?? Date())
        
        stackView.isHidden = noteImage.isHidden && filesImage.isHidden && bellImage.isHidden && calendarImage.isHidden
    }
}
