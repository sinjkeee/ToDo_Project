//
//  ListsViewController.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 10.08.2022.
//

import UIKit
import RealmSwift
import SnapKit
import UserNotifications

class ListViewController: UIViewController {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var addTaskView: UIView!
    @IBOutlet weak var settingsView: UIView!
    
    //MARK: - let/var
    private var currentTasksNotificationToken: NotificationToken?
    private var completedTaskNotificationToken: NotificationToken?
    private var notificationToken: NotificationToken?
    private var notificationCenter = UNUserNotificationCenter.current()
    private var currentTasks: Results<TaskModel>!
    private var completedTasks: Results<TaskModel>!
    private var list: ListModel?
    private var isHideCompletionTasks = true
    var listID: ObjectId!
    
    private lazy var viewForHeader: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        let button = UIButton(type: .system)
        button.backgroundColor = .clear
        view.addSubview(button)
        button.addTarget(self, action: #selector(hideCompletedTask(sender:)), for: .touchUpInside)
        button.setTitle("  Завершенные", for: .normal)
        button.setImage(UIImage(systemName: "chevron.forward"), for: .normal)
        
        button.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.leading.equalToSuperview().inset(10)
            make.top.equalToSuperview().inset(0)
        }
        
        return view
    }()
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTaskView.layer.cornerRadius = 6
        settingsView.layer.cornerRadius = 6
        
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        listTableView.register(UINib(nibName: "TaskCell", bundle: nil),
                               forCellReuseIdentifier: "taskCell")
        listTableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        
        // получаем объект списка по _id
        list = RealmManager.shared.realm.object(ofType: ListModel.self, forPrimaryKey: listID)
        // получаем текущие и завершенные таски
        currentTasks = list?.tasks.where{ $0.isCompleted == false }
        completedTasks = list?.tasks.where{ $0.isCompleted == true }
        // подписываемся на изменения в списке currentTasks
        notificationToken = list?.tasks.observe({ (changes) in
            switch changes {
            case .initial: break
            case .update(_, _, _, _):
                /*
                 var deletionsTask: TaskModel?
                 if let index = deletions.first {
                 deletionsTask = tasks[index]
                 }
                 var insertionsTask: TaskModel?
                 if let index = insertions.first {
                 insertionsTask = tasks[index]
                 }
                 var modificationsTask: TaskModel?
                 if let index = modifications.first {
                 modificationsTask = tasks[index]
                 }
                 
                 self.listTableView.performBatchUpdates { [weak self] in
                 guard let self = self else { return }
                 self.listTableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: deletionsTask?.isCompleted ?? false ? 1 : 0) }),
                 with: .automatic)
                 self.listTableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: insertionsTask?.isCompleted ?? false ? 1 : 0) }),
                 with: .automatic)
                 self.listTableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: modificationsTask?.isCompleted ?? false ? 1 : 0) }),
                 with: .automatic)
                 } completion: { finished in
                 // ...
                 }
                 */
                self.listTableView.reloadData()
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
        guard let taskController = UIStoryboard(name: "Task", bundle: nil).instantiateViewController(withIdentifier: "TaskNavigationController") as? UINavigationController,
              let controller = taskController.viewControllers.first as? TaskViewController
        else { return }
        controller.listID = listID
        present(taskController, animated: true)
    }
    
    @objc private func hideCompletedTask(sender: UIButton) {
        sender.setImage(UIImage(systemName: isHideCompletionTasks ? "chevron.down" : "chevron.forward"), for: .normal)
        isHideCompletionTasks.toggle()
        listTableView.reloadData()
    }
}

//MARK: - UITableViewDelegate
extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = list {
            if list.isInvalidated { // проверка на то, что список еще существует
                return 0
            } else { // если секция 1 смотрим isHideCompletionTasks и или 0 задач показываем или все, что есть
                return section == 0 ? (list.tasks.where{$0.isCompleted == false}.count) : isHideCompletionTasks ? 0 : (list.tasks.where{$0.isCompleted == true}.count)
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return viewForHeader
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let list = list else { return 0 }
        // проверка есть ли завершенные таски и если да, то показываем хэдэр
        return section == 1 ? list.tasks.filter({$0.isCompleted == true}).count > 0 ? 35 : 0 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let taskCell = listTableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as? TaskCell,
              let list = list else { return UITableViewCell() }
        
        taskCell.task = indexPath.section == 0 ? (list.tasks.where{$0.isCompleted == false}[indexPath.row]) : (list.tasks.where{$0.isCompleted == true}[indexPath.row])
        taskCell.configure(with: indexPath.section == 0 ? (list.tasks.where{$0.isCompleted == false}[indexPath.row]) : (list.tasks.where{$0.isCompleted == true}[indexPath.row]))
        return taskCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let taskController = UIStoryboard(name: "Task", bundle: nil).instantiateViewController(withIdentifier: "TaskNavigationController") as? UINavigationController,
              let controller = taskController.viewControllers.first as? TaskViewController,
              let list = list
        else { return }
        
        // переходя с ячейки передаем еще индекс, чтобы понимать, что это не новая таска будет создаваться, а редактируется старая
        controller.task = indexPath.section == 0 ? (list.tasks.where{$0.isCompleted == false}[indexPath.row]) : (list.tasks.where{$0.isCompleted == true}[indexPath.row])
        controller.indexPath = indexPath
        controller.listID = listID
        present(taskController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let taskName = indexPath.section == 0 ? list?.tasks.where({$0.isCompleted == false})[indexPath.row].name : list?.tasks.where({$0.isCompleted == true})[indexPath.row].name else { return }
            showActionSheet(title: "Элемент \"\(taskName)\" будет удален без возможности восстановления",
                            message: nil,
                            showCancel: true,
                            actions: [UIAlertAction(title: "Удалить задачу",
                                                    style: .destructive,
                                                    handler: { [weak self] action in
                guard let self = self,
                      let task = indexPath.section == 0 ? self.list?.tasks.where({$0.isCompleted == false})[indexPath.row] : self.list?.tasks.where({$0.isCompleted == true})[indexPath.row],
                      let list = self.list
                else { return }
                
                let index = list.tasks.firstIndex { element in
                    element._id == task._id
                }
                
                guard let index = index else { return }
                self.notificationCenter.removePendingNotificationRequests(withIdentifiers: [task._id.stringValue])
                RealmManager.shared.delete(task: task, index: index, from: list)
            })])
        }
    }
}
