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
    var isVisited: String?
}

class RestaurantDecodable{
    
    var restaurant: [Restaurant] = []

private func loadTWA00() {
    if let fileLocation = Bundle.main.url(forResource: "TWA00", withExtension: "json") {
        do {
            let data = try Data(contentsOf: fileLocation)
            let jsonDecode = JSONDecoder()
            let dataFromJson = try jsonDecode.decode([Restaurant].self, from: data)
            self.restaurant = dataFromJson
        } catch {
            print("error")
        }
    }
}

}
