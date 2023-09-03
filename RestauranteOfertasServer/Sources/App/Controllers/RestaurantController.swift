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
            builder.get("restaurantWithOffer", ":id", use: getRestaurantWithOffersByID)//restaurantWithOffersByID
            builder.get("restaurantsWithOffer", use: getRestaurantsWithOffers)
        }
    }
    
     //MARK: - Routes -
    //Companies can add restaurants.
    //  func addRestaurant(req: Request) async throws -> Restaurant.Public {
//    func addRestaurant(req: Request)  async throws -> String {
//        //TODO: Where should be checked if the user is a company?
//        print("before restaurant create")
//
//        try Restaurant.Create.validate(content: req)
//        print("after restaurant create")
//        //Decode
//        let restaurantCreate = try req.content.decode(Restaurant.Create.self)
//
//        let coordinates = try Coordinates(latitude: restaurantCreate.latitude, longitude: restaurantCreate.longitude)
//
//        await withThrowingTaskGroup(of: Void.self) { taskGroup in
//            taskGroup.addTask {
//                try await coordinates.create(on: req.db)
//            }
//        }
//
//        //Save restaurant
//        let restaurant = try Restaurant(idCompany: restaurantCreate.idCompany, name: restaurantCreate.name, type: restaurantCreate.type, idAddress: restaurantCreate.idAddress, coordinates: coordinates ,idSchedule: restaurantCreate.idSchedule)
//
//        await withThrowingTaskGroup(of: Void.self) { taskGroup in
//            taskGroup.addTask {
//                try await restaurant.create(on: req.db)
//            }
//        }
//
//        coordinates.restaurant.append(restaurant)
//
//        try await coordinates.$restaurant.attach
////        restaurant.coordinates.append(coordinates)
////        //restaurant.idCoordinates.append(coordinates)
////        coordinates.restaurant = restaurant
//
////        try await restaurant.create(on: req.db)
////        try await coordinates.create(on: req.db)
//
//        return "Restaurant Added" //TODO: Does it need a return?
//
//    }
    
    func addRestaurant(req: Request)  async throws -> HTTPStatus { //TODO: Check return type
        //Data validation
        try Restaurant.Create.validate(content: req)
        //Decode
        let restaurantCreate = try req.content.decode(Restaurant.Create.self)

        let coordinates = try Coordinates(latitude: restaurantCreate.latitude, longitude: restaurantCreate.longitude)
        
        try await coordinates.create(on: req.db)


        let restaurant = try Restaurant(idCompany: restaurantCreate.idCompany, name: restaurantCreate.name, type: restaurantCreate.type, idAddress: restaurantCreate.idAddress, coordinates: coordinates, idSchedule: restaurantCreate.idSchedule)
        
      //  try await coordinates.create(on: req.db)
        

        try await restaurant.create(on: req.db)
     //   try await coordinates.$restaurant.create(restaurant, on: req.db)
       
        return .ok

        //try await restaurant.$coordinates.create(on: req.db)
//        try await req.db.transaction { database in
//            try await coordinates.save(on: database).flatMap<Coordinates> { values  in
//
//                let savedCoordinates = Coordinates.find(coordinates.id, on: req.db)
//                if let idCoordinates = values.{
//                    restaurant.id = coordinates.id
//                }
//            }
//            try await restaurant.save(on: database)
//            coordinates.restaurant.append(restaurant)
//        }
        return .ok
        
  
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
    
    //Retrieve a restaurant by idRestaurant
    func restaurantByID(req: Request) async throws -> Restaurant {
        let id = req.parameters.get("id", as: UUID.self)
        
        guard let restaurant = try await Restaurant.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        return restaurant
    }
    
    // Retrieve all Restaurants with the List of Offers
    func getRestaurantsWithOffers(req: Request) async throws -> RestResponse {

        let restaurants = try await Restaurant.query(on: req.db).all()
        
        var rest : [Restaurant.Public] = []
       
        for restaurant in restaurants {
            try await restaurant.$offers.load(on: req.db)
            
            rest.append(Restaurant.Public(id: restaurant.id!, idCompany: restaurant.idCompany , name: restaurant.name, type: restaurant.type, idAddress: restaurant.idAddress, offers: restaurant.offers) )
        }

        return RestResponse(totalResults: rest.count, restaurants: rest)
    }
       
    // Retrieve one Restaurant with the List of Offers through RestaurantID
   func getRestaurantWithOffersByID(req: Request) async throws -> Restaurant.Public {
       
       let id = req.parameters.get("id", as: UUID.self)
       
       guard let restaurant = try await Restaurant.find(id, on: req.db) else {
           throw Abort(.notFound)
       }
       
       try await restaurant.$offers.load(on: req.db)
       
       return Restaurant.Public(id: restaurant.id!, idCompany: restaurant.idCompany, name: restaurant.name, type: restaurant.type, idAddress: restaurant.idAddress, offers: restaurant.offers)
   }
}
