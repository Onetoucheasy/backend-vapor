//
//  File.swift
//  
//
//  Created by Alberto Junquera Ramírez on 6/9/23.
//

import Vapor
///Struct to map the restaurant results.
struct RestaurantMappers {
    /// Method that transforms one Restaurant into a Restaurant.PublicRestaurant.
    /// - Parameter offer: A Restaurant object.
    /// - Returns: A Restaurant.PublicRestaurant object.
    static func mapperFromRestaurantToPublicRestaurant(restaurant: Restaurant) -> Restaurant.PublicRestaurant{
        return Restaurant.PublicRestaurant(id: restaurant.id!,
                                idCompany: restaurant.idCompany,
                                name: restaurant.name,
                                picture: restaurant.picture,
                                type: restaurant.type,
                                address: restaurant.address,
                                coordinates: restaurant.coordinates!)
    }
    /// Method that transforms a [Restaurant] list into a [Restaurant.PublicRestaurant]
    /// - Parameter offersList: A Restaurant list [Restaurant]
    /// - Returns: A Restaurant.PublicRestaurant list [Restaurant.PublicRestaurant]
    static func mapperFromRestaurantsToPublicRestaurantsList(restaurantsList: [Restaurant]) -> [Restaurant.PublicRestaurant]{
        var result : [Restaurant.PublicRestaurant] = []
        restaurantsList.forEach { restaurant in
            result.append(mapperFromRestaurantToPublicRestaurant(restaurant: restaurant))
        }
        return result
    }
}
