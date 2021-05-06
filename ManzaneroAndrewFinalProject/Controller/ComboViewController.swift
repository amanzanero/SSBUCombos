//
//  ComboViewController.swift
//  ManzaneroAndrewFinalProject
//
//  Created by Andrew Manzanero on 4/26/21.
//  amanzane@usc.edu
//

import UIKit
import WebKit

class ComboViewController: UIViewController, WKNavigationDelegate, UITableViewDataSource, UITableViewDelegate {
    var characterName: String?
    var characterID: String?
    private var iconBaseURL = "https://raw.githubusercontent.com/marcrd/smash-ultimate-assets/master/stock-icons/png/"
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var webkitView: WKWebView!
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webkitView.navigationDelegate = self
        tableview.delegate = self
        tableview.dataSource = self

        self.tableview.reloadData()
        
        // gets the table data and loads the character image
        if let characterName = characterName, let characterID = characterID {
            ComboModel.sharedInstance.getByCharacter(characterID: characterID) { _ in
                self.tableview.reloadData()
            }
            
            self.title = characterName
            if let url = URL(string: getImageURL(characterName)) {
                let request = URLRequest(url: url)
                webkitView.load(request)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addComboSegue", let characterName = characterName {
            // prepares the add view with character info
            let dest = segue.destination as! AddComboViewController
            dest.characterID = CharacterModel.sharedInstance.getIDByName(characterName)
            dest.parentVC = self
        }
        if segue.identifier == "comboDetailsSegue" {
            // gets cached info to load into details
            let index = tableview.indexPathForSelectedRow!.item
            let dest = segue.destination as! ComboDetailsViewController
            dest.combo = ComboModel.sharedInstance.getCachedComboList()[index]
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if webkitView.isLoading {
            webkitView.stopLoading()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableview.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ComboModel.sharedInstance.getCachedComboList().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // uses custom cell
        let cell = tableview.dequeueReusableCell(withIdentifier: "comboCell")! as! CustomTableViewCell
        let combo = ComboModel.sharedInstance.getCachedComboList()[indexPath.item]
        var title = combo.moves[0]
        for c in combo.moves[1...] {
            title += " - \(c)"
        }
        
        if title.count >= 30 {
            let start = title.startIndex
            let thirteenth = title.index(start, offsetBy: 27)
            title = String(title[start..<thirteenth])
            title += "..."
        }
        
        cell.textLabel?.text = title
        cell.likesLabel.text = String(combo.likes)
       return cell
    }
    
    /**
     * Functions below toggle loading view
     */
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
 }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    // Helper for forming url based of character name
    func getImageURL(_ name: String) -> String {
        let slug = name.lowercased().replacingOccurrences(of: " ", with: "_")
        return "\(iconBaseURL)\(slug).png"
    }
}
