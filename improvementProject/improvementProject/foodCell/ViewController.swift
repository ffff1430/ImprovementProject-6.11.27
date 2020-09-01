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
    
    var restaurantInfo: [Arrangerestaurant] = []
    
    let newRestaurantKey = "SavedNewRestaurantArray"
    
    var newRestaurantData: [Arrangerestaurant] = []
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setuptableViewUI()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 105
    }
    
    
    func setuptableViewUI() {
        if let savedPerson = defaults.object(forKey: newRestaurantKey) as? Data {
            let decoder = JSONDecoder()
            if let loadedPerson = try? decoder.decode([Arrangerestaurant].self, from: savedPerson) {
                for data in loadedPerson{
                    let name = data.name
                    let type = data.type
                    let location = data.location
                    let phone = data.phone
                    let isVisited = data.isVisited
                    let image = data.image
                    let description = data.description
                    let restaurant = Arrangerestaurant(image: image,
                                                       isVisited: isVisited,
                                                       name: name,
                                                       type: type,
                                                       location: location,
                                                       phone: phone,
                                                       description: description)
                    restaurantInfo.append(restaurant)
                    newRestaurantData.append(restaurant)
                }
            }
        }
        restaurant.getRestaurantDatas { (data, response, error)  in
            for food in data{
                if let url = URL(string: "https://raw.githubusercontent.com/cmmobile/ImprovementProjectInfo/master/info/pic/restaurants/\(food.image ?? "")") {
                    let data = try? Data(contentsOf: url)
                    let name = food.name ?? ""
                    let type = food.type ?? ""
                    let location = food.location ?? ""
                    let phone = food.phone ?? ""
                    let description = food.description ?? ""
                    let restaurant = Arrangerestaurant(image: data,
                                                       isVisited: food.isVisited,
                                                       name: name,
                                                       type: type,
                                                       location: location,
                                                       phone: phone,
                                                       description: description)
                    self.restaurantInfo.append(restaurant)
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationItemButton()
    }
    
    
    func setNavigationItemButton() {
        let plusButton = UIBarButtonItem(image: UIImage(named: "plus"), style: .plain, target: self, action: #selector(plusTap))
        plusButton.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = plusButton
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.hidesBarsOnSwipe = true
    }
    
    @objc func plusTap(sender: AnyObject){
        guard let viewcontroller = UIStoryboard(name: "AddRestaurant", bundle: nil).instantiateViewController(withIdentifier: "AddRestaurant") as? AddRestaurantViewController else { return }
        viewcontroller.delegate = self
        present(viewcontroller, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
        
        cell.heartImage.isHidden = true
        
        cell.heartImage.isHidden = restaurantInfo[indexPath.row].isVisited ? false : true
        
        let restaurantInfos = restaurantInfo[indexPath.row]
        cell.nameLabel.text = restaurantInfos.name
        cell.countryLabel.text = restaurantInfos.location
        cell.typeLabel.text = restaurantInfos.type
        DispatchQueue.main.async {
            if let image = restaurantInfos.image{
                cell.foodImage.image = UIImage(data: image)
            }
        }
        
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
        viewcontroller.image = restaurantInfo[indexPath.row].image
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deletAction = UIContextualAction(style: .destructive, title: "Delect") { [weak self] (action, sourceView, complete) in
            self?.restaurantInfo.remove(at: indexPath.row)
            
            if indexPath.row < self?.newRestaurantData.count ?? 0{
                self?.newRestaurantData.remove(at: indexPath.row)
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(self?.newRestaurantData){
                    self?.defaults.set(encoded, forKey: self?.newRestaurantKey ?? "")
                }
            }
            
            self?.tableView.deleteRows(at: [indexPath], with: .fade)
            complete(true)
        }
        let heartAction = UIContextualAction(style: .normal, title: "heart") { [weak self] (action, sourceView, complete) in
            
            let cell = tableView.cellForRow(at: indexPath) as? FoodTableViewCell
            
            self?.restaurantInfo[indexPath.row].isVisited = self?.restaurantInfo[indexPath.row].isVisited ?? false ? false : true
            
            if indexPath.row < self?.newRestaurantData.count ?? 0{
                self?.newRestaurantData[indexPath.row].isVisited = self?.newRestaurantData[indexPath.row].isVisited ?? false ? false : true
                let encoder = JSONEncoder()
                if let encoded = try? encoder.encode(self?.newRestaurantData){
                    self?.defaults.set(encoded, forKey: self?.newRestaurantKey ?? "")
                }
            }
            
            cell?.heartImage.isHidden = self?.restaurantInfo[indexPath.row].isVisited ?? false ? false : true
            
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

extension ViewController: GetNewRestaurantData{
    func didSetNewRestaurant(Arrangerestaurant: Arrangerestaurant) {
        newRestaurantData.insert(Arrangerestaurant, at: 0)
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(newRestaurantData){
            defaults.set(encoded, forKey: newRestaurantKey)
        }
        
        restaurantInfo.insert(Arrangerestaurant, at: 0)
        tableView.reloadData()
    }
}

