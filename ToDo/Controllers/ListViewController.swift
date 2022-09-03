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

enum ListOfColors: Int, PersistableEnum, CaseIterable {
    case one = 1, two = 2, three = 3, four = 4, five = 5, six = 6, seven = 7, eight = 8, nine = 9, ten = 10, eleven = 11, twelve = 12, thirteen = 13
    
    var color: UIColor {
        switch self {
        case .one:
            return UIColor(red: 255/255, green: 192/255, blue: 203/255, alpha: 1)
        case .two:
            return UIColor(red: 250/255, green: 92/255, blue: 92/255, alpha: 1)
        case .three:
            return UIColor(red: 216/255, green: 191/255, blue: 216/255, alpha: 1)
        case .four:
            return UIColor(red: 255/255, green: 204/255, blue: 0/255, alpha: 1)
        case .five:
            return UIColor(red: 100/255, green: 149/255, blue: 237/255, alpha: 1)
        case .six:
            return UIColor(red: 204/255, green: 119/255, blue: 34/255, alpha: 1)
        case .seven:
            return UIColor.systemCyan
        case .eight:
            return UIColor.systemGray
        case .nine:
            return UIColor.systemMint
        case .ten:
            return UIColor.systemGreen
        case .eleven:
            return UIColor.systemIndigo
        case .twelve:
            return UIColor.systemOrange
        case .thirteen:
            return UIColor.systemTeal
        }
    }
}

class ListViewController: UIViewController {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var addTaskView: UIView!
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var bottomConstraintContentView: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - let/var
    private var currentTasksNotificationToken: NotificationToken?
    private var completedTaskNotificationToken: NotificationToken?
    private var notificationToken: NotificationToken?
    private var notificationCenter = UNUserNotificationCenter.current()
    private var list: ListModel?
    private var isHideCompletionTasks = false
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
        
        bottomConstraintContentView.constant = -350
        
        contentView.layer.cornerRadius = 10
        
        addTaskView.layer.cornerRadius = 6
        addTaskView.layer.masksToBounds = false
        addTaskView.layer.shadowColor = UIColor.black.cgColor
        addTaskView.layer.shadowRadius = 2
        addTaskView.layer.shadowOpacity = 0.35
        addTaskView.layer.shadowOffset = CGSize(width: 3, height: 3)
        
        settingsView.layer.cornerRadius = 6
        settingsView.layer.masksToBounds = false
        settingsView.layer.shadowColor = UIColor.black.cgColor
        settingsView.layer.shadowRadius = 2
        settingsView.layer.shadowOpacity = 0.35
        settingsView.layer.shadowOffset = CGSize(width: 3, height: 3)
        
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        listTableView.register(UINib(nibName: "TaskCell", bundle: nil),
                               forCellReuseIdentifier: "taskCell")
        listTableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        
        collectionView.register(UINib(nibName: "ColorCell", bundle: nil),
                                forCellWithReuseIdentifier: "colorCell")
        collectionView.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        // получаем объект списка по _id
        list = RealmManager.shared.realm.object(ofType: ListModel.self, forPrimaryKey: listID)
        
        self.view.backgroundColor = list?.color.color
        
        // подписываемся на изменения задач в текущем листе
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
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        listTableView.delegate = self
        listTableView.dataSource = self
        
        listTableView.separatorStyle = .none
        listTableView.showsVerticalScrollIndicator = false
        /*
        settingsView.isHidden = title == "Завершенные" ? true : false
        addTaskView.isHidden = title == "Завершенные" ? true : false
        */
    }
    
    //MARK: - @IBAction
    @IBAction func addTaskTapped(_ sender: UIButton) {
        guard let taskController = UIStoryboard(name: "Task", bundle: nil).instantiateViewController(withIdentifier: "TaskNavigationController") as? UINavigationController,
              let controller = taskController.viewControllers.first as? TaskViewController
        else { return }
        controller.listID = listID
        present(taskController, animated: true)
    }
    
    @IBAction func settingsTapped(_ sender: UIButton) {
        bottomConstraintContentView.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.bottomConstraintContentView.constant = -10
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        bottomConstraintContentView.constant = -350
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
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
                                                    handler: { [weak self] _ in
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

//MARK: - UICollectionViewDelegate
extension ListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ListOfColors.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let colorCell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath) as? ColorCell else { return UICollectionViewCell() }
        let color = ListOfColors.allCases[indexPath.row]
        colorCell.configure(color: color.color, isCurrentColor: list?.color.color == color.color)
        return colorCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.view.backgroundColor = ListOfColors.allCases[indexPath.row].color
        let currentColor = ListOfColors.allCases[indexPath.row]
        guard let list = list else { return }
        RealmManager.shared.updateColor(list: list, newColor: currentColor)
        collectionView.reloadData()
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension ListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 30, height: 30)
    }
}
