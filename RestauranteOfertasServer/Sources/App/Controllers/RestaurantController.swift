//
//  File.swift
//  
//
//  Created by Alberto Junquera Ramírez on 7/8/23.
//

import Vapor
import Fluent

struct RestaurantController : RouteCollection{
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.group(JWTToken.authenticator(),JWTToken.guardMiddleware()) { builder in
            builder.post("addRestaurant", use: addRestaurant)
            builder.get("restaurants", use: allRestaurants)
            builder.get("restaurants", ":id", use: getRestaurantById)
            builder.get("restaurants-type", ":type" , use: getRestaurantByType)
            builder.put("restaurants", ":id", use: updateRestaurant)
            builder.get("restaurants-company", ":company", use: getRestaurantsByCompany)

        }
    }
    
     //MARK: - Routes -
    //Companies can add restaurants.
    //  func addRestaurant(req: Request) async throws -> Restaurant.Public {
    func addRestaurant(req: Request) async throws -> String {
        //TODO: Where should be checked if the user is a company?
        try Restaurant.Create.validate(content: req)
        
        //Decode
        let restaurantCreate = try req.content.decode(Restaurant.Create.self)
        
        //Save restaurant
        let restaurant = Restaurant(idCompany: restaurantCreate.idCompany, name: restaurantCreate.name, type: restaurantCreate.type, idAddress: restaurantCreate.idAddress, idCoordinates: restaurantCreate.idCoordinates, idSchedule: restaurantCreate.idSchedule)
        
        try await restaurant.create(on: req.db)
        
        
        return "Restaurant Added" //TODO: Does it need a return?
        
    }
    //Retrieve all restaurants
    
    func allRestaurants(req: Request) async throws -> [Restaurant]{
        try await Restaurant.query(on: req.db).all()
    }
    
    //Retrieve a restaurant by idRestaurant
    func getRestaurantById(req: Request) async throws -> Restaurant {
        let id = req.parameters.get("id", as: UUID.self)
        
        guard let restaurant = try await Restaurant.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        return restaurant
    }
    
    //Retrieve all the restaurants from a company
    
    func getRestaurantsByCompany(req: Request) async throws -> [Restaurant] {
        let company = req.parameters.get("company", as: UUID.self) ?? UUID()
        
        let restaurants = try await Restaurant.query(on: req.db)
            .filter(\.$idCompany == company)
            .all()
        
        if restaurants.isEmpty {
            throw Abort(.notFound)
        }
        
        return restaurants
    }
    
    //Retrieve restaurant by type
    func getRestaurantByType(req: Request) async throws -> [Restaurant] {
        let type = req.parameters.get("type", as: String.self) ?? ""
        
        let restaurants = try await Restaurant.query(on: req.db)
            .filter(\.$type == type)
            .all()
        
        if restaurants.isEmpty {
            throw Abort(.notFound)
        }
        
        return restaurants
    }

    
    
    // Update a restaurant
    func updateRestaurant(req: Request) async throws -> String {
        let id = req.parameters.get("id", as: UUID.self)
        
        let updatedData = try req.content.decode(Restaurant.Create.self)
        
        // Find the restaurant by ID
        guard let existingRestaurant = try await Restaurant.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        existingRestaurant.name = updatedData.name
        existingRestaurant.type = updatedData.type
        
        // Save the changes to the database
        try await existingRestaurant.update(on: req.db)
        
        return "Restaurant Updated"
    }

}
