//
//  OfferController.swift
//  
//
//  Created by Camila Laura Lopez on 22/8/23.
//

import Vapor
import Fluent

/// OfferController is a struct with the EndPoints related with the offers. Each methods function as an EndPoint. The "boot" method, defines how each EndPoint should be called.
struct OfferController : RouteCollection{
    
    /// The boot method is part of the RouteCollection protocol. This method sets how the EndPoint should be invoked.
    /// - Parameter routes: Is a RouteBuilder, which registers all of the routes in the group to this router.
    func boot(routes: Vapor.RoutesBuilder) throws {
        
        ///The routes are protected with both, a JWT authenticator and a JWT Middleware. This way, only users with valid JWT Tokens can access these EndPoints.
        routes.group(JWTToken.authenticator(), JWTToken.guardMiddleware()) { builder in
            /// "offers" retrieves all the offers.
            builder.get("offers", use: allOffers)
            
            /// "offers/id" retrieve an offer filtered by the offer id.
            builder.get("offers", ":id", use: getOfferById)
            
            /// "restaurantsWithOffers" retrieves all offers grouped by the id of the restaurant that published the offer.
            builder.get("restaurantsWithOffer", use: getOffersGroupedByRestaurantID)
        }
    }
    
    /// Method that retrieves all the offers aviable in the database.
    /// - Parameter req: Contains the accessToken in the headers.
    /// - Returns: An array of Offer objects, with all the information aviable in the database.
    func allOffers(req: Request) async throws -> [Offer]{
        try await Offer.query(on: req.db).all()
    }
    
    /// Method that retrieves a specific offer based on the given offer id. provided in the request.
    /// - Parameter req: Contains the accessToken in the headers and the offer id that should be retrieved.
    /// - Returns: An Offer object, with all the information aviable in the database.
    func getOfferById(req: Request) async throws -> Offer{
        let id = req.parameters.get("id", as: UUID.self)
        
        guard let offer = try await Offer.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        return offer
    }
    
    // Retrieve all offers grouped by restaurant id
    /// Method that retrieves all offers grouped by the id of the restaurant that created the offer.
    /// - Parameter req: Contains the accessToken.
    /// - Returns: An APIResponse object with the number of restaurants, which contain an array with the offers grouped by the restaurant id.
    func getOffersGroupedByRestaurantID(req: Request)  throws -> EventLoopFuture<APIResponse<Restaurant.RestaurantWithOffers>>{
        //TODO: Add pagination.
        return Offer.query(on: req.db)
            .with(\.$restaurant)
            .all()
            .flatMap{ offers in
                ///The Dictionary simplifies the grouping process, grouping the offers by ID
                let groupedOffers = Dictionary(grouping: offers) { offer in
                    offer.restaurant.id!
                }
                var result : [Restaurant.RestaurantWithOffers] = []
                /// The offers list is mapped on a result, which maps the [Offer] into an [Offer.Public] list. Then a restaurant is created in which the [Offer.Public] is pased as a parameter to ensure that all the offers related with said restaurant, are grouped there.
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
                ///An APIResponse is generated if this process was successful.
                let apiResponse = APIResponse<Restaurant.RestaurantWithOffers>(items: result.count, result: result)
                return req.eventLoop.makeSucceededFuture(apiResponse)
            }
    }
}
