//
//  CharacterViewController.swift
//  ManzaneroAndrewFinalProject
//
//  Created by Andrew Manzanero on 4/26/21.
//  amanzane@usc.edu
//

import UIKit
import Firebase

class CharacterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // assign delegates
        tableview.delegate = self
        tableview.dataSource = self
        self.navigationItem.hidesBackButton = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableview.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CharacterModel.sharedInstance.count()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell")!
        cell.textLabel?.text = CharacterModel.sharedInstance.at(index: indexPath.item).name
       return cell
    }

    @IBAction func logoutTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            navigationController?.popViewController(animated: true)
        } catch {
            print(error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // passes on character name and starts loading combos
        let dest = segue.destination as! ComboViewController
        let cell = (sender as! UITableViewCell)
        let name = cell.textLabel!.text!
        dest.characterName = name

        if let characterID = CharacterModel.sharedInstance.getIDByName(name) {
            dest.characterID = characterID
        }
    }
}
