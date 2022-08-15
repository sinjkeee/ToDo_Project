//
//  ListsViewController.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 10.08.2022.
//

import UIKit

class ListViewController: UIViewController {
    //MARK: - @IBOutlet
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var addTaskView: UIView!
    @IBOutlet weak var settingsView: UIView!
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTaskView.layer.cornerRadius = 6
        settingsView.layer.cornerRadius = 6
        
        navigationController?.navigationBar.tintColor = .white
        listTableView.register(UINib(nibName: "TaskCell", bundle: nil), forCellReuseIdentifier: "taskCell")
        
        listTableView.delegate = self
        listTableView.dataSource = self
        
        listTableView.separatorStyle = .none
        listTableView.showsVerticalScrollIndicator = false
    }
    
    //MARK: - @IBAction
    @IBAction func addTaskTapped(_ sender: UIButton) {
        guard let taskController = UIStoryboard(name: "Task", bundle: nil).instantiateViewController(withIdentifier: "TaskNavigationController") as? UINavigationController else { return }
        present(taskController, animated: true)
    }
}

//MARK: - UITableViewDelegate
extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let taskCell = listTableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as? TaskCell else { return UITableViewCell() }
        
        return taskCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let taskController = UIStoryboard(name: "Task", bundle: nil).instantiateViewController(withIdentifier: "TaskNavigationController") as? UINavigationController else { return }
        present(taskController, animated: true)
        
        print(indexPath.row)
    }
}
