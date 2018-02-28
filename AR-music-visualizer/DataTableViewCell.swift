//
//  DataTableViewCell.swift
//  AR-music-visualizer
//
//  Created by Lucy Zhang on 2/28/18.
//  Copyright © 2018 Lucy Zhang. All rights reserved.
//

import UIKit

class DataTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
