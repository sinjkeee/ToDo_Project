//
//  SearchViewController.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 21.08.2022.
//

import UIKit
import RealmSwift

class SearchViewController: UIViewController {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - let/var
    private var searchController = UISearchController()
    private var dataTask: Results<TaskModel>!
    private var filteredDataTask: [TaskModel] = []
    private var notificationToken: NotificationToken?
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGray6
        title = ""
        
        searchController.searchBar.setValue("Cancel".localized(), forKey: "cancelButtonText")
        searchController.searchBar.placeholder = "Search".localized()
        searchController.searchResultsUpdater = self
        
        navigationItem.searchController = searchController
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TaskCell", bundle: nil), forCellReuseIdentifier: "taskCell")
        
        dataTask = RealmManager.shared.realm.objects(TaskModel.self)
        // подписываемся на изменения задач в бд, если изменение есть – делаем reloadData
        notificationToken = dataTask.observe({ (changes) in
            switch changes {
            case .initial:
                break
            case .update(_, _, _, _):
                self.tableView.reloadData()
            case .error(let error):
                fatalError("\(error)")
            }
        })
    }
}

//MARK: - UITableViewDelegate
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredDataTask.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let taskCell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as? TaskCell else { return UITableViewCell() }
        
        taskCell.task = filteredDataTask[indexPath.row]
        taskCell.configure(with: filteredDataTask[indexPath.row])
        return taskCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let taskController = UIStoryboard(name: "Task", bundle: nil).instantiateViewController(withIdentifier: "TaskNavigationController") as? UINavigationController,
              let controller = taskController.viewControllers.first as? TaskViewController
        else { return }
        let task = filteredDataTask[indexPath.row]
        
        controller.task = task
        controller.indexPath = indexPath
        present(taskController, animated: true)
    }
}

//MARK: - UISearchResultsUpdating
extension SearchViewController: UISearchResultsUpdating {
    // поиск совпадений в имени задачи
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        
        filteredDataTask = []
        
        filteredDataTask = dataTask.filter({$0.name.uppercased().contains(text.uppercased())})
        
        tableView.reloadData()
    }
}
