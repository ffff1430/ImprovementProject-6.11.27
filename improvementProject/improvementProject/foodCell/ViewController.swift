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
    
    var arrangeRestaurantInfo: [ArrangeRestaurantBaseInfo] = []
    
    let dispatch = DispatchGroup()
    
    var restaurants: RestaurantMO?
    
    let defaults = UserDefaults.standard
    
    var isFirstTimeLogin: Bool = false
    
    var isFirstTimeLoginKey: String = "isFirstTimeLoginKey"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.cellLayoutMarginsFollowReadableWidth = true
        //使用UserDefaults 去存是否第一次登入 第一次登入去API拿預設的餐廳，第二次登入從CoreData 拿資料
        isFirstTimeLogin = defaults.bool(forKey: isFirstTimeLoginKey)
        getRestaurantInfoData()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func getRestaurantInfoData() {
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let fetchRequest: NSFetchRequest<RestaurantMO> = RestaurantMO.fetchRequest()
            let context = appDelegate.persistentContainer.viewContext
            
            do {
                let fetchedObjects = try context.fetch(fetchRequest)
                //第二次進來才會跑CoreData
                if isFirstTimeLogin {
                    //原本是一次把Data存進去，但應該是這原因造成效能瓶頸，所以我改成使用URL然後到Cell在生成圖片
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
                        //用insert我新增的資料才會在最上面
                        arrangeRestaurantInfo.insert(restaurant, at: 0)
                    }
                } else {
                    //第一次的時候從API拿資料然後存資料到CoreData
                    restaurant.getRestaurantDatas { (data, response, error)  in
                        for food in data{
                            let url = URL(string: "https://raw.githubusercontent.com/cmmobile/ImprovementProjectInfo/master/info/pic/restaurants/\(food.image ?? "")")
                                let name = food.name ?? ""
                                let type = food.type ?? ""
                                let location = food.location ?? ""
                                let phone = food.phone ?? ""
                                let description = food.description ?? ""
                                let restaurant = ArrangeRestaurantBaseInfo(image: url,
                                                                           isVisited: food.isVisited,
                                                                           name: name,
                                                                           type: type,
                                                                           location: location,
                                                                           phone: phone,
                                                                           description: description)
                                self.arrangeRestaurantInfo.append(restaurant)
                        }
                        self.dispatch.notify(queue: .main) {
                            self.tableView.reloadData()
                            //如果沒反轉，第二次登入的時後存在CoreData的API資料會是反的
                            for food in self.arrangeRestaurantInfo.reversed() {
                                self.insertData(contactInfo: food)
                            }
                            //這邊會改變isFirstTimeLogin的值
                            self.isFirstTimeLogin = true
                            self.defaults.set(self.isFirstTimeLogin, forKey: self.isFirstTimeLoginKey)
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
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            
            if let managedObectContext = appDelegate?.persistentContainer.viewContext {
                
                //已把驚嘆號去掉
                if let entity = NSEntityDescription.entity(forEntityName: "RestaurantMO", in: managedObectContext) {
                    let user = NSManagedObject(entity: entity, insertInto: managedObectContext)
                    
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
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationItemButton()
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
        return arrangeRestaurantInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FoodVC", for: indexPath) as? FoodTableViewCell else { return UITableViewCell() }
        
        let restaurantInfos = arrangeRestaurantInfo[indexPath.row]
        cell.nameLabel.text = restaurantInfos.name
        cell.countryLabel.text = restaurantInfos.location
        cell.typeLabel.text = restaurantInfos.type
        if restaurantInfos.isVisited == true {
            cell.heartImage.image = UIImage(named: "like")
        }
        //生完圖片就把Task給取消掉 這要就不會一直重生圖片，就不會造成滑動困難
        if let url = restaurantInfos.image {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        cell.foodImage.image = image
                    }
                }
            }
            task.resume()
            cell.task = task
        }
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let viewcontroller = UIStoryboard(name: "Result", bundle: nil).instantiateViewController(withIdentifier: "ResultVC") as? ResultViewController else { return }
        viewcontroller.phone = arrangeRestaurantInfo[indexPath.row].phone
        viewcontroller.map = arrangeRestaurantInfo[indexPath.row].location
        viewcontroller.article = arrangeRestaurantInfo[indexPath.row].description
        viewcontroller.name = arrangeRestaurantInfo[indexPath.row].name
        viewcontroller.location = arrangeRestaurantInfo[indexPath.row].location
        viewcontroller.type = arrangeRestaurantInfo[indexPath.row].type
        viewcontroller.image = arrangeRestaurantInfo[indexPath.row].image
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deletAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (action, sourceView, complete) in
            self?.arrangeRestaurantInfo.remove(at: indexPath.row)
            
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                let fetchRequest: NSFetchRequest<RestaurantMO> = RestaurantMO.fetchRequest()
                let context = appDelegate.persistentContainer.viewContext
                do {
                    var fetchedObjects = try context.fetch(fetchRequest)
                        //因為存進CoreData的資料是反的所以要經過反轉，才會刪除正確的Cell
                        fetchedObjects.reverse()
                        context.delete(fetchedObjects[indexPath.row])
                        appDelegate.saveContext()
                } catch {
                    print(error)
                }
            }
            
            self?.tableView.deleteRows(at: [indexPath], with: .fade)
            complete(true)
        }
        let heartAction = UIContextualAction(style: .normal, title: nil) { [weak self] (action, sourceView, complete) in
            
            let cell = tableView.cellForRow(at: indexPath) as? FoodTableViewCell
            
            //一開始都是預設為False，使用三元運算子，當觸發UIContextualAction就會把觸發那段的Cell的isVisited改成另一個布林值
            self?.arrangeRestaurantInfo[indexPath.row].isVisited = self?.arrangeRestaurantInfo[indexPath.row].isVisited ?? false ? false : true
            
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                let fetchRequest: NSFetchRequest<RestaurantMO> = RestaurantMO.fetchRequest()
                let context = appDelegate.persistentContainer.viewContext
                do {
                    var fetchedObjects = try context.fetch(fetchRequest)
                    //因為存進CoreData的資料是反的所以要經過反轉，愛心才會在正確的Cell上顯示
                        fetchedObjects.reverse()
                        fetchedObjects[indexPath.row].isVisited = fetchedObjects[indexPath.row].isVisited ? false : true
                        appDelegate.saveContext()
                } catch {
                    print(error)
                }
            }
            
            if self?.arrangeRestaurantInfo[indexPath.row].isVisited == true {
                cell?.heartImage.image = UIImage(named: "like")
            } else {
                cell?.heartImage.image = nil
            }
            
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

//修改CodingStyle
extension ViewController: GetNewRestaurantData {
    func didSetNewRestaurant(newRestaurantData: ArrangeRestaurantBaseInfo) {
        arrangeRestaurantInfo.insert(newRestaurantData, at: 0)
        tableView.reloadData()
    }
}

