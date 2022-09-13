//
//  TaskViewController.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 12.08.2022.
//

import UIKit
import SnapKit
import RealmSwift
import UserNotifications

class TaskViewController: UIViewController {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var taskNameTF: UITextField!
    // дата выполнения таски
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var datePickerLabel: UILabel!
    @IBOutlet weak var datePickerImage: UIImageView!
    @IBOutlet weak var deleteDatePickerButton: UIButton!
    // дата уведомления
    @IBOutlet weak var dateTimePicker: UIDatePicker!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var dateTimeImage: UIImageView!
    @IBOutlet weak var deleteDateTimeButton: UIButton!
    
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var notesTextView: UITextView!
    
    @IBOutlet weak var saveTaskButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    //MARK: - let/var
    private var placeholderLabel: UILabel!
    private var taskList: ListModel!
    private var imagePicker = UIImagePickerController()
    private var imagesLocal = [Data]()
    private var imagesArray = List<Data>()
    private var notificationCenter = UNUserNotificationCenter.current()
    private var reminderTime: Date?
    private var dateOfCompletion: Date?
    var task: TaskModel = TaskModel()
    var indexPath: IndexPath?
    var listID: ObjectId?
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cancelButton.title = "Cancel".localized()
        saveTaskButton.title = "Save".localized()
        taskNameTF.placeholder = "Task name".localized()
        datePickerLabel.text = "Due Date".localized()
        dateTimeLabel.text = "Remind Me".localized()
        addImageButton.setTitle("Add Image".localized(), for: .normal)
        
        deleteDateTimeButton.isHidden = true
        deleteDatePickerButton.isHidden = true
        
        notificationCenter.delegate = self
        
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView.register(UINib(nibName: "ImageCell",
                                           bundle: nil),
                                     forCellWithReuseIdentifier: "ImageCell")
        imageCollectionView.showsVerticalScrollIndicator = false
        imageCollectionView.showsHorizontalScrollIndicator = false
//        imageCollectionView.backgroundColor = .white
        imageCollectionView.contentInset = UIEdgeInsets(top: 0,
                                                        left: ImageCellConstants.leftDistanceToView,
                                                        bottom: 0,
                                                        right: ImageCellConstants.rightDistanceToView)
        
        imagePicker.delegate = self
        
        taskList = listID != nil ? RealmManager.shared.realm.object(ofType: ListModel.self,
                                                                    forPrimaryKey: listID) : ListModel()
        
        taskNameTF.delegate = self
        notesTextView.delegate = self
        
