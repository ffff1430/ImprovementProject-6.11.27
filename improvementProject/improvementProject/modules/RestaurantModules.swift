//
//  RestaurantModules.swift
//  improvementProject
//
//  Created by chen yue on 2020/8/25.
//  Copyright © 2020 chen yue. All rights reserved.
//

import Foundation
import UIKit

class RestaurantModules {
    
    func getRestaurantDatas(callback: @escaping (([Restaurant], URLResponse?, Error?, Data?) -> Void)) {
        let url = "https://raw.githubusercontent.com/cmmobile/ImprovementProjectInfo/master/info/restaurants.json"
        
        if let url = URL(string: url) {
            URLSession.shared.dataTask(with: url) { (data, response , error) in
                let decoder = JSONDecoder()
                if let data = data, let dataFromJson = try? decoder.decode([Restaurant].self, from: data) {
                    self.getImage(restaurant: dataFromJson, complete: { (restaurant, data) in
                        callback(dataFromJson, response, error, data)
                    })
                } else {
                    callback([], response, error, data)
                }
            }.resume()
        }
    }
    
    func getImage(restaurant: [Restaurant], complete: @escaping (([Restaurant], Data?) -> Void)) {
        for (index, _) in restaurant.enumerated(){
            if let imageName = restaurant[index].image{
                let url = URL(string: "https://raw.githubusercontent.com/cmmobile/ImprovementProjectInfo/master/info/pic/restaurants/\(imageName).jpg")
                if let url = url{
                    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                        DispatchQueue.main.async {
                            complete(restaurant, data)
                        }
                    }
                    task.resume()
                }
            }
        }
    }
}
