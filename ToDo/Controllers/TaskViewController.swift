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
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    //MARK: - let/var
    private var placeholderLabel: UILabel!
    private var taskList: ListModel!
    private var imagePicker = UIImagePickerController()
    private var imagesLocal = [Data]()
    private var imagesArray = List<Data>()
    var task: TaskModel = TaskModel()
    var indexPath: IndexPath?
    var listID: ObjectId?
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.minimumDate = Date()
        dateTimePicker.minimumDate = Date()
        
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        imageCollectionView.register(UINib(nibName: "ImageCell",
                                           bundle: nil),
                                     forCellWithReuseIdentifier: "ImageCell")
        imageCollectionView.showsVerticalScrollIndicator = false
        imageCollectionView.showsHorizontalScrollIndicator = false
        imageCollectionView.backgroundColor = .white
        imageCollectionView.contentInset = UIEdgeInsets(top: 0,
                                                        left: ImageCellConstants.leftDistanceToView,
                                                        bottom: 0,
                                                        right: ImageCellConstants.rightDistanceToView)
        
        imagePicker.delegate = self
        
        taskList = listID != nil ? RealmManager.shared.realm.object(ofType: ListModel.self, forPrimaryKey: listID) : ListModel()

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
        task.images.forEach { imageData in
            self.imagesLocal.append(imageData)
        }
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
    
    private func showImagePicker(withType type: UIImagePickerController.SourceType) {
        imagePicker.sourceType = type
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    private func saveNewTask(taskName: String) {
        task.name = taskName
        task.note = notesTextView.text
        task.images = imagesArray
        imagesLocal.forEach { data in
            task.images.append(data)
        }
        RealmManager.shared.save(task: task, in: taskList)
    }
    
    private func updateTask(taskName: String) {
        let newtask = TaskModel()
        newtask.name = taskName
        newtask.note = notesTextView.text
        imagesLocal.forEach { data in
            newtask.images.append(data)
        }
        RealmManager.shared.updateTask(task: task, updatingTask: newtask)
    }
    
    //MARK: - @IBAction
    @IBAction func addFileTapped(_ sender: UIButton) {
        showActionSheet(title: nil,
                        message: nil,
                        showCancel: true,
                        actions: [UIAlertAction(title: "Камера",
                                                style: .default,
                                                handler: { _ in
            self.showImagePicker(withType: .camera) }),
                                  UIAlertAction(title: "Библиотека изображений",
                                                style: .default,
                                                handler: { _ in
            self.showImagePicker(withType: .photoLibrary) })
                        ])
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM, yyyy"
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
        return CGSize(width: ImageCellConstants.galleryItemWidth, height: imageCollectionView.frame.height * 0.8)
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
        showActionSheet(title: "Вы действительно хотите удалить этот файл?",
                        message: nil,
                        showCancel: true,
                        actions: [UIAlertAction(title: "Удаление файла",
                                                style: .destructive,
                                                handler: { _ in
            self.imagesLocal.remove(at: index)
            self.imageCollectionView.reloadData()
        })])
    }
}
