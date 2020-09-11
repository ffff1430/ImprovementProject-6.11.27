//
//  RestaurantBaseInfo.swift
//  improvementProject
//
//  Created by chen yue on 2020/8/24.
//  Copyright © 2020 chen yue. All rights reserved.
//

import Foundation

struct RestaurantBaseInfo: Codable {
    var image: String?
    var isVisited: Bool
    var name: String?
    var type: String?
    var location: String?
    var phone: String?
    var description: String?
}

struct ArrangeRestaurantBaseInfo {
    var image: URL?
    var isVisited: Bool
    var name: String
    var type: String
    var location: String
    var phone: String
    var description: String
    var updateAt: Date
}


