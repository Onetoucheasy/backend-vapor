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
        
        let address =  Address(country: restaurantCreate.country, state: restaurantCreate.state, city: restaurantCreate.city, zipCode: restaurantCreate.zipCode, address: restaurantCreate.address)
        
        try await address.create(on: req.db)
       
//        let openingHourDate = Date.parseISO8601StringToHourMinuteDate(iso8601StringDate: restaurantCreate.openingHour)
//        let closingHourDate = Date.parseISO8601StringToHourMinuteDate(iso8601StringDate: restaurantCreate.closingHour)
        
        let restaurant = try Restaurant(idCompany: restaurantCreate.idCompany, name: restaurantCreate.name, picture: restaurantCreate.picture, type: restaurantCreate.type, address: address, coordinates: coordinates, openingHour: restaurantCreate.openingHour  , closingHour: restaurantCreate.closingHour)
        
        try await restaurant.create(on: req.db)
       
        return .ok  //.ok = 200, .created = .201 //TODO: Shoud it be .created insted of .ok?
    }
    
    //TODO: The commented one works but return the ids.
    //Retrieve all restaurants
//    func allRestaurants(req: Request) async throws -> [Restaurant]{
//        try await Restaurant.query(on: req.db).all()
//    }
    //https://docs.vapor.codes/basics/async/?h=eventloopfuture#eventloopfutures
    //Retrieve all restaurants
    func allRestaurants(req: Request)  throws -> EventLoopFuture<Restaurant.APIResponse>{
        return Restaurant.query(on: req.db)
            .join(Coordinates.self, on: \Restaurant.$coordinates.$id == \Coordinates.$id)
            .with(\.$coordinates)
            .join(Address.self, on: \Restaurant.$address.$id == \Address.$id)
            .with(\.$address)
            .all()
            .map{ restaurants in
                let apiResponse =  Restaurant.APIResponse(
                    code: .ok,
                    status: "success",
                    totalResults: restaurants.count,
                    restaurants: restaurants)
                return apiResponse
            }
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
            
            rest.append(Restaurant.Public(id: restaurant.id!, idCompany: restaurant.idCompany , name: restaurant.name, picture: restaurant.picture, type: restaurant.type, address: restaurant.address, offers: restaurant.offers) )
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
       
       return Restaurant.Public(id: restaurant.id!, idCompany: restaurant.idCompany, name: restaurant.name, picture: restaurant.picture, type: restaurant.type, address: restaurant.address, offers: restaurant.offers)
   }
}
