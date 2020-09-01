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
    var image: Data?
    var phone: String = ""
    var map: String = ""
    var article: String = ""
    var mapLocation: String = "台北101"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func setupUI(){
        nameLabel.text = name
        typeLabel.text = type
        if let image = image{
            foodImage.image = UIImage(data: image)
        }
    }
}

extension ResultViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 4{
            guard let viewcontroller = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "mapVC") as? MapViewController else { return }
            viewcontroller.locationMap = mapLocation
            self.navigationController?.pushViewController(viewcontroller, animated: true)
        }
    }
}

extension ResultViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
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
            cell.mapTitleLabel.text = "How To Get Here"
            cell.selectionStyle = .none
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "map", for: indexPath) as! MapTableViewCell
            cell.configure(location: mapLocation)
            cell.selectionStyle = .none
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as! ResultTableViewCell
            cell.articleLabel.text = "Failed to instantiate the content"
            return cell
        }
    }
}
