//
//  ViewController.swift
//  ManzaneroAndrewFinalProject
//
//  Created by Andrew Manzanero on 4/21/21.
//  amanzane@usc.edu
//

import UIKit

class ViewController: UIViewController {
    var characterModel: CharacterModel!
    var comboModel: ComboModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        characterModel = CharacterModel.sharedInstance
        comboModel = ComboModel.sharedInstance
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

