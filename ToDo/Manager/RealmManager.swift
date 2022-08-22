//
//  RealmManager.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 16.08.2022.
//

import Foundation
import RealmSwift

class RealmManager {
    private let realmSchemaVersion: UInt64 = 5
    
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
    // сохранение нового пользователя
    func save(user: UserModel) {
        write {
            realm.add(user)
        }
    }
    
    // сохранение нового списка задач
    func save(list: ListModel) {
        write {
            realm.add(list)
        }
    }
    
    // сохранине новой задачи в список задач
    func save(task: TaskModel, in list: ListModel) {
        write {
            list.tasks.append(task)
        }
    }

    // удаление списка задач из бд
    func delete(list: ListModel) {
        write {
            realm.delete(list.tasks)
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
            task.isCompleted = updatingTask.isCompleted
            task.isImportant = updatingTask.isImportant
            task.reminderTime = updatingTask.reminderTime
        }
    }
    
    // редактирование списка
    func updateList(list: ListModel, newValue: String) {
        write {
            list.name = newValue
        }
    }
}
