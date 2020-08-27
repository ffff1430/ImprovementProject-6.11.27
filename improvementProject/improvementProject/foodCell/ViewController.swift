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
    
    var restaurantInfo: [NEWrestaurant] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        restaurant.getRestaurantDatas { (data, response, error)  in
            for food in data{
                if let url = URL(string: "https://raw.githubusercontent.com/cmmobile/ImprovementProjectInfo/master/info/pic/restaurants/\(food.image ?? "")") {
                    self.restaurantInfo.append(NEWrestaurant(image: url, isVisited: food.isVisited, name: food.name ?? "", type: food.type ?? "", location: food.location ?? "", phone: food.phone ?? "", description: food.description ?? ""))
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func getImage(restaurantsImagename: URL, tablecell: UITableViewCell) -> UIImage{
        var images = UIImage()
        let cell = tablecell as? FoodTableViewCell
        
        let tempDirectory = FileManager.default.temporaryDirectory
        let imageFileUrl = tempDirectory.appendingPathComponent(restaurantsImagename.lastPathComponent)
        if FileManager.default.fileExists(atPath: imageFileUrl.path) {
            if let image = UIImage(contentsOfFile: imageFileUrl.path) {
                images = image
            }
        } else {
            cell?.task = URLSession.shared.dataTask(with: restaurantsImagename) { (data, response, error) in
                 DispatchQueue.main.async {
                    if let data = data, let image = UIImage(data: data) {
                    try? data.write(to: imageFileUrl)
                        images = image
                        self.tableView.reloadData()
                    }
                }
            }
            cell?.task?.resume()
        }
        return images
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurantInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FoodVC", for: indexPath) as? FoodTableViewCell else { return UITableViewCell() }
        
        let restaurantInfos = restaurantInfo[indexPath.row]
        cell.nameLabel.text = restaurantInfos.name
        cell.countryLabel.text = restaurantInfos.location
        cell.typeLabel.text = restaurantInfos.type
        cell.foodImage.image = getImage(restaurantsImagename: restaurantInfos.image, tablecell: cell)

        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let viewcontroller = UIStoryboard(name: "Result", bundle: nil).instantiateViewController(withIdentifier: "ResultVC") as? ResultViewController else { return }
        viewcontroller.phone = restaurantInfo[indexPath.row].phone
        viewcontroller.map = restaurantInfo[indexPath.row].location
        viewcontroller.article = restaurantInfo[indexPath.row].description
        viewcontroller.name = restaurantInfo[indexPath.row].name
        viewcontroller.location = restaurantInfo[indexPath.row].location
        viewcontroller.type = restaurantInfo[indexPath.row].type
        viewcontroller.image = getImage(restaurantsImagename: restaurantInfo[indexPath.row].image, tablecell: UITableViewCell() )
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deletAction = UIContextualAction(style: .destructive, title: "Delect") { (action, sourceView, complete) in
            self.restaurantInfo.remove(at: indexPath.row)
            
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            complete(true)
        }
        let heartAction = UIContextualAction(style: .normal, title: "heart") { (action, sourceView, complete) in
            
            let cell = tableView.cellForRow(at: indexPath) as! FoodTableViewCell
            
            self.restaurantInfo[indexPath.row].isVisited = self.restaurantInfo[indexPath.row].isVisited ? false : true
            
            cell.heartImage.isHidden = self.restaurantInfo[indexPath.row].isVisited ? false : true
            complete(true)
        }
        deletAction.backgroundColor = UIColor(red: 231.0/255, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
        deletAction.image = UIImage(systemName: "trash")
        heartAction.backgroundColor = UIColor(red: 254.0/255, green: 149.0/255.0, blue: 38.0/255.0, alpha: 1.0)
        heartAction.image = UIImage(systemName: "heart")
        
        let swipe = UISwipeActionsConfiguration(actions: [deletAction, heartAction])
        return swipe
    }
}
