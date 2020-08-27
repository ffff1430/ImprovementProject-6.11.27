//
//  ViewController.swift
//  improvementProject
//
//  Created by chen yue on 2020/8/21.
//  Copyright © 2020 chen yue. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let restaurant = RestaurantModules()
    
    var restaurantInfo: [Restaurant] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restaurant.getRestaurantDatas { (data, response, error)  in
            self.restaurantInfo = data
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func getImage(index: Int) -> UIImage{
        var images = UIImage()
        let url = "https://raw.githubusercontent.com/cmmobile/ImprovementProjectInfo/master/info/pic/restaurants/\( restaurantInfo[index].image ?? "")"
        if let url = URL(string: url) {
            print("url: \(url)")
            let tempDirectory = FileManager.default.temporaryDirectory
            let imageFileUrl = tempDirectory.appendingPathComponent(url.lastPathComponent)
            if FileManager.default.fileExists(atPath: imageFileUrl.path) {
                if let image = UIImage(contentsOfFile: imageFileUrl.path) {
                    images = image
                }
            } else {
                let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                    if let data = data, let image = UIImage(data: data) {
                        try? data.write(to: imageFileUrl)
                        images = image
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                task.resume()
            }
        }
        return images
    }
}


extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurantInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodVC", for: indexPath) as! FoodTableViewCell
        
        cell.heartImage.isHidden = true
        
        cell.nameLabel.text = restaurantInfo[indexPath.row].name
        cell.countryLabel.text = restaurantInfo[indexPath.row].location
        cell.typeLabel.text = restaurantInfo[indexPath.row].type
        cell.heartImage.isHidden = restaurantInfo[indexPath.row].isVisited ? false : true

        cell.foodImage.image = getImage(index: indexPath.row)
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let viewcontroller = UIStoryboard(name: "Result", bundle: nil).instantiateViewController(withIdentifier: "ResultVC") as? ResultViewController else { return }
        viewcontroller.phone = restaurantInfo[indexPath.row].phone ?? ""
        viewcontroller.map = restaurantInfo[indexPath.row].location ?? ""
        viewcontroller.article = restaurantInfo[indexPath.row].description ?? ""
        viewcontroller.name = restaurantInfo[indexPath.row].name ?? ""
        viewcontroller.location = restaurantInfo[indexPath.row].location ?? ""
        viewcontroller.type = restaurantInfo[indexPath.row].type ?? ""
        viewcontroller.image = getImage(index: indexPath.row)
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deletAction = UIContextualAction(style: .destructive, title: "Delect") { [weak self] (action, sourceView, complete) in
            self?.restaurantInfo.remove(at: indexPath.row)
            
            self?.tableView.deleteRows(at: [indexPath], with: .fade)
            complete(true)
        }
        let heartAction = UIContextualAction(style: .normal, title: "heart") { (action, sourceView, complete) in
            
            let cell = tableView.cellForRow(at: indexPath) as? FoodTableViewCell
            
            self.restaurantInfo[indexPath.row].isVisited = self.restaurantInfo[indexPath.row].isVisited ? false : true
            
            cell?.heartImage.isHidden = self.restaurantInfo[indexPath.row].isVisited ? false : true
            complete(true)
        }
        deletAction.backgroundColor = UIColor.deletActionColor
        deletAction.image = UIImage(systemName: "trash")
        heartAction.backgroundColor = UIColor.heartActionColor
        heartAction.image = UIImage(systemName: "heart")
        
        let swipe = UISwipeActionsConfiguration(actions: [deletAction, heartAction])
        return swipe
    }
}
