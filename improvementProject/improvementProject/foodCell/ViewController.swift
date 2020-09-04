//
//  ViewController.swift
//  improvementProject
//
//  Created by chen yue on 2020/8/21.
//  Copyright © 2020 chen yue. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let restaurant = RestaurantManager()
    
    var restaurantInfo: [ArrangeRestaurantBaseInfo] = []
    
    let dispatch = DispatchGroup()
    
    var restaurants: RestaurantMO?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.cellLayoutMarginsFollowReadableWidth = true
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func setuptableViewUI() {
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let fetchRequest: NSFetchRequest<RestaurantMO> = RestaurantMO.fetchRequest()
            let context = appDelegate.persistentContainer.viewContext
            
            do {
                let fetchedObjects = try context.fetch(fetchRequest)
                //沒資料時從API拿資料
                if fetchedObjects.count != 0 {
                    for food in fetchedObjects{
                        let data = food.image
                        let name = food.name ?? ""
                        let type = food.type ?? ""
                        let location = food.location ?? ""
                        let phone = food.phone ?? ""
                        let description = food.summary ?? ""
                        let restaurant = ArrangeRestaurantBaseInfo(image: data,
                                                                   isVisited: food.isVisited,
                                                                   name: name,
                                                                   type: type,
                                                                   location: location,
                                                                   phone: phone,
                                                                   description: description)
                        restaurantInfo.insert(restaurant, at: 0)
                    }
                } else {
                    //第一次的時候從API拿資料然後存資料到CoreData
                    restaurant.getRestaurantDatas { (data, response, error)  in
                        for (index,food) in data.enumerated(){
                            let url = "https://raw.githubusercontent.com/cmmobile/ImprovementProjectInfo/master/info/pic/restaurants/\(food.image ?? "")"
                            self.dispatch.enter()
                            self.fetchImage(from: url) { (datas) in
                                let name = food.name ?? ""
                                let type = food.type ?? ""
                                let location = food.location ?? ""
                                let phone = food.phone ?? ""
                                let description = food.description ?? ""
                                let restaurant = ArrangeRestaurantBaseInfo(image: datas,
                                                                           isVisited: food.isVisited,
                                                                           name: name,
                                                                           type: type,
                                                                           location: location,
                                                                           phone: phone,
                                                                           description: description)
                                self.restaurantInfo.append(restaurant)
                                self.dispatch.leave()
                            }
                        }
                        self.dispatch.notify(queue: .main) {
                            self.tableView.reloadData()
                            for food in self.restaurantInfo.reversed() {
                                self.insertData(contactInfo: food)
                            }
                        }
                    }
                }
            } catch {
                print(error)
            }
        }
    }
    
    //存資料到CoreData
    func insertData(contactInfo: ArrangeRestaurantBaseInfo) {
        
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let managedObectContext = appDelegate.persistentContainer.viewContext
            
            let entity = NSEntityDescription.entity(forEntityName: "RestaurantMO", in: managedObectContext)
            let user = NSManagedObject(entity: entity!, insertInto: managedObectContext)
            
            user.setValue(contactInfo.image, forKey: "image")
            user.setValue(contactInfo.isVisited, forKey: "isVisited")
            user.setValue(contactInfo.location, forKey: "location")
            user.setValue(contactInfo.name, forKey: "name")
            user.setValue(contactInfo.phone, forKey: "phone")
            user.setValue(contactInfo.description, forKey: "summary")
            user.setValue(contactInfo.type, forKey: "type")
            
            do {
                try managedObectContext.save()
            } catch  {
                print("error")
            }
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationItemButton()
        setuptableViewUI()
    }
    
    func fetchImage(from urlString: String, completionHandler: @escaping (_ data: Data?) -> ()) {
        guard let url = URL(string: urlString) else { return }
        DispatchQueue.global().sync {
            if let data = try? Data(contentsOf: url) {
                completionHandler(data)
            }
        }
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
        let deletAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (action, sourceView, complete) in
            self?.restaurantInfo.remove(at: indexPath.row)
            
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                let fetchRequest: NSFetchRequest<RestaurantMO> = RestaurantMO.fetchRequest()
                let context = appDelegate.persistentContainer.viewContext
                do {
                    var fetchedObjects = try context.fetch(fetchRequest)
                    if fetchedObjects.count > indexPath.row{
                        fetchedObjects.reverse()
                        context.delete(fetchedObjects[indexPath.row])
                        appDelegate.saveContext()
                    }
                } catch {
                    print(error)
                }
            }
            
            self?.tableView.deleteRows(at: [indexPath], with: .fade)
            complete(true)
        }
        let heartAction = UIContextualAction(style: .normal, title: nil) { [weak self] (action, sourceView, complete) in
            
            let cell = tableView.cellForRow(at: indexPath) as? FoodTableViewCell
            
            self?.restaurantInfo[indexPath.row].isVisited = self?.restaurantInfo[indexPath.row].isVisited ?? false ? false : true
            
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                let fetchRequest: NSFetchRequest<RestaurantMO> = RestaurantMO.fetchRequest()
                let context = appDelegate.persistentContainer.viewContext
                do {
                    var fetchedObjects = try context.fetch(fetchRequest)
                    if fetchedObjects.count > indexPath.row{
                        fetchedObjects.reverse()
                        fetchedObjects[indexPath.row].isVisited = fetchedObjects[indexPath.row].isVisited ? false : true
                        appDelegate.saveContext()
                    }
                } catch {
                    print(error)
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
    func didSetNewRestaurant(newRestaurantData: ArrangeRestaurantBaseInfo) {
        restaurantInfo.insert(newRestaurantData, at: 0)
        tableView.reloadData()
    }
}

