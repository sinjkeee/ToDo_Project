//
//  TaskViewController.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 12.08.2022.
//

import UIKit
import SnapKit

class TaskViewController: UIViewController {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var taskNameTF: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateTimePicker: UIDatePicker!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var saveTaskButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    //MARK: - let/var
    var placeholderLabel: UILabel!
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
        view.addGestureRecognizer(recognizer)
        
        taskNameTF.delegate = self
        notesTextView.delegate = self
        
        settingNotesTextView()
    }
    
    //MARK: - Custom methods
    @objc private func tap() {
        view.endEditing(true)
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
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        print("cancel")
        dismiss(animated: true)
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
