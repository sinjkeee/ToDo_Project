//
//  ViewController.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 09.08.2022.
//

import UIKit
import SnapKit

class MainViewController: UIViewController {
    
    //MARK: - IBOutlet
    @IBOutlet weak var mainTableView: UITableView!
    
    //MARK: - let/var
    private var arrayLists: [List] = []
    private var arrayCustomLists: [List] = []
    
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
        
        arrayLists = [List(name: "Мой день", image: "sun.max", imageColor: .systemYellow, countTask: nil),
                      List(name: "Важно", image: "star", imageColor: .systemGray, countTask: 2),
                      List(name: "Запланировано", image: "calendar", imageColor: .systemGray, countTask: 1),
                      List(name: "Завершенные", image: "checkmark.circle", imageColor: .systemRed, countTask: nil),
                      List(name: "Задачи", image: "text.badge.checkmark", imageColor: .systemGreen, countTask: 5)]
        
        arrayCustomLists = [List(name: "Купить в магазине", image: "list.bullet", imageColor: .blue, countTask: nil),
                            List(name: "В поход", image: "list.bullet", imageColor: .red, countTask: 2)]
    }
    
    @IBAction func createNewListTapped(_ sender: UIButton) {
        showAlert()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        setConstraint()
    }
    
    @objc private func searchButtonTapped() {
        print("findButtonTapped")
    }
    
    @objc private func infoButtonTapped() {
        print("infoButtonTapped")
    }
    
    private func showAlert() {
        let alertController = UIAlertController(title: "Новый список", message: "", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default) { action in
            guard let text = alertController.textFields?.first?.text else { return }
            if text != "" {
                let newCustomCell = List(name: text, image: "list.bullet", imageColor: .blue, countTask: nil)
                self.arrayCustomLists.append(newCustomCell)
                self.mainTableView.reloadData()
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
        
        indexPath.section == 0 ? cell.customCell(with: arrayLists[indexPath.row]) : cell.customCell(with: arrayCustomLists[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let list = UIStoryboard(name: "List", bundle: nil).instantiateViewController(withIdentifier: "ListsViewController") as? ListViewController else { return }
        
        list.title = indexPath.section == 0 ? arrayLists[indexPath.row].name : arrayCustomLists[indexPath.row].name
        navigationController?.pushViewController(list, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.arrayCustomLists.remove(at: indexPath.row)
            self.mainTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        indexPath.section == 1
    }
}
