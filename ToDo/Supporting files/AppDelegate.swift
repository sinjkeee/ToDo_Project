//
//  AppDelegate.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 09.08.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // проверка на первый запуск приложения. пока так, потом поправлю, когда прикручу регистрацию юзера
//        if UserDefaults.standard.value(forKey: "isFirst") == nil {
//            let list1 = ListModel()
//            list1.index = .one
//            let list2 = ListModel()
//            list2.index = .two
//            let list3 = ListModel()
//            list3.index = .three
//            let list4 = ListModel()
//            list4.index = .four
//            let list5 = ListModel()
//            list5.index = .five
//            RealmManager.shared.save(list: list1)
//            RealmManager.shared.save(list: list2)
//            RealmManager.shared.save(list: list3)
//            RealmManager.shared.save(list: list4)
//            RealmManager.shared.save(list: list5)
//            UserDefaults.standard.set(true, forKey: "isFirst")
//        }
//
        RealmManager.shared.printURL()

        return true
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

