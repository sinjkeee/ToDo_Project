//
//  ListModelForRealm.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 16.08.2022.
//

import Foundation
import RealmSwift

class UserModel: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String = ""
    @Persisted var uid: String = ""
    @Persisted var userImage = Data()
    @Persisted var email: String = ""
    @Persisted var lists = List<ListModel>()
}

class ListModel: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var index: ListIndex = .custom
    @Persisted var name: String = "Список без названия"
    @Persisted var image: String = "list.bullet"
    @Persisted var tasks = List<TaskModel>()
}

class TaskModel: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String = ""
    @Persisted var note: String = ""
    @Persisted var isCompleted: Bool = false
    @Persisted var isImportant: Bool = false
    @Persisted var dateOfCreation: Date = Date()
    @Persisted var reminderTime: Date?
    @Persisted var dateOfCompletion: Date?
    @Persisted var images = List<Data>()
}
