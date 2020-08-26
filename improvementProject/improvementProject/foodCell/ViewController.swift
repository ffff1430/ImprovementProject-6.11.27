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
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        restaurant.getRestaurantDatas { (data, response, error)  in
            self.restaurantInfo = data
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
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
        cell.nameLabel.text = restaurantInfo[indexPath.row].name
        cell.countryLabel.text = restaurantInfo[indexPath.row].location
        cell.typeLabel.text = restaurantInfo[indexPath.row].type
        
        cell.foodImage.image = getImage(index: indexPath.row)
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let viewcontroller = UIStoryboard(name: "Result", bundle: nil).instantiateViewController(withIdentifier: "ResultVC") as? ResultViewController else { return }
        viewcontroller.name = restaurantInfo[indexPath.row].name ?? ""
        viewcontroller.location = restaurantInfo[indexPath.row].location ?? ""
        viewcontroller.type = restaurantInfo[indexPath.row].type ?? ""
        viewcontroller.image = getImage(index: indexPath.row)
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
}
