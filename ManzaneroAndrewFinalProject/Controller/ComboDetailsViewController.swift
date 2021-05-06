//
//  ComboDetailsViewController.swift
//  ManzaneroAndrewFinalProject
//
//  Created by Andrew Manzanero on 4/29/21.
//  amanzane@usc.edu
//

import UIKit
import CoreLocation
import MessageUI

class ComboDetailsViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    var combo: Combo?
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var comboLabel1: UILabel!
    @IBOutlet weak var comboLabel2: UILabel!
    @IBOutlet weak var comboLabel3: UILabel!
    @IBOutlet weak var comboLabel4: UILabel!
    @IBOutlet weak var startPercentLabel: UILabel!
    @IBOutlet weak var endPercentLabel: UILabel!
    @IBOutlet weak var isTrueLabel: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let combo = combo {
            usernameLabel.text = combo.submittedBy
            
            // get combos from list
            let comboList = [comboLabel1, comboLabel2, comboLabel3, comboLabel4]
            for (i, x) in comboList.enumerated() {
                x!.text = combo.moves.count > i ? combo.moves[i] : ""
            }
            
            startPercentLabel.text = "\(combo.startPercent)%"
            endPercentLabel.text = "\(combo.endPercent)%"
            
            isTrueLabel.text = combo.trueCombo ? "Yes" : "No"
            locationLabel.text = combo.location
            
            refreshLikesUI()
            refreshLikeButton()
        }
    }
    
    func refreshLikesUI() {
        if let combo = combo {
            likesLabel.text = String(combo.likes)
        }
    }
    
    func refreshLikeButton() {
        if let combo = combo {
            UserModel.sharedInstance.reloadLikes {
                // check if liked and update button text
                if UserModel.sharedInstance.likes.contains(combo.id) {
                    self.likeBtn.setTitle("Unlike", for: .normal)
                } else {
                    self.likeBtn.setTitle("Like", for: .normal)
                }
            }
        }
    }
    
    @IBAction func likeBtnTapped(_ sender: Any) {
        if let combo = combo {
            let completionHandler = { (newCombo: Combo) in
                self.combo = newCombo
                self.refreshLikesUI()
                ComboModel.sharedInstance.getByCharacter(characterID: combo.characterID, onSuccess: nil)
            }
            
            // check if liked
            if UserModel.sharedInstance.likes.contains(combo.id) {
                // if yes, then unlike
                UserModel.sharedInstance.removeLike(combo: combo) {
                    self.refreshLikeButton()
                } onCompleteComboUpdate: { newCombo in
                    completionHandler(newCombo)
                }

            } else {
                // otherwise create like
                UserModel.sharedInstance.insertLike(combo: combo) {
                    self.refreshLikeButton()
                } onCompleteComboUpdate: { newCombo in
                    completionHandler(newCombo)
                }
            }
        }
    }
    
    // builts an SMS message and launches compose view controller
    @IBAction func shareBtnTapped(_ sender: Any) {
        if !MFMessageComposeViewController.canSendText() {
            print("SMS services are not available")
            return
        }
        let combo = self.combo!
        
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
         
        // Configure the fields of the interface.
        composeVC.recipients = []
        var body = "Check out this awesome Super Smash Bros. Combo for \(CharacterModel.sharedInstance.getNameByID(ID: combo.characterID)!)!\n"
        for move in combo.moves {
            body += "\n\(move)"
        }
        body += "\n\n\(combo.trueCombo ? "True" : "Untrue") combo"
        body += "\n\nSubmitted by: \(combo.submittedBy) (\(combo.location))"
        composeVC.body = body
        
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                      didFinishWith result: MessageComposeResult) {
        // Check the result or perform other tasks.
        
        // Dismiss the message compose view controller.
        controller.dismiss(animated: true, completion: nil)}
}
