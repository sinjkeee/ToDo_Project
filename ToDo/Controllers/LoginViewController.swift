//
//  LoginViewController.swift
//  ToDo
//
//  Created by Vladimir Sekerko on 12.08.2022.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var bottomConstraintStackView: NSLayoutConstraint!
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
        view.addGestureRecognizer(recognizer)
        
        loginButton.cornerRadius()
        registerButton.cornerRadius()
        
        loginTF.delegate = self
        passwordTF.delegate = self
        
        loginTF.placeholder = "Введите логин"
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
    
    
    //MARK: - @IBAction
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        
        // проверка, что логин и пароль введены правильно и пропускаем
        
        guard let mainController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainNavigationController") as? UINavigationController else { return }
        mainController.modalPresentationStyle = .fullScreen
        present(mainController, animated: true)
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        // проверка, что такого пользователя по имене еще нет и регистрируем нового пользователя
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
        guard let userInfo = notification.userInfo,
              let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        
        self.bottomConstraintStackView.constant = keyboardFrame.height + 10
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        
        self.bottomConstraintStackView.constant = 240
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
