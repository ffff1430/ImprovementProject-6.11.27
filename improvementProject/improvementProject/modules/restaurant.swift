//
//  restaurant.swift
//  improvementProject
//
//  Created by chen yue on 2020/8/24.
//  Copyright © 2020 chen yue. All rights reserved.
//

import Foundation

struct Restaurant: Codable {
    var name: String?
    var type: String?
    var location: String?
    var image: String?
    var isVisited: Bool?
    
}

class RestaurantDecodable{
    
    func restaurantData(callback: @escaping (([Restaurant]) -> Void)) {
        if let fileLocation = Bundle.main.url(forResource: "restaurants", withExtension: "json") {
            do {
                let data = try Data(contentsOf: fileLocation)
                let jsonDecode = JSONDecoder()
                let dataFromJson = try jsonDecode.decode([Restaurant].self, from: data)
                callback(dataFromJson)
            } catch {
                print("error")
            }
        }
    }
}
