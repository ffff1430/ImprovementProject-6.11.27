//
//  RestaurantManager.swift
//  improvementProject
//
//  Created by chen yue on 2020/8/25.
//  Copyright © 2020 chen yue. All rights reserved.
//

import Foundation
import UIKit

class RestaurantManager {
            
    func getRestaurantDatas(callback: @escaping (([RestaurantBaseInfo], URLResponse?, Error?) -> Void)) {
        
        let url = "https://raw.githubusercontent.com/cmmobile/ImprovementProjectInfo/master/info/detail_restaurants.json"
        if let url = URL(string: url) {
            URLSession.shared.dataTask(with: url) { (data, response , error) in
                let decoder = JSONDecoder()
                if let data = data, let dataFromJson = try? decoder.decode([RestaurantBaseInfo].self, from: data) {
                    DispatchQueue.main.async {
                        callback(dataFromJson, response, error)
                    }
                } else {
                    callback([], response, error)
                }
            }.resume()
        }
    }
}

