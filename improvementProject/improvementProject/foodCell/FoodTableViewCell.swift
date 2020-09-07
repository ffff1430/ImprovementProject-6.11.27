//
//  FoodTableViewCell.swift
//  improvementProject
//
//  Created by chen yue on 2020/8/24.
//  Copyright © 2020 chen yue. All rights reserved.
//

import UIKit

class FoodTableViewCell: UITableViewCell {
    
    @IBOutlet weak var foodImage: UIImageView! {
        didSet{
            foodImage.layer.cornerRadius = foodImage.bounds.width / 2
            foodImage.clipsToBounds = true
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var heartImage: UIImageView!
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        foodImage.image = nil
        heartImage.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        heartImage.image = nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
