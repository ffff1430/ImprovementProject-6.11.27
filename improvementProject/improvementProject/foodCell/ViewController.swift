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
    
    var restaurantInfo: [RestaurantMO] = []
    
    let dispatch = DispatchGroup()
    
    var restaurants: RestaurantMO?
    
    var isFirstTimeLogin: Bool = true
    
    var isFirstTimeLoginKey: String = "isFirstTimeLoginKey"
    
    var fetchResultController: NSFetchedResultsController<RestaurantMO>?
    
    var cancelTask: URLSessionDataTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.cellLayoutMarginsFollowReadableWidth = true
        //使用UserDefaults 去存是否第一次登入 第一次登入去API拿預設的餐廳，第二次登入從CoreData 拿資料
        isFirstTimeLogin = isKeyPresentInUserDefaults(key: isFirstTimeLoginKey)
        getRestaurantInfoData()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    //因為第一次如果UserDefaults裡面沒值會回傳false所以用這func去判斷UserDefaults是否為空的
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) == nil
    }
    
    
    func getRestaurantInfoData() {
        if isFirstTimeLogin {
            dispatch.enter()
            restaurant.getRestaurantDatas { [weak self] (data, response, error)  in
                //因為我是用時間來判斷排序，因為是用時間長道短做排序，所以倒轉data才能讓最一個先得到時間
                for food in data.reversed(){
                    let url = "https://raw.githubusercontent.com/cmmobile/ImprovementProjectInfo/master/info/pic/restaurants/\(food.image ?? "")"
                    let name = food.name ?? ""
                    let type = food.type ?? ""
                    let location = food.location ?? ""
                    let phone = food.phone ?? ""
                    let date = NSDate() as Date
                    let description = food.description ?? ""
                    //新增的欄位拿來判斷是api的圖片，還是coredata的圖片
                    let currentImage = "apiImage"
                    let restaurant = ArrangeRestaurantBaseInfo(image: url,
                                                               isVisited: food.isVisited,
                                                               name: name,
                                                               type: type,
                                                               location: location,
                                                               phone: phone,
                                                               description: description,
                                                               updateAt: date,
                                                               currentImage: currentImage)
                    self?.insertData(contactInfo: restaurant)
                }
                self?.dispatch.leave()
            }
            self.dispatch.notify(queue: .main) {
                self.getCoreDatas { (data, appDelegate, context) in
                    self.restaurantInfo = data
                    self.tableView.reloadData()
                }
                //這邊會改變isFirstTimeLogin的值
                UserDefaults.standard.set(false, forKey: self.isFirstTimeLoginKey)
            }
        } else {
            getCoreDatas { (data, appDelegate, context) in
                self.restaurantInfo = data
                self.tableView.reloadData()
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
                    user.setValue(contactInfo.updateAt, forKey: "updateAt")
                    user.setValue(contactInfo.currentImage, forKey: "currentImage")
                    
                    do {
                        try managedObectContext.save()
                    } catch  {
                        print("error")
                    }
                }
            }
        }
    }
    
    //得到CoreData的資料
    func getCoreDatas(callback: @escaping ([RestaurantMO], AppDelegate, NSManagedObjectContext)->Void) {
        let fetchRequest: NSFetchRequest<RestaurantMO> = RestaurantMO.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "updateAt", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController?.delegate = self
            
            do {
                try fetchResultController?.performFetch()
                if let fetchedObjects = fetchResultController?.fetchedObjects {
                    callback(fetchedObjects, appDelegate, context)
                }
            } catch {
                print(error)
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

    //生成coreData的圖片
    private func load(fileName: String) -> UIImage? {
        if let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName) {
            do {
                let imageData = try Data(contentsOf: fileURL)
                return UIImage(data: imageData)
            } catch {
                print("Error loading image : \(error)")
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FoodVC", for: indexPath) as? FoodTableViewCell else { return UITableViewCell() }
        
        let restaurantInfos = restaurantInfo[indexPath.row]
        cell.path = URL(string: restaurantInfos.image ?? "")
        cell.nameLabel.text = restaurantInfos.name
        cell.countryLabel.text = restaurantInfos.location
        cell.typeLabel.text = restaurantInfos.type
        if restaurantInfos.isVisited == true {
            cell.heartImage.image = UIImage(named: "like")
        }
        
        //這邊做一個判斷如果是coreData的資料就跑load這個方法，如果是api的圖片就跑task
        if let image = restaurantInfos.image, restaurantInfos.currentImage == "coreData"{
            cell.foodImage.image = load(fileName: image)
        } else {
            if let image = restaurantInfos.image, let url = URL(string: image) {
                let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                    
                    //在Cell加一個path每當準備執行task前先把上一次執行的路徑存起來，然後下面判斷路徑一樣在做task，解決閃動問題
                    guard cell.path == url else { return }
                    
                    if let data = data, let image = UIImage(data: data){
                        DispatchQueue.main.async {
                            cell.foodImage.image = image
                        }
                    }
                }
                task.resume()
            }
        }
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let viewcontroller = UIStoryboard(name: "Result", bundle: nil).instantiateViewController(withIdentifier: "ResultVC") as? ResultViewController else { return }
        viewcontroller.restaurant = restaurantInfo[indexPath.row]
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deletAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (action, sourceView, complete) in
            
            if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
                let context = appDelegate.persistentContainer.viewContext
                if let restaurantToDelete = self?.fetchResultController?.object(at: indexPath) {
                    context.delete(restaurantToDelete)
                }
                
                appDelegate.saveContext()
            }
            complete(true)
        }
        let heartAction = UIContextualAction(style: .normal, title: nil) { [weak self] (action, sourceView, complete) in
            
            let cell = tableView.cellForRow(at: indexPath) as? FoodTableViewCell
            
            self?.getCoreDatas { (data, appDelegate, context) in
                data[indexPath.row].isVisited = data[indexPath.row].isVisited ? false : true
                appDelegate.saveContext()
            }
            
            if self?.restaurantInfo[indexPath.row].isVisited == true {
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

//新增圖片
extension ViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        default:
            tableView.reloadData()
        }
        
        if let fetchedObjects = controller.fetchedObjects {
            restaurantInfo = fetchedObjects as? [RestaurantMO] ?? []
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
