//
//  CustomTableViewCell.swift
//  ManzaneroAndrewFinalProject
//
//  Created by Andrew Manzanero on 4/30/21.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    @IBOutlet weak var likesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
