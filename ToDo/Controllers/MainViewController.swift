//
//  ViewController.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 09.08.2022.
//

import UIKit
import SnapKit
import RealmSwift
import Firebase

class MainViewController: UIViewController {
    
    //MARK: - IBOutlet
    @IBOutlet weak var mainTableView: UITableView!
    
    //MARK: - let/var
    private var arrayLists: Results<ListModel>!
    private var arrayCustomLists: Results<ListModel>!
    private var notificationTokenForArrayList: NotificationToken?
    private var notificationTokenForCustomArrayList: NotificationToken?
    private var currentUser: UserModel = UserModel()
    var userUID: String!
    
    private lazy var customTitleView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var userImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.circle")
        imageView.tintColor = .systemCyan
        return imageView
    }()
    
    private lazy var infoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Владимир Секерко", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.tintColor = .black
        button.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "magnifyingglass")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .systemCyan
        button.imageView?.contentMode = .scaleAspectFit
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var viewForFooter: UIView = {
        let view = UIView()
        let subview = UIView()
        subview.backgroundColor = .systemCyan
        view.backgroundColor = .white
        view.addSubview(subview)
        
        subview.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(1)
        }
        
        return view
    }()
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Списки"
        
        customTitleView.addSubview(userImage)
        customTitleView.addSubview(infoButton)
        customTitleView.addSubview(searchButton)
        
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "mainCell")
        
        // получаем юзера, который сейчас авторизовался
        guard let user = RealmManager.shared.realm.objects(UserModel.self).where({ $0.uid == userUID }).first else { return }
        currentUser = user
        // получаем его списки
        arrayLists = currentUser.lists.where { $0.index != .custom }
        arrayCustomLists = currentUser.lists.where { $0.index == .custom }
        // подписываемся на обновление данных в arrayLists
        notificationTokenForArrayList = arrayLists.observe { (changes) in
            switch changes {
            case .initial:
                break
            case .update(_, let deletions, let insertions, let modifications):
                self.mainTableView.performBatchUpdates { [weak self] in
                    guard let self = self else { return }
                    self.mainTableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0) }),
                                                  with: .automatic)
                    self.mainTableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                                  with: .automatic)
                    self.mainTableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                                  with: .automatic)
                } completion: { finished in
                    // ...
                }
            case .error(let error):
                fatalError("\(error)")
            }
        }
        
        // подписываемся на обновление данных в arrayCustomLists
        notificationTokenForCustomArrayList = arrayCustomLists.observe { (changes) in
            switch changes {
            case .initial:
                break
            case .update(_, let deletions, let insertions, let modifications):
                self.mainTableView.performBatchUpdates { [weak self] in
                    guard let self = self else { return }
                    self.mainTableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 1) }),
                                                  with: .automatic)
                    self.mainTableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 1) }),
                                                  with: .automatic)
                    self.mainTableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 1) }),
                                                  with: .automatic)
                } completion: { finished in
                    // ...
                }
            case .error(let error):
                fatalError("\(error)")
            }
        }
    }
    
    //MARK: - @IBAction
    @IBAction func createNewListTapped(_ sender: UIButton) {
        showAlert()
    }
    
    //MARK: - updateViewConstraints
    override func updateViewConstraints() {
        super.updateViewConstraints()
        setConstraint()
    }
    
    @objc private func searchButtonTapped() {
        guard let searchNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchNavigationController") as? UINavigationController else { return }

        present(searchNavigationController, animated: true)
    }
    
    @objc private func infoButtonTapped() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
    }
    
    private func showAlert() {
        let alertController = UIAlertController(title: "Новый список",
                                                message: "",
                                                preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default) { action in
            guard let text = alertController.textFields?.first?.text else { return }
            if text != "" {
                // создаем новый список задач и сохраняем в бд
                let newTaskList = ListModel()
                newTaskList.name = text
                newTaskList.index = .custom
                RealmManager.shared.save(list: newTaskList, in: self.currentUser)
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(ok)
        alertController.addAction(cancel)
        alertController.addTextField { textField in
            textField.placeholder = "Введите имя списка"
        }
        present(alertController, animated: true)
    }
    
    private func showEditAlert(_ list: ListModel) {
        let alertController = UIAlertController(title: "Хотите переименовать?",
                                                message: "Введите новое название списка",
                                                preferredStyle: .alert)
        let ok = UIAlertAction(title: "Изменить", style: .default) { action in
            guard let text = alertController.textFields?.first?.text,
                  text != "" else { return }
            RealmManager.shared.updateList(list: list, newValue: text)
        }
        let cancel = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(ok)
        alertController.addAction(cancel)
        alertController.addTextField { textField in
            textField.text = list.name
        }
        present(alertController, animated: true)
    }
    
    private func setConstraint() {
        
        customTitleView.snp.makeConstraints { make in
            make.width.equalTo(view.frame.width)
            make.height.equalTo(41)
        }
        
        userImage.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.leading.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
        }
        
        infoButton.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.height.equalTo(30)
            make.centerY.equalTo(userImage)
            make.leading.equalTo(userImage.snp.trailing).offset(8)
        }
        
        searchButton.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.centerY.equalTo(userImage)
            make.trailing.equalToSuperview().inset(32)
        }
        
        navigationItem.titleView = customTitleView
    }
}

//MARK: - UITableViewDelegate
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return viewForFooter
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        section == 0 ? 30 : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? arrayLists.count : arrayCustomLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = mainTableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath) as? MainTableViewCell else { return UITableViewCell() }
        
        cell.configure(with: indexPath.section == 0 ? arrayLists[indexPath.row] : arrayCustomLists[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let list = UIStoryboard(name: "List", bundle: nil).instantiateViewController(withIdentifier: "ListsViewController") as? ListViewController else { return }
        
        // переходя в список передает туда имя списка и id, чтобы внутри уже работать с его тасками
        list.title = indexPath.section == 0 ? arrayLists[indexPath.row].index.name : arrayCustomLists[indexPath.row].name
        list.listID = indexPath.section == 0 ? arrayLists[indexPath.row]._id : arrayCustomLists[indexPath.row]._id
        
        navigationController?.pushViewController(list, animated: true)
    }
    
    // удаление списка из бд
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            showActionSheet(title: "Элемент \"\(arrayCustomLists[indexPath.row].name)\" будет удален без возможности восстановления",
                            message: nil,
                            showCancel: true,
                            actions: [UIAlertAction(title: "Удаление списка",
                                                    style: .destructive,
                                                    handler: { [weak self] action in
                guard let self = self else { return }
                let list = self.arrayCustomLists[indexPath.row]
                RealmManager.shared.delete(list: list)
            })])
        }
    }
    
    // метод, который добавляет действие по свайпу вправо
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = listEdit(at: indexPath)
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    // метод, который будет переименовывать таск лист
    private func listEdit(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal,
                                        title: "title") { [weak self] action, view, completion in
            guard let self = self else { return }
            let list = self.arrayCustomLists[indexPath.row]
            self.showEditAlert(list)
            completion(true)
        }
        action.backgroundColor = .systemGreen
        action.image = UIImage(systemName: "pencil")
        return action
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        indexPath.section == 1
    }
}
