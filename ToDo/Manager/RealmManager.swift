//
//  RealmManager.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 16.08.2022.
//

import Foundation
import RealmSwift

class RealmManager {
    private let realmSchemaVersion: UInt64 = 18
    
    static var shared = RealmManager()
    
    private init() {}
    
    lazy var realm: Realm = {
        let config = Realm.Configuration(schemaVersion: realmSchemaVersion)
        Realm.Configuration.defaultConfiguration = config
        
        return try! Realm()
    }()
    
    func printURL() {
        print(Realm.Configuration.defaultConfiguration.fileURL!)
    }
    
    private func write(_ completion: () -> Void) {
        do {
            try realm.write {
                completion()
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    // меняем тип сортировки списка
    func updateListSortingType(with list: ListModel, type: Sorting) {
        write {
            list.listSortType?.sortType = type
        }
    }
    
    // меняем порядок сортировки списка
    func updateListSortingAscident(with list: ListModel) {
        write {
            list.listSortType.isAscident.toggle()
        }
    }
    
    // меняем видимость листа
    func updateHiddenListProterty(list: ListModel) {
        write {
            list.isHidden.toggle()
        }
    }
    
    // сохранение нового пользователя
    func save(user: UserModel) {
        write {
            realm.add(user)
        }
    }
    
    func deleteUserPhoto(user: UserModel) {
        write {
            user.userImage = Data()
        }
    }
    
    func updateUserPhoto(user: UserModel, image data: Data) {
        write {
            user.userImage = data
        }
    }
    
    // сохранение нового списка задач
    func save(list: ListModel) {
        write {
            realm.add(list)
        }
    }
    
    func save(list: ListModel, in user: UserModel) {
        write {
            user.lists.append(list)
        }
    }
    
    // сохранине новой задачи в список задач
    func save(task: TaskModel, in list: ListModel) {
        write {
            list.tasks.append(task)
        }
    }
    
    func deleteAllTasks(list: ListModel) {
        write {
            list.tasks.removeAll()
        }
    }

    // удаление списка задач из бд
    func delete(list: ListModel) {
        write {
            realm.delete(list.tasks)
            realm.delete(list.listSortType)
            realm.delete(list)
        }
    }
    
    // удаление задачи из списка
    func delete(task: TaskModel, index: Int, from list: ListModel) {
        write {
            list.tasks.remove(at: index)
            realm.delete(task)
        }
    }
    
    // редактирование задачи
    func updateTask(task: TaskModel, updatingTask: TaskModel) {
        write {
            task.name = updatingTask.name
            task.note = updatingTask.note
            task.dateOfCompletion = updatingTask.dateOfCompletion
            task.reminderTime = updatingTask.reminderTime
            task.images = updatingTask.images
        }
    }
    
    // меняем состояние задачи важное/обычное
    func updateImportantState(task: TaskModel) {
        write {
            task.isImportant.toggle()
        }
    }
    
    // меняем статус задачи выполнен/нет
    func updateCompletedState(task: TaskModel) {
        write {
            task.isCompleted.toggle()
        }
    }
    
    // редактирование списка
    func updateList(list: ListModel, newValue: String) {
        write {
            list.name = newValue
        }
    }
    
    // сохранение цвета листа
    func updateColor(list: ListModel, newColor: ListOfColors) {
        write {
            list.color = newColor
        }
    }
}
