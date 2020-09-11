//
//  NewRestaurant.swift
//  improvementProject
//
//  Created by chen yue on 2020/8/31.
//  Copyright © 2020 chen yue. All rights reserved.
//

import Foundation

protocol GetNewRestaurant: AnyObject{
    func didSetRestaurant(name: String, type: String, location: String, phone: String, description: String, isVisited: Bool, image: Data)
}

class NewRestaurant {
    
    weak var delegate: GetNewRestaurant?
    
    func setAddRestaurantData(name: String, type: String, location: String, phone: String, description: String, isVisited: Bool, image: Data) {
        
        
        delegate?.didSetRestaurant(name: name, type: type, location: location, phone: phone, description: description, isVisited: isVisited, image: image)
    }
    
    
}
