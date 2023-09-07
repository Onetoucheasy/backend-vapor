//
//  OfferController.swift
//  
//
//  Created by Camila Laura Lopez on 22/8/23.
//

import Vapor
import Fluent

struct OfferController : RouteCollection{
    func boot(routes: Vapor.RoutesBuilder) throws {
        
        routes.group(JWTToken.authenticator(), JWTToken.guardMiddleware()) { builder in
            
            builder.get("offers", use: allOffers)
            builder.get("offers", ":id", use: getOfferById)
            //builder.get("offers-with-restaurants", use: getAllOffersWithRestaurantsData)
            builder.get("restaurantsWithOffer", use: getOffersGroupedByRestaurantID)

        }
    }
    
    func allOffers(req: Request) async throws -> [Offer]{
        try await Offer.query(on: req.db).all()
    }
    
    func getOfferById(req: Request) async throws -> Offer{
        let id = req.parameters.get("id", as: UUID.self)
        
        guard let offer = try await Offer.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        return offer
    }
    
    // Retrieve all offers grouped by restaurant id
    func getOffersGroupedByRestaurantID(req: Request)  throws -> EventLoopFuture<APIResponse<Restaurant.RestaurantWithOffers>>{
      
       return Offer.query(on: req.db)
            .with(\.$restaurant)
            .all()
            .flatMap{ offers in
                let groupedOffers = Dictionary(grouping: offers) { offer in
                    offer.restaurant.id!.uuidString //TODO: check if works without uuidString
                }
                var result : [Restaurant.RestaurantWithOffers] = []
                
                for(restaurantID, restaurantOffers) in groupedOffers{
                    if let firstOffer = restaurantOffers.first{
                        
                        let OfferPublicList = OfferMappers.mapperFromOffersToOfferPublicList(offersList: restaurantOffers)
                        
                        let restaurantWithOffers = Restaurant.RestaurantWithOffers(
                            id: firstOffer.restaurant.id!,
                            name: firstOffer.restaurant.name,
                            picture: firstOffer.restaurant.picture,
                            type: firstOffer.restaurant.type,
                            offers: OfferPublicList)
                        
                        result.append(restaurantWithOffers)
                    }
                }
                let apiResponse = APIResponse<Restaurant.RestaurantWithOffers>(items: result.count, result: result)
                return req.eventLoop.makeSucceededFuture(apiResponse)
            }
        
    }
    
}
