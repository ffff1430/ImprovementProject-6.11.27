//
//  ResultTableViewCell.swift
//  improvementProject
//
//  Created by chen yue on 2020/8/25.
//  Copyright © 2020 chen yue. All rights reserved.
//

import UIKit

class ResultTableViewCell: UITableViewCell {

    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var articleLabel: UILabel!
    @IBOutlet weak var mapTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
