//
//  MovesTableViewCell.swift
//  pokedex
//
//  Created by Ray Elliott on 2/12/16.
//  Copyright © 2016 Crossway. All rights reserved.
//

import UIKit

class MovesTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var powerLbl: UILabel!
    @IBOutlet weak var accuracyLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(move: Dictionary<String, AnyObject>) {
        nameLbl.text = move["name"] as? String
        powerLbl.text = move["power"] as? String
        accuracyLbl.text = move["accuracy"] as? String
    }

}
