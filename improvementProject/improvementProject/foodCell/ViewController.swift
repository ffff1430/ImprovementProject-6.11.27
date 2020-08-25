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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        restaurant.getRestaurantData { (data, response, error) in
            self.restaurantInfo = data
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
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
        
        if var name = (restaurantInfo[indexPath.row].name)?.trimmingCharacters(in: .whitespaces).filter({ $0.isNumber || $0.isLetter }).lowercased(){
            if name == "bourkestreetbackery"{
                name = "bourkestreetbakery"
            } else if name == "caskpubandkitchen"{
                name = "caskpubkitchen"
            }
            let url = URL(string: "https://raw.githubusercontent.com/cmmobile/ImprovementProjectInfo/master/info/pic/restaurants/\(name).jpg")
            if let url = url{
                let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                    DispatchQueue.main.async {
                    if let data = data, cell.nameLabel.text == self.restaurantInfo[indexPath.row].name{
                            cell.foodImage.image = UIImage(data: data)
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
        viewcontroller.name = restaurantInfo[indexPath.row].name ?? ""
        viewcontroller.location = restaurantInfo[indexPath.row].location ?? ""
        viewcontroller.type = restaurantInfo[indexPath.row].type ?? ""
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
}
