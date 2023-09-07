//
//  File.swift
//  
//
//  Created by Alberto Junquera Ramírez on 6/9/23.
//

import Vapor

struct RestaurantMappers {
    static func mapperFromRestaurantToPublicRestaurant(restaurant: Restaurant) -> Restaurant.PublicRestaurant{
        return Restaurant.PublicRestaurant(id: restaurant.id!,
                                idCompany: restaurant.idCompany,
                                name: restaurant.name,
                                picture: restaurant.picture,
                                type: restaurant.type,
                                address: restaurant.address,
                                coordinates: restaurant.coordinates!)
    }
    
    static func mapperFromRestaurantsToPublicRestaurantsList(restaurantsList: [Restaurant]) -> [Restaurant.PublicRestaurant]{
        var result : [Restaurant.PublicRestaurant] = []
        restaurantsList.forEach { restaurant in
            result.append(mapperFromRestaurantToPublicRestaurant(restaurant: restaurant))
        }
        return result
    }
}
