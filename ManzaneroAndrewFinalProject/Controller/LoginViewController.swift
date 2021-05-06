//
//  AuthViewController.swift
//  ManzaneroAndrewFinalProject
//
//  Created by Andrew Manzanero on 4/27/21.
//  amanzane@usc.edu
//

import UIKit
import Firebase

class AuthViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        errorMessageLabel.text = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        emailTextField.text = UserModel.sharedInstance.loadAndGetEmail()
        passwordTextField.text = ""
}

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func loginBtnTapped(_ sender: Any) {
        // use firebase auth to login
        errorMessageLabel.text = ""
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                guard let strongSelf = self else { return }
                if let error = error {
                    print("something happened: \(error.localizedDescription)")
                    strongSelf.errorMessageLabel.text = error.localizedDescription
                }
                if let user = authResult?.user {
                    UserModel.sharedInstance.cacheEmail(email: email)
                    UserModel.sharedInstance.loadUserInfo(user: user) {
                        print("authenticated successfully")
                        strongSelf.performSegue(withIdentifier: "authenticated", sender: nil)
                    }
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == emailTextField { // Switch focus to other text field
            passwordTextField.becomeFirstResponder()
        }
        else if textField == passwordTextField {
            dismissKeyboard()
        }
        return true
    }
    
    @IBAction func backgroundTapped(_ sender: Any) {
        dismissKeyboard()
    }
    
    func dismissKeyboard() {
        self.emailTextField.endEditing(true)
        self.passwordTextField.endEditing(true)
    }
}
