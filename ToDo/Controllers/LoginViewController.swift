//
//  LoginViewController.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 12.08.2022.
//

import UIKit
import Firebase
import RealmSwift

class LoginViewController: UIViewController {
    
    // login view
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var loginTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var toRegisterView: UIButton!
    @IBOutlet weak var dontHaveAnAccountLabel: UILabel!
    @IBOutlet weak var bottomConstraintStackView: NSLayoutConstraint!
    // register view
    @IBOutlet weak var registerView: UIView!
    @IBOutlet weak var haveAnAccountLabel: UILabel!
    @IBOutlet weak var toLoginView: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginRegisterTF: UITextField!
    @IBOutlet weak var nameRegisterTF: UITextField!
    @IBOutlet weak var passwordRegisterTF: UITextField!
    @IBOutlet weak var secondPasswordRegisterTF: UITextField!
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
        view.addGestureRecognizer(recognizer)
        
        loginButton.cornerRadius()
        registerButton.cornerRadius()
        
        loginTF.delegate = self
        passwordTF.delegate = self
        
        loginTF.placeholder = "Введите почту"
        passwordTF.placeholder = "Введите пароль"
        
        addVerticalGradientLayer(topColor: .systemBlue, bottomColor: .systemYellow)
    }
    
    //MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObservers() // подписываемся, когда контроллер виден
    }
    
    //MARK: - viewDidDisapear
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeKeyboardObservers() // отписываемся, когда контроллер пропал
    }
    
    //MARK: - Custom methods
    @objc private func tap() {
        view.endEditing(true)
    }
    
    private func addVerticalGradientLayer(topColor: UIColor, bottomColor: UIColor) {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [topColor.cgColor, bottomColor.cgColor]
        gradient.opacity = 0.4
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
    }
    
    private func firstLaunchApp(user: UserModel) {
        let list1 = ListModel()
        list1.index = .one
        let list2 = ListModel()
        list2.index = .two
        let list3 = ListModel()
        list3.index = .three
        let list4 = ListModel()
        list4.index = .four
        let list5 = ListModel()
        list5.index = .five
        RealmManager.shared.save(list: list1, in: user)
        RealmManager.shared.save(list: list2, in: user)
        RealmManager.shared.save(list: list3, in: user)
        RealmManager.shared.save(list: list4, in: user)
        RealmManager.shared.save(list: list5, in: user)
    }
    
    //MARK: - @IBAction
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let email = loginTF.text,
              let password = passwordTF.text
        else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if error == nil, let result = result, let mainController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainNavigationController") as? UINavigationController, let vc = mainController.viewControllers.first as? MainViewController {
                mainController.modalPresentationStyle = .fullScreen
                // при успешной авторизации мы передаем uid пользователя в контроллер, чтобы понимать, какой пользователь авторизовался
                vc.userUID = result.user.uid
                self.present(mainController, animated: true)
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    // регистрация нового пользователя в firebase
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        
        guard let name = nameRegisterTF.text,
              let email = loginRegisterTF.text,
              let password = passwordRegisterTF.text
        else { return }
        // регистрируем пользователя в firebase
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let result = result {
                // сохраняем пользователя в realtime database
                let ref = Database.database().reference().child("users")
                ref.child(result.user.uid).updateChildValues(["name": name, "email": email])
                // создаем объект пользователя в реалм
                let newUser = UserModel()
                newUser.name = name
                newUser.uid = result.user.uid
                RealmManager.shared.save(user: newUser)
                self.firstLaunchApp(user: newUser)
                self.showAlert(title: "Успешно!", message: nil, showCancel: false, actions: [UIAlertAction(title: "OK", style: .default, handler: { action in
                    UIView.animate(withDuration: 0.25) {
                        self.registerView.alpha = 0
                    } completion: { _ in
                        self.registerView.isHidden = true
                        self.loginView.alpha = 0
                        UIView.animate(withDuration: 0.25, delay: 0) {
                            self.loginView.isHidden = false
                            self.loginView.alpha = 1
                        }
                    }
                })])
                
                self.loginRegisterTF.text = ""
                self.passwordRegisterTF.text = ""
                self.secondPasswordRegisterTF.text = ""
                self.nameRegisterTF.text = ""
                self.view.endEditing(true)
            }
        }
    }
    
    @IBAction func toRegisterViewTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.25) {
            self.loginView.alpha = 0
        } completion: { _ in
            self.loginView.isHidden = true
            self.registerView.alpha = 0
            UIView.animate(withDuration: 0.25, delay: 0) {
                self.registerView.isHidden = false
                self.registerView.alpha = 1
            }
        }
    }
    
    @IBAction func toLoginViewTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.25) {
            self.registerView.alpha = 0
        } completion: { _ in
            self.registerView.isHidden = true
            self.loginView.alpha = 0
            UIView.animate(withDuration: 0.25, delay: 0) {
                self.loginView.isHidden = false
                self.loginView.alpha = 1
            }
        }
    }
}

//MARK: - Keyboard
extension LoginViewController {
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIApplication.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIApplication.keyboardWillHideNotification, object: nil)
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        /*
        guard let userInfo = notification.userInfo,
              let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        
        self.bottomConstraintStackView.constant = keyboardFrame.height + 10
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
         */
    }
    
    @objc private func keyboardWillHide(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        
        //self.bottomConstraintStackView.constant = 240
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
}

//MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case loginTF:
            passwordTF.becomeFirstResponder()
        case passwordTF:
            self.view.endEditing(true)
        default: break
        }
        
        return false
    }
}
