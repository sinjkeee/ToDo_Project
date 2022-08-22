//
//  TaskViewController.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 12.08.2022.
//

import UIKit
import SnapKit
import RealmSwift

class TaskViewController: UIViewController {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var taskNameTF: UITextField!
    // дата выполнения таски
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var datePickerLabel: UILabel!
    @IBOutlet weak var datePickerImage: UIImageView!
    // дата уведомления
    @IBOutlet weak var dateTimePicker: UIDatePicker!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var dateTimeImage: UIImageView!
    
    @IBOutlet weak var notesTextView: UITextView!
    
    @IBOutlet weak var saveTaskButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    //MARK: - let/var
    private var placeholderLabel: UILabel!
    private var taskList: ListModel!
    var task: TaskModel = TaskModel()
    var indexPath: IndexPath?
    var listID: ObjectId?
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.minimumDate = Date()
        dateTimePicker.minimumDate = Date()
        
        taskList = listID != nil ? RealmManager.shared.realm.object(ofType: ListModel.self, forPrimaryKey: listID) : ListModel()
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
        view.addGestureRecognizer(recognizer)
        
        taskNameTF.delegate = self
        notesTextView.delegate = self
        
        updateUI()
        settingNotesTextView()
        updateSaveButtonState()
    }
    
    //MARK: - Custom methods
    @objc private func tap() {
        view.endEditing(true)
    }
    
    private func updateUI() {
        taskNameTF.text = task.name
        notesTextView.text = task.note
    }
    
    private func updateSaveButtonState() {
        guard let taskName = taskNameTF.text else { return }
        self.saveTaskButton.isEnabled = !taskName.isEmpty
    }
    
    // add placeholder and setting text view
    private func settingNotesTextView() {
        placeholderLabel = UILabel()
        placeholderLabel.text = "Заметка"
        guard let pointSize = notesTextView.font?.pointSize else { return }
        placeholderLabel.font = .systemFont(ofSize: pointSize)
        placeholderLabel.sizeToFit()
        notesTextView.addSubview(placeholderLabel)
        notesTextView.layer.borderColor = UIColor.tertiaryLabel.cgColor
        notesTextView.layer.borderWidth = 0.5
        notesTextView.layer.cornerRadius = 6
        placeholderLabel.frame.origin = CGPoint(x: 5, y: pointSize / 2)
        placeholderLabel.textColor = .tertiaryLabel
        placeholderLabel.isHidden = !notesTextView.text.isEmpty
    }
    
    //MARK: - @IBAction
    @IBAction func addFileTapped(_ sender: UIButton) {
        print("added file")
    }
    
    @IBAction func saveTaskTapped(_ sender: UIBarButtonItem) {
        print("save")
        guard let taskName = taskNameTF.text else { return }
        if indexPath == nil {
            task.name = taskName
            task.note = notesTextView.text
            RealmManager.shared.save(task: task, in: taskList)
        } else {
            let newtask = TaskModel()
            newtask.name = taskName
            newtask.note = notesTextView.text
            RealmManager.shared.updateTask(task: task, updatingTask: newtask)
        }
        dismiss(animated: true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        print("cancel")
        dismiss(animated: true)
    }
    
    @IBAction func taskNameTFAction(_ sender: UITextField) {
        updateSaveButtonState()
    }
    
    @IBAction func datePickerAction(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        print(dateFormatter.string(from: sender.date))
        datePickerImage.tintColor = .systemRed
        datePicker.alpha = 1
    }
    
    @IBAction func dateTimePickerAction(_ sender: UIDatePicker) {
        print(sender.date)
    }
    
}

//MARK: - UITextViewDelegate
extension TaskViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !notesTextView.text.isEmpty
    }
}

//MARK: - UITextFieldDelegate
extension TaskViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case taskNameTF:
            self.view.endEditing(true)
        default: break
        }
        
        return false
    }
}
