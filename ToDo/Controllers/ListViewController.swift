//
//  ListsViewController.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 10.08.2022.
//

import UIKit
import RealmSwift

class ListViewController: UIViewController {
    //MARK: - @IBOutlet
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var addTaskView: UIView!
    @IBOutlet weak var settingsView: UIView!
    
    //MARK: - let/var
    private var listNotificationToken: NotificationToken?
    private var list: ListModel?
    var listID: ObjectId!
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTaskView.layer.cornerRadius = 6
        settingsView.layer.cornerRadius = 6
        
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        listTableView.register(UINib(nibName: "TaskCell", bundle: nil), forCellReuseIdentifier: "taskCell")
        
        // получаем объект списка по _id
        list = RealmManager.shared.realm.object(ofType: ListModel.self, forPrimaryKey: listID)
        // подписываемся на изменения в списке
        listNotificationToken = list?.tasks.observe({ (changes) in
            switch changes {
            case .initial: break
            case .update(_, let deletions, let insertions, let modifications):
                self.listTableView.performBatchUpdates {
                    self.listTableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                                  with: .automatic)
                    self.listTableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                                  with: .automatic)
                    self.listTableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                                  with: .automatic)
                } completion: { finished in
                    // ...
                }
            case .error(let error):
                fatalError("\(error)")
            }
        })

        listTableView.delegate = self
        listTableView.dataSource = self
        
        listTableView.separatorStyle = .none
        listTableView.showsVerticalScrollIndicator = false
    }
    
    //MARK: - @IBAction
    @IBAction func addTaskTapped(_ sender: UIButton) {
        guard let taskController = UIStoryboard(name: "Task", bundle: nil).instantiateViewController(withIdentifier: "TaskNavigationController") as? UINavigationController else { return }
        guard let controller = taskController.viewControllers.first as? TaskViewController else { return }
        controller.listID = listID
        present(taskController, animated: true)
    }
}

//MARK: - UITableViewDelegate
extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // проверка на то, что список еще существует
        if let saveList = list {
            if saveList.isInvalidated {
                return 0
            } else {
                return saveList.tasks.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let taskCell = listTableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as? TaskCell else { return UITableViewCell() }
        if let task = list?.tasks[indexPath.row] {
            taskCell.configure(with: task)
            return taskCell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let taskController = UIStoryboard(name: "Task", bundle: nil).instantiateViewController(withIdentifier: "TaskNavigationController") as? UINavigationController else { return }
        guard let controller = taskController.viewControllers.first as? TaskViewController else { return }
        // переходя с ячейки передаем еще индекс, чтобы понимать, что это не новая таска будет создаваться, а редактируется старая
        guard let task = list?.tasks[indexPath.row] else { return }
        controller.task = task
        controller.indexPath = indexPath
        controller.listID = listID
        present(taskController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let taskName = list?.tasks[indexPath.row].name else { return }
            showActionSheet(title: "Элемент \"\(taskName)\" будет удален без возможности восстановления", message: nil, showCancel: true, actions: [UIAlertAction(title: "Удалить задачу", style: .destructive, handler: { [weak self] action in
                guard let self = self,
                      let task = self.list?.tasks[indexPath.row],
                      let list = self.list else { return }
                RealmManager.shared.delete(task: task, index: indexPath.row, from: list)
            })])
        }
    }
}
