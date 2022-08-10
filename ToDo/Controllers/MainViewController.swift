//
//  ViewController.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 09.08.2022.
//

import UIKit
/*
enum MainCells: CaseIterable {
    case myDay
    case important
    case planned
    case completed
    case tasks
}
*/
class MainViewController: UIViewController {

    //MARK: - IBOutlet
    @IBOutlet weak var mainTableView: UITableView!
    
    //MARK: - let/var
    var arrayCells: [MainCell] = []
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCustomTitleView()
        
        mainTableView.delegate = self
        mainTableView.dataSource = self
        
        arrayCells = [MainCell(name: "Мой день", image: "sun.max", imageColor: .systemGray),
                      MainCell(name: "Важно", image: "star", imageColor: .systemGray),
                      MainCell(name: "Запланировано", image: "calendar", imageColor: .systemGray),
                      MainCell(name: "Завершенные", image: "checkmark.circle", imageColor: .systemRed),
                      MainCell(name: "Задачи", image: "text.badge.checkmark", imageColor: .systemGreen)]
        
        mainTableView.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: "mainCell")
    }
}


//MARK: - UITableViewDelegate, UITableViewDataSource
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewForFooter = UIView()
        viewForFooter.backgroundColor = .systemGray5
        viewForFooter.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 1)
        return viewForFooter
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return arrayCells.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = mainTableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath) as? MainTableViewCell else { return UITableViewCell() }
        
        if indexPath.section == 0 {
            cell.custonCell(with: arrayCells[indexPath.row])
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - customTitleView
extension MainViewController {

    private func createCustomTitleView(contactName: String, selector: Selector) -> UIView {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 350, height: 41)
        
        let imageContact = UIImageView()
        imageContact.image = UIImage(systemName: "person.crop.circle")
        imageContact.frame = CGRect(x: 5, y: 10, width: 25, height: 25)
        imageContact.layer.cornerRadius = imageContact.frame.size.width / 2
        imageContact.tintColor = .systemCyan
        view.addSubview(imageContact)

        let button = UIButton(type: .system)
        button.setTitle(contactName, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.tintColor = .black
        button.frame = CGRect(x: 30, y: 13, width: 200, height: 20)
        button.addTarget(self, action: selector, for: .touchUpInside)
        view.addSubview(button)
        
        return view
    }
    
    private func createCustomButton(selector: Selector) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "magnifyingglass")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .systemCyan
        button.imageView?.contentMode = .scaleAspectFit
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.addTarget(self, action: selector, for: .touchUpInside)
        
        let barButtonItem = UIBarButtonItem(customView: button)
        return barButtonItem
    }
    
    private func setupCustomTitleView() {
        let searchButton = createCustomButton(selector: #selector(findButtonTapped))
        let customTitleView = createCustomTitleView(contactName: "Владимир Секерко", selector: #selector(infoButtonTapped))
        
        navigationItem.rightBarButtonItem = searchButton
        navigationItem.titleView = customTitleView
    }
    
    @objc private func findButtonTapped() {
        print("findButtonTapped")
    }
    
    @objc private func infoButtonTapped() {
        print("infoButtonTapped")
    }
}
