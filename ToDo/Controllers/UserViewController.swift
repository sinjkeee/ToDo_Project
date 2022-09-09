//
//  UserViewController.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 31.08.2022.
//

import UIKit

class UserViewController: UIViewController {
    
    //MARK: - @IBOutlets
    @IBOutlet weak var tableVIew: UITableView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    //MARK: - let/var
    private var imagePicker = UIImagePickerController()
    var user: UserModel!
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.title = "Done".localized()
        title = "Settings".localized()
        tableVIew.register(UINib(nibName: "UserInfoCell", bundle: nil),
                           forCellReuseIdentifier: "userInfoCell")
        tableVIew.register(UINib(nibName: "SignOutCell", bundle: nil),
                           forCellReuseIdentifier: "signOutCell")
        tableVIew.register(UINib(nibName: "ListCell", bundle: nil),
                           forCellReuseIdentifier: "listCell")
        imagePicker.delegate = self
        tableVIew.dataSource = self
        tableVIew.delegate = self
    }
    
    //MARK: - @IBActions
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    //MARK: - custom methods
    private func showImagePicker(withType type: UIImagePickerController.SourceType) {
        imagePicker.sourceType = type
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
}

//MARK: - UITableViewDelegate
extension UserViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 4
        case 2:
            return 2
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let userInfoCell = tableView.dequeueReusableCell(withIdentifier: "userInfoCell") as? UserInfoCell,
              let signOutCell = tableView.dequeueReusableCell(withIdentifier: "signOutCell") as? SignOutCell,
              let listCell = tableView.dequeueReusableCell(withIdentifier: "listCell") as? ListCell
        else { return UITableViewCell() }
        switch indexPath.section {
        case 0:
            userInfoCell.delegate = self
            userInfoCell.configure(with: user)
            return userInfoCell
        case 1:
            listCell.delegate = self
            listCell.configure(index: indexPath.row)
            return listCell
        case 2:
            signOutCell.configure(index: indexPath.row)
            return signOutCell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.section == 0 ? 200 : 47
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 1 ? "SMART LISTS".localized() : ""
    }
}

//MARK: - UserInfoCellDelegate
extension UserViewController: UserInfoCellDelegate {
    func showAlert() {
        let cameraAction = UIAlertAction(title: "Camera".localized(), style: .default) { _ in
            self.showImagePicker(withType: .camera)
        }
        let photoLibraryAction = UIAlertAction(title: "Photo library".localized(), style: .default) { _ in
            self.showImagePicker(withType: .photoLibrary)
        }
        
        let changePhoto = UIAlertAction(title: "Edit photo".localized(), style: .default) { _ in
            self.showActionSheet(title: nil,
                                 message: nil,
                                 showCancel: true,
                                 actions: [cameraAction, photoLibraryAction])
        }
        
        let delete = UIAlertAction(title: "Delete".localized(),
                                   style: .destructive) { _ in
            RealmManager.shared.deleteUserPhoto(user: self.user)
            self.tableVIew.reloadData()
        }
        
        let deletePhoto = UIAlertAction(title: "Delete photo".localized(), style: .destructive) { _ in
            self.showActionSheet(title: "The photo will be permanently deleted".localized(),
                                 message: nil,
                                 showCancel: true,
                                 actions: [delete])
        }
        
        showActionSheet(title: nil,
                        message: nil,
                        showCancel: true,
                        actions: [changePhoto, deletePhoto])
    }
}

//MARK: - UIImagePickerControllerDelegate
extension UserViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage,
              let data = image.jpegData(compressionQuality: 1)
        else { return }
        
        RealmManager.shared.updateUserPhoto(user: self.user, image: data)
        tableVIew.reloadData()
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

//MARK: - ListCellDelegate
extension UserViewController: ListCellDelegate {
    func changeListVisibility(index: Int) {
        switch index {
        case 0:
            let importantList = RealmManager.shared.realm.objects(ListModel.self).first { list in
                list.index == ListIndex.two
            }
            guard let importantList = importantList else { return }
            RealmManager.shared.updateHiddenListProterty(list: importantList)
        case 1:
            let dateOfCompleted = RealmManager.shared.realm.objects(ListModel.self).first { list in
                list.index == ListIndex.three
            }
            guard let dateOfCompleted = dateOfCompleted else { return }
            RealmManager.shared.updateHiddenListProterty(list: dateOfCompleted)
        case 2:
            let completedTasks = RealmManager.shared.realm.objects(ListModel.self).first { list in
                list.index == ListIndex.four
            }
            guard let completedTasks = completedTasks else { return }
            RealmManager.shared.updateHiddenListProterty(list: completedTasks)
        default:
            let tasksList = RealmManager.shared.realm.objects(ListModel.self).first { list in
                list.index == ListIndex.five
            }
            guard let tasksList = tasksList else { return }
            RealmManager.shared.updateHiddenListProterty(list: tasksList)
        }
    }
}
