//
//  SignUpViewController.swift
//  ManzaneroAndrewFinalProject
//
//  Created by Andrew Manzanero on 4/29/21.
//  amanzane@usc.edu
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorMessageLabel.text = ""
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        
        // use firebase auth to sign up
        errorMessageLabel.text = ""
        if let email = emailTF.text, let password = passwordTF.text, let username = usernameTF.text {
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
                guard let strongSelf = self else { return }
                if let error = error {
                    print("something happened: \(error.localizedDescription)")
                    strongSelf.errorMessageLabel.text = error.localizedDescription
                }
                
                // displayName is the username that user enters
                if let user = authResult?.user {
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = username
                    changeRequest.commitChanges { (error) in
                        UserModel.sharedInstance.cacheEmail(email: email)
                        UserModel.sharedInstance.loadUserInfo(user: user) {
                            strongSelf.emailTF.text = ""
                            strongSelf.passwordTF.text = ""
                            strongSelf.performSegue(withIdentifier: "signedUpSegue", sender: nil)
                        }
                    }
                }
            }
        }
    }
    
    
    @IBAction func backgroundTapped(_ sender: Any) {
        dismissKeyboard()
    }
    
    func dismissKeyboard() {
        self.emailTF.endEditing(true)
        self.passwordTF.endEditing(true)
    }
}
