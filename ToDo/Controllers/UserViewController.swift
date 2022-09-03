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
    
    //MARK: - let/var
    private var imagePicker = UIImagePickerController()
    var user: UserModel!
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Параметры"
        tableVIew.register(UINib(nibName: "UserInfoCell", bundle: nil),
                           forCellReuseIdentifier: "userInfoCell")
        tableVIew.register(UINib(nibName: "SignOutCell", bundle: nil),
                           forCellReuseIdentifier: "signOutCell")
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
        case 0, 1:
            return 1
        case 2:
            return 2
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let userInfoCell = tableView.dequeueReusableCell(withIdentifier: "userInfoCell") as? UserInfoCell,
              let signOutCell = tableView.dequeueReusableCell(withIdentifier: "signOutCell") as? SignOutCell
        else { return UITableViewCell() }
        switch indexPath.section {
        case 0:
            userInfoCell.delegate = self
            userInfoCell.configure(with: user)
            return userInfoCell
        case 2:
            signOutCell.configure(index: indexPath.row)
            return signOutCell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.section == 0 ? 200 : 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

//MARK: - UserInfoCellDelegate
extension UserViewController: UserInfoCellDelegate {
    func showAlert() {
        let cameraAction = UIAlertAction(title: "Камера", style: .default) { _ in
            self.showImagePicker(withType: .camera)
        }
        let photoLibraryAction = UIAlertAction(title: "Библиотека изображений", style: .default) { _ in
            self.showImagePicker(withType: .photoLibrary)
        }
        
        let changePhoto = UIAlertAction(title: "Изменить фото", style: .default) { _ in
            self.showActionSheet(title: nil,
                                 message: nil,
                                 showCancel: true,
                                 actions: [cameraAction, photoLibraryAction])
        }
        
        let delete = UIAlertAction(title: "Удалить",
                                   style: .destructive) { _ in
            RealmManager.shared.deleteUserPhoto(user: self.user)
            self.tableVIew.reloadData()
        }
        
        let deletePhoto = UIAlertAction(title: "Удалить фото", style: .destructive) { _ in
            self.showActionSheet(title: "Фото будет удалено без возможности восстановления",
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
