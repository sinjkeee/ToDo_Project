//
//  SceneDelegate.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 09.08.2022.
//

import UIKit
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window?.windowScene = windowScene
        
        FirebaseApp.configure()

//        do {
//            try Auth.auth().signOut()
//        } catch {
//            print(error)
//        }
        
        Auth.auth().addStateDidChangeListener { auth, user in
            if user == nil {
                print("user == nil")
                self.showLoginViewController()
            } else {
                print("user != nil")
                guard let uid = user?.uid else { return }
                self.showMainViewController(with: uid)
            }
        }
    }
    
    private func showMainViewController(with uid: String) {
        guard let navigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainNavigationController") as? UINavigationController,
              let controller = navigationController.viewControllers.first as? MainViewController else { return }
        controller.userUID = uid
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
    }
    
    private func showLoginViewController() {
        guard let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else { return }
        window?.rootViewController = loginViewController
        window?.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
}

