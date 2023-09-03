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
}
