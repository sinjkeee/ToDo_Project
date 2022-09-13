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
    @IBOutlet weak var addNewTaskButton: UIButton!
    @IBOutlet weak var settingsView: UIView!
    // setting view
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var bottomConstraintContentView: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var colorTextLabel: UILabel!
    @IBOutlet weak var sortTextLabel: UILabel!
    @IBOutlet weak var alphabetLabel: UILabel!
    @IBOutlet weak var importantLabel: UILabel!
    @IBOutlet weak var byDateOfCompletedLabel: UILabel!
    @IBOutlet weak var byDateOfCreationLabel: UILabel!
    
    
    @IBOutlet weak var alphabetSwitch: UISwitch!
    @IBOutlet weak var alphabetButton: UIButton!
    
    @IBOutlet weak var importantSwitch: UISwitch!
    @IBOutlet weak var importantButton: UIButton!
    
    
    @IBOutlet weak var dateOfCompletionSwitch: UISwitch!
    @IBOutlet weak var dateOfCompletionButton: UIButton!
    
    @IBOutlet weak var dateOfCreationSwitch: UISwitch!
    @IBOutlet weak var dateOfCreationButton: UIButton!
    
    //MARK: - let/var
    private var notificationToken: NotificationToken?
    private var sortedForList: SortedForList!
    private var sortedTasks: [TaskModel]?
    private var notificationCenter = UNUserNotificationCenter.current()
    private var list: ListModel?
    private var isHideCompletionTasks = false
    private var sortingClosure: ((TaskModel, TaskModel) -> Bool)?
    var listID: ObjectId!
    
    private lazy var viewForHeader: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.backgroundColor = .systemGroupedBackground.withAlphaComponent(0.4)
        button.cornerAndShadow(cornerRadius: 6,
                               shadowRadius: 2,
                               shadowOffset: CGSize(width: 3, height: 2))
        view.addSubview(button)
        button.addTarget(self,
                         action: #selector(hideCompletedTask(sender:)),
                         for: .touchUpInside)
        button.setTitle("  Completed".localized(), for: .normal)
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        
        button.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.width.equalTo(150)
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
        backgroundView.isHidden = true
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        backgroundView.addGestureRecognizer(recognizer)
        // setting view title
        mainLabel.text = "List options".localized()
        doneButton.setTitle("Done".localized(), for: .normal)
        colorTextLabel.text = "Background color:".localized()
        sortTextLabel.text = "Sort:".localized()
        alphabetLabel.text = "Alphabetically".localized()
        importantLabel.text = "Importance".localized()
        byDateOfCompletedLabel.text = "Due Date".localized()
        byDateOfCreationLabel.text = "Creation Date".localized()
        
        addNewTaskButton.setTitle("   Add a new Task".localized(), for: .normal)
        addTaskView.cornerAndShadow(cornerRadius: 6,
                                    shadowRadius: 2,
                                    shadowOffset: CGSize(width: 3, height: 3))
        settingsView.cornerAndShadow(cornerRadius: 6,
                                     shadowRadius: 2,
                                     shadowOffset: CGSize(width: 3, height: 3))

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
        self.sortedForList = list?.listSortType
        self.view.backgroundColor = list?.color.color
        
        self.updateData()
        self.updateSwitchState()
        
        // подписываемся на изменения задач в текущем листе
        notificationToken = list?.tasks.observe({ (changes) in
            switch changes {
            case .initial: break
            case .update(_, _, _, _):
                self.updateData()
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
        
        //settingsView.isHidden = title == "Завершенные"
        addTaskView.isHidden = title == "Completed".localized()
    }
    
    //MARK: - private methods
    private func updateSwitchState() {
        alphabetSwitch.isOn = sortedForList.sortType == .alphabet
        alphabetButton.setImage(UIImage(systemName: sortedForList.isAscident ? "chevron.up" : "chevron.down"), for: .normal)
        alphabetButton.isHidden = !(sortedForList.sortType == .alphabet)
        
        importantSwitch.isOn = sortedForList.sortType == .isImportant
        importantButton.setImage(UIImage(systemName: sortedForList.isAscident ? "chevron.up" : "chevron.down"), for: .normal)
        importantButton.isHidden = !(sortedForList.sortType == .isImportant)
        
        dateOfCompletionSwitch.isOn = sortedForList.sortType == .dateOfCompletion
        dateOfCompletionButton.setImage(UIImage(systemName: sortedForList.isAscident ? "chevron.up" : "chevron.down"), for: .normal)
        dateOfCompletionButton.isHidden = !(sortedForList.sortType == .dateOfCompletion)
        
        dateOfCreationSwitch.isOn = sortedForList.sortType == .dateOfCreation
        dateOfCreationButton.setImage(UIImage(systemName: sortedForList.isAscident ? "chevron.up" : "chevron.down"), for: .normal)
        dateOfCreationButton.isHidden = !(sortedForList.sortType == .dateOfCreation)
    }
    
    private func updateData() {
        switch sortedForList.sortType {
        case .alphabet:
            sortingClosure = sortedForList.isAscident ?
            {$0.name.lowercased() < $1.name.lowercased()} :
            {$0.name.lowercased() > $1.name.lowercased()}
        case .isImportant:
            sortingClosure = sortedForList.isAscident ?
            {$0.isImportant && !$1.isImportant} :
            {!$0.isImportant && $1.isImportant}
        case .dateOfCreation:
            sortingClosure = sortedForList.isAscident ?
            {$0.dateOfCreation > $1.dateOfCreation} :
            {$0.dateOfCreation < $1.dateOfCreation}
        case .dateOfCompletion:
            sortingClosure = sortedForList.isAscident ?
            {$0.dateOfCompletion ?? Date() < $1.dateOfCompletion ?? Date()} :
            {$0.dateOfCompletion ?? Date() > $1.dateOfCompletion ?? Date()}
        }
        
        guard let sortingClosure = sortingClosure else { return }
        self.sortedTasks = RealmManager.shared.realm.object(ofType: ListModel.self, forPrimaryKey: self.listID)?.tasks.sorted(by: sortingClosure)
        self.listTableView.reloadData()
    }
    
    //MARK: - @IBAction
    @objc private func tapped() {
        bottomConstraintContentView.constant = -350
        UIView.animate(withDuration: 0.3) {
            self.backgroundView.alpha = 0
            self.view.layoutIfNeeded()
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.backgroundView.isHidden = true
            }
        }
    }
    
    @IBAction func addTaskTapped(_ sender: UIButton) {
        guard let taskController = UIStoryboard(name: "Task", bundle: nil).instantiateViewController(withIdentifier: "TaskNavigationController") as? UINavigationController,
              let controller = taskController.viewControllers.first as? TaskViewController
        else { return }
        controller.listID = listID
        taskController.modalPresentationStyle = .fullScreen
        present(taskController, animated: true)
    }
    
    @IBAction func settingsTapped(_ sender: UIButton) {
        backgroundView.isHidden = false
        backgroundView.alpha = 0
        bottomConstraintContentView.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.backgroundView.alpha = 0.4
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
            self.backgroundView.alpha = 0
            self.view.layoutIfNeeded()
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.backgroundView.isHidden = true
            }
        }
    }
    
    @objc private func hideCompletedTask(sender: UIButton) {
        sender.setImage(UIImage(systemName: isHideCompletionTasks ? "chevron.down" : "chevron.forward"), for: .normal)
        isHideCompletionTasks.toggle()
        listTableView.reloadData()
    }
    
    @IBAction func alphabetSwitchAction(_ sender: UISwitch) {
        if sender.isOn {
            guard let list = list else { return }
            RealmManager.shared.updateListSortingType(with: list, type: .alphabet)
            self.updateSwitchState()
            self.updateData()
        } else {
            self.updateData()
            self.alphabetSwitch.isOn = true
        }
    }
    
    @IBAction func ascidentToogle(_ sender: UIButton) {
        guard let list = list else { return }
        RealmManager.shared.updateListSortingAscident(with: list)
        self.updateData()
        self.updateSwitchState()
    }
    
    @IBAction func importantSwitchAction(_ sender: UISwitch) {
        if sender.isOn {
            guard let list = list else { return }
            RealmManager.shared.updateListSortingType(with: list, type: .isImportant)
            self.updateSwitchState()
            self.updateData()
        } else {
            self.updateData()
            self.importantSwitch.isOn = true
        }
    }
    
    @IBAction func dateOfCompletionSwitchAction(_ sender: UISwitch) {
        if sender.isOn {
            guard let list = list else { return }
            RealmManager.shared.updateListSortingType(with: list, type: .dateOfCompletion)
            self.updateSwitchState()
            self.updateData()
        } else {
            self.updateData()
            self.dateOfCompletionSwitch.isOn = true
        }
    }
    
    @IBAction func dateOfCreationSwitchAction(_ sender: UISwitch) {
        if sender.isOn {
            guard let list = list else { return }
            RealmManager.shared.updateListSortingType(with: list, type: .dateOfCreation)
            self.updateSwitchState()
            self.updateData()
        } else {
            self.updateData()
            self.dateOfCreationSwitch.isOn = true
        }
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
                return section == 0 ? sortedTasks?.filter({$0.isCompleted == false}).count ?? 0 : isHideCompletionTasks ? 0 : sortedTasks?.filter({$0.isCompleted == true}).count ?? 0
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
        // проверка есть ли завершенные таски и если да, то показываем хэдэр
        return section == 1 ? sortedTasks?.filter({$0.isCompleted == true}).count ?? 0 > 0 ? 35 : 0 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let taskCell = listTableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as? TaskCell,
              let task = indexPath.section == 0 ? sortedTasks?.filter({$0.isCompleted == false})[indexPath.row] : sortedTasks?.filter({$0.isCompleted == true})[indexPath.row]
        else { return UITableViewCell() }
        
        taskCell.configure(with: task)
        return taskCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let taskController = UIStoryboard(name: "Task", bundle: nil).instantiateViewController(withIdentifier: "TaskNavigationController") as? UINavigationController,
              let controller = taskController.viewControllers.first as? TaskViewController,
              let task = indexPath.section == 0 ? sortedTasks?.filter({$0.isCompleted == false})[indexPath.row] : sortedTasks?.filter({$0.isCompleted == true})[indexPath.row]
        else { return }
        
        // переходя с ячейки передаем еще индекс, чтобы понимать, что это не новая таска будет создаваться, а редактируется старая
        controller.task = task
        controller.indexPath = indexPath
        controller.listID = listID
        taskController.modalPresentationStyle = .fullScreen
        present(taskController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let taskName = indexPath.section == 0 ? self.sortedTasks?.filter({$0.isCompleted == false})[indexPath.row].name : self.sortedTasks?.filter({$0.isCompleted == true})[indexPath.row].name else { return }
            showActionSheet(title: "Item".localized() + " " + "\"\(taskName)\"" + " " + "will be permanently deleted".localized(),
                            message: nil,
                            showCancel: true,
                            actions: [UIAlertAction(title: "Delete task".localized(),
                                                    style: .destructive,
                                                    handler: { [weak self] _ in
                guard let self = self,
                      let task = indexPath.section == 0 ? self.sortedTasks?.filter({$0.isCompleted == false})[indexPath.row] : self.sortedTasks?.filter({$0.isCompleted == true})[indexPath.row],
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
