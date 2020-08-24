//
//  restaurant.swift
//  improvementProject
//
//  Created by chen yue on 2020/8/24.
//  Copyright © 2020 chen yue. All rights reserved.
//

import Foundation

struct Restaurant: Codable {
    var image: String?
    var isVisited: Bool?
    var name: String?
    var type: String?
    var location: String?
}

class RestaurantDecodable{
    
    func restaurantData(callback: @escaping (([Restaurant]) -> Void)) {
        let url = "https://raw.githubusercontent.com/cmmobile/ImprovementProjectInfo/master/info/restaurants.json"

        if let url = URL(string: url) {
            URLSession.shared.dataTask(with: url) { (data, response , error) in
                let decoder = JSONDecoder()
                if let data = data, let dataFromJson = try?
                   decoder.decode([Restaurant].self, from: data)
                {
                    callback(dataFromJson)
                } else {
                    print("error")
                }
            }.resume()
        }
    }
}
