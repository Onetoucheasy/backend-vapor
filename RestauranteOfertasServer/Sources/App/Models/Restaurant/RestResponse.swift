//
//  File.swift
//  
//
//  Created by Marta Maquedano on 3/9/23.
//

import Vapor
import Fluent
import CoreLocation

final class RestResponse: Content  {
    
    let totalResults: Int
    let restaurants: [Restaurant.Public]
    
    init(totalResults: Int, restaurants: [Restaurant.Public]) {
        self.totalResults = totalResults
        self.restaurants = restaurants
    }
   
}
