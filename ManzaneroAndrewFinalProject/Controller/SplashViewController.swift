//
//  SplashViewController.swift
//  ManzaneroAndrewFinalProject
//
//  Created by Andrew Manzanero on 4/27/21.
//  amanzane@usc.edu
//

import UIKit
import Firebase

class SplashViewController: UIViewController {
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        // creates an auth listener to see if user is logged in
        print("loading auth state")
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                print("auth'd for \(user.uid)")
                
                // transition to home screen if auth'd
                UserModel.sharedInstance.loadUserInfo(user: user) {
                    self.performSegue(withIdentifier: "splashToHome", sender: nil)
                }
            } else {
                // transition to auth flow
                print("not auth'd")
                self.performSegue(withIdentifier: "splashToAuth", sender: nil)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
}
