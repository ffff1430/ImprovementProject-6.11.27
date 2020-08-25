//
//  RestaurantModules.swift
//  improvementProject
//
//  Created by chen yue on 2020/8/25.
//  Copyright © 2020 chen yue. All rights reserved.
//

import Foundation


class RestaurantModules{
    
    func getRestaurantData(callback: @escaping (([Restaurant], URLResponse?, Error?) -> Void)) {
        let url = "https://raw.githubusercontent.com/cmmobile/ImprovementProjectInfo/master/info/restaurants.json"
        
        if let url = URL(string: url) {
            URLSession.shared.dataTask(with: url) { (data, response , error) in
                let decoder = JSONDecoder()
                if let data = data, let dataFromJson = try? decoder.decode([Restaurant].self, from: data) {
                        callback(dataFromJson, response, error)
                } else {
                    print("error")
                }
            }.resume()
        }
    }
}
