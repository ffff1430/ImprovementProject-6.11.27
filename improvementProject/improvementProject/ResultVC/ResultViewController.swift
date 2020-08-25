//
//  ResultViewController.swift
//  improvementProject
//
//  Created by chen yue on 2020/8/24.
//  Copyright © 2020 chen yue. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var foodImage: UIImageView!
    
    var name: String = ""
    var location: String = ""
    var type: String = ""
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI(){
        nameLabel.text = name
        typeLabel.text = type
        locationLabel.text = location
        foodImage.image = image
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
