//
//  ResultViewController.swift
//  improvementProject
//
//  Created by chen yue on 2020/8/24.
//  Copyright © 2020 chen yue. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel! {
        didSet {
            typeLabel.layer.cornerRadius = 5
            typeLabel.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var foodImage: UIImageView!
    
    
    var name: String = ""
    var location: String = ""
    var type: String = ""
    var image: UIImage?
    var phone: String = ""
    var map: String = ""
    var article: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        setupUI()
    }
    
    func setupUI(){
        nameLabel.text = name
        typeLabel.text = type
        foodImage.image = image
    }
}

extension ResultViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "phoneCell", for: indexPath) as! ResultTableViewCell
            cell.phoneLabel.text = phone
            cell.selectionStyle = .none
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "mapCell", for: indexPath) as! ResultTableViewCell
            cell.locationLabel.text = map
            cell.selectionStyle = .none
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as! ResultTableViewCell
            cell.articleLabel.text = article
            cell.selectionStyle = .none
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "mapTitle", for: indexPath) as! ResultTableViewCell
            cell.mapTitleLabel.text = "Subsection title"
            cell.selectionStyle = .none
            return cell
        default:
            fatalError("error")
        }
    }
}