        updateUI()
        settingNotesTextView()
        updateSaveButtonState()
    }
    
    //MARK: - Custom methods
    private func updateUI() {
        taskNameTF.text = task.name
        notesTextView.text = task.note
        dateOfCompletion = task.dateOfCompletion
        reminderTime = task.reminderTime
        datePicker.date = dateOfCompletion ?? Date()
        dateTimePicker.date = reminderTime ?? Date()
        task.images.forEach { imageData in
            self.imagesLocal.append(imageData)
        }
        datePickerImage.tintColor = dateOfCompletion == nil ? .systemGray2 : .systemBlue
        dateTimeImage.tintColor = reminderTime == nil ? .systemGray2 : .systemBlue
        datePicker.alpha = dateOfCompletion == nil ? 0.2 : 1
        dateTimePicker.alpha = reminderTime == nil ? 0.2 : 1
        deleteDatePickerButton.isHidden = dateOfCompletion == nil
        deleteDateTimeButton.isHidden = reminderTime == nil
    }
    
    private func updateSaveButtonState() {
        guard let taskName = taskNameTF.text else { return }
        self.saveTaskButton.isEnabled = !taskName.isEmpty
    }
    
    // add placeholder and setting text view
    private func settingNotesTextView() {
        placeholderLabel = UILabel()
        placeholderLabel.text = "Note".localized()
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
    
    private func showImagePicker(withType type: UIImagePickerController.SourceType) {
        imagePicker.sourceType = type
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    private func saveNewTask(taskName: String) {
        task.name = taskName
        task.note = notesTextView.text
        task.images = imagesArray
        task.reminderTime = reminderTime
        task.dateOfCompletion = self.taskList.index == ListIndex.three ? Date() : dateOfCompletion //dateOfCompletion
        task.isImportant = self.taskList.index == ListIndex.two ? true : false
        imagesLocal.forEach { data in
            task.images.append(data)
        }
        
        if let time = reminderTime {
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [task._id.stringValue])
            sendNotifications(title: "Reminder".localized(),
                              body: task.name,
                              date: time,
                              id: task._id.stringValue)
        } else {
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [task._id.stringValue])
        }
        
        RealmManager.shared.save(task: task, in: taskList)
    }
    
    private func updateTask(taskName: String) {
        let newtask = TaskModel()
        newtask.name = taskName
        newtask.note = notesTextView.text
        newtask.dateOfCompletion = dateOfCompletion
        newtask.reminderTime = reminderTime
        imagesLocal.forEach { data in
            newtask.images.append(data)
        }
        
        if let time = reminderTime {
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [task._id.stringValue])
            sendNotifications(title: "Reminder".localized(),
                              body: task.name,
                              date: time,
                              id: task._id.stringValue)
        } else {
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [task._id.stringValue])
        }
        
        RealmManager.shared.updateTask(task: task, updatingTask: newtask)
    }
    
    private func sendNotifications(title: String, body: String, date: Date, id: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute],
                                                             from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents,
                                                    repeats: false)
        
        let request = UNNotificationRequest(identifier: id,
                                            content: content,
                                            trigger: trigger)
        
        notificationCenter.add(request) { error in
            print(error?.localizedDescription as Any)
        }
    }
    
    //MARK: - @IBAction
    @IBAction func addFileTapped(_ sender: UIButton) {
        let camera = UIAlertAction(title: "Camera".localized(),
                                   style: .default) { _ in
            self.showImagePicker(withType: .camera)
        }
        
        let photoLibrary = UIAlertAction(title: "Photo library".localized(),
                                         style: .default) { _ in
            self.showImagePicker(withType: .photoLibrary)
        }
        
        showActionSheet(title: nil,
                        message: nil,
                        showCancel: true,
                        actions: [camera, photoLibrary])
    }
    
    @IBAction func saveTaskTapped(_ sender: UIBarButtonItem) {
        guard let taskName = taskNameTF.text else { return }
        indexPath == nil ? saveNewTask(taskName: taskName) : updateTask(taskName: taskName)
        dismiss(animated: true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func taskNameTFAction(_ sender: UITextField) {
        updateSaveButtonState()
    }
    
    @IBAction func datePickerAction(_ sender: UIDatePicker) {
        dateOfCompletion = sender.date
        datePickerImage.tintColor = .systemBlue
        datePicker.alpha = 1
        deleteDatePickerButton.isHidden = false
    }
    
    @IBAction func dateTimePickerAction(_ sender: UIDatePicker) {
        notificationCenter.requestAuthorization(options: [.sound, .badge, .alert]) { granted, error in
            guard granted else { return }
        }
        
        notificationCenter.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                self.reminderTime = sender.date
                self.dateTimeImage.tintColor = .systemBlue
                self.dateTimePicker.alpha = 1
                self.deleteDateTimeButton.isHidden = false
            }
        }
    }
    
    @IBAction func deleteDatePickerTapped(_ sender: UIButton) {
        dateOfCompletion = nil
        datePicker.alpha = 0.2
        datePickerImage.tintColor = .systemGray2
        deleteDatePickerButton.isHidden = true
    }
    
    @IBAction func deleteDateTimeTapped(_ sender: UIButton) {
        reminderTime = nil
        dateTimePicker.alpha = 0.2
        dateTimeImage.tintColor = .systemGray2
        deleteDateTimeButton.isHidden = true
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

//MARK: - UIImagePickerControllerDelegate
extension TaskViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage,
              let data = image.jpegData(compressionQuality: 1)
        else { return }
        
        imagesLocal.append(data)
        imageCollectionView.reloadData()
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

//MARK: - UICollectionViewDelegate
extension TaskViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesLocal.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let imageCell = imageCollectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCell else { return UICollectionViewCell() }
        imageCell.delegate = self
        imageCell.configure(withData: imagesLocal[indexPath.row], index: indexPath.row)
        return imageCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let imageViewController = UIStoryboard(name: "Task", bundle: nil).instantiateViewController(withIdentifier: "ImageViewController") as? ImageViewController else { return }
        let imageData = imagesLocal[indexPath.row]
        imageViewController.imageData = imageData
        present(imageViewController, animated: true, completion: nil)
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension TaskViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return ImageCellConstants.galleryMinimumLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: ImageCellConstants.galleryItemWidth,
                      height: imageCollectionView.frame.height * 0.8)
    }
}

//MARK: - ImageCellDelegate
extension TaskViewController: ImageCellDelegate {
    func shareImage(image: UIImage) {
        let shareController = UIActivityViewController(activityItems: [image],
                                                       applicationActivities: nil)
        
        shareController.completionWithItemsHandler = { _, bool, _, _ in
            if bool {
                print("Успешно!")
            }
        }
        
        present(shareController, animated: true)
    }
    
    func deleteImage(index: Int) {
        showActionSheet(title: "Are you sure you want to delete this file?".localized(),
                        message: nil,
                        showCancel: true,
                        actions: [UIAlertAction(title: "Delete a file".localized(),
                                                style: .destructive,
                                                handler: { _ in
            self.imagesLocal.remove(at: index)
            self.imageCollectionView.reloadData()
        })])
    }
}

//MARK: - UNUserNotificationCenterDelegate
extension TaskViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // тут будет переход в таску, после нажатия на уведомление
        print(#function)
    }
}
