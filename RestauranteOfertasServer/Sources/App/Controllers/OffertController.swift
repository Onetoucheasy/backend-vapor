//
//  OffertController.swift
//  
//
//  Created by Eric Olsson on 8/17/23.
//

import Vapor
import Fluent

struct OffertController : RouteCollection {

    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.group(JWTToken.authenticator(),JWTToken.guardMiddleware()) { builder in
            builder.get("offerts", ":id", use: getOffertsById) // GET: api/offerts
            builder.get("offerts", use: allOfferts)
        }
    }
    
    //Retrieve an offer by user idRestaurant
    func getOffertsById(req: Request) async throws -> Offert {
        let idRestaurant = req.parameters.get("idRestaurant", as: UUID.self)
        
        guard let offerts = try await Offert.find(idRestaurant, on: req.db) else {
            throw Abort(.notFound)
        }
        return offerts
    }
    
    func allOfferts(req: Request) async throws -> [Offert]{
        try await Offert.query(on: req.db).all()
    }
}
