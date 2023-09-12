//
//  File.swift
//  
//
//  Created by Alberto Junquera Ramírez on 7/8/23.
//

import Vapor
import Fluent
/// RestaurantController is a struct with the EndPoints related with the restaurants. Each methods function as an EndPoint. The "boot" method, defines how each EndPoint should be called.
struct RestaurantController : RouteCollection{
    
    /// The boot method is part of the RouteCollection protocol. This method sets how the EndPoint should be invoked.
    /// - Parameter routes: Is a RouteBuilder, which registers all of the routes in the group to this router.
    func boot(routes: Vapor.RoutesBuilder) throws {
        
        ///The routes are protected with both, a JWT authenticator and a JWT Middleware. This way, only users with valid JWT Tokens can access these EndPoints.
        routes.group(JWTToken.authenticator(),JWTToken.guardMiddleware()) { builder in
            
            /// "addRestaurant": Allows to create a new restaurant.
            builder.post("addRestaurant", use: addRestaurant)
            
            /// "restaurants": Retrieves a list of all the restaurants.
            builder.get("restaurants", use: allRestaurants)
            
            /// "restaurants/id": Retieves a specific restaurant based on the restaurant id field.
            builder.get("restaurants", ":id", use: getRestaurantById)
            
            /// "restaurants/id": Retieves a list of restaurants based on the restaurant type field.
            builder.get("restaurants-type", ":type" , use: getRestaurantByType)
            
            /// "restaurants/id": Updates a specific restaurant with the new provided values.
            builder.put("restaurants", ":id", use: updateRestaurant)
            
            /// "restaurantsCompany/company": Retieves a list of restaurants created by the company that owns them (id company).
            builder.get("restaurantsCompany", ":company", use: getRestaurantsByCompany)
            
            /// "restaurantWithOffer": Retieves a specidic restaurant that includes the offers that this restaurant has published based on the restaurant id field.
            builder.get("restaurantWithOffer", ":id", use: getRestaurantWithOffersByID)//restaurantWithOffersByID
        }
    }
    
    //MARK: - Routes -
    
    /// Method that adds  a restaurant into the database.
    /// - Parameter req: Contains the authorization requierements and the parameters needed to create a restaurant.
    /// - Returns: A HTTPStatus code.
    func addRestaurant(req: Request)  async throws -> HTTPStatus { //TODO: Check return type
        
        ///Data is validated.
        try Restaurant.Create.validate(content: req)
        
        ///Data is decoded.
        let restaurantCreate = try req.content.decode(Restaurant.Create.self)
        
        ///In the first place, the coordinates are added to the database.
        let coordinates = try Coordinates(latitude: restaurantCreate.latitude, longitude: restaurantCreate.longitude)
        
        try await coordinates.create(on: req.db)
        
        ///Secondly, the address is added to the database.
        let address =  Address(country: restaurantCreate.country, state: restaurantCreate.state, city: restaurantCreate.city, zipCode: restaurantCreate.zipCode, address: restaurantCreate.address)
        
        try await address.create(on: req.db)
        
        ///Finally the restaurant is added to the database.
        let restaurant = try Restaurant(idCompany: restaurantCreate.idCompany, name: restaurantCreate.name, picture: restaurantCreate.picture, type: restaurantCreate.type, address: address, coordinates: coordinates, openingHour: restaurantCreate.openingHour  , closingHour: restaurantCreate.closingHour)
        
        try await restaurant.create(on: req.db)
        
        return .ok  //.ok = 200, .created = .201 //TODO: Shoud it be .created insted of .ok?
    }
    
    
    /// Method that retrieves all the restaurants with the values stored in the Coordiantes and Address tables.
    /// - Parameter req: Contains the autherizathion.
    /// - Returns: An APIResponse object that contains the number of elements and a list of [Restaurant.PublicRestaurant].
    func allRestaurants(req: Request)  throws -> EventLoopFuture<APIResponse<Restaurant.PublicRestaurant>>{
        //TODO: Add pagination.
        return Restaurant.query(on: req.db)
            .join(Coordinates.self, on: \Restaurant.$coordinates.$id == \Coordinates.$id)
            .with(\.$coordinates)
            .join(Address.self, on: \Restaurant.$address.$id == \Address.$id)
            .with(\.$address)
            .all()
            .map{ restaurants in
                
                let publicRestaurantList = RestaurantMappers.mapperFromRestaurantsToPublicRestaurantsList(restaurantsList: restaurants)
                
                let apiResponse =  APIResponse<Restaurant.PublicRestaurant>(items: restaurants.count, result: publicRestaurantList)
                
                return apiResponse
            }
    }
    
    /// Method that retrieves a specific restaurant from the database based ob the restaurant id.
    /// - Parameter req: Contains the authentication parameters and the id value needed to do the query.
    /// - Returns: A restaurant with the provided restaurant id.
    func getRestaurantById(req: Request) async throws -> Restaurant {
        //TODO: Refactor to return a Restaurant.PublicRestaurant.
        let id = req.parameters.get("id", as: UUID.self)
        
        guard let restaurant = try await Restaurant.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        return restaurant
    }
    
    
    /// Method tha retrieves a list of the restaurants created by a certain company based on the company id.
    /// - Parameter req: Contains the authorization parameters and the company id.
    /// - Returns: A list of Restaurant.
    func getRestaurantsByCompany(req: Request) async throws -> [Restaurant] {
        //TODO: Refactor to return a APIResponse<Restaurant.PublicRestaurant>
        let company = req.parameters.get("company", as: UUID.self) ?? UUID()
        
        let restaurants = try await Restaurant.query(on: req.db)
            .filter(\.$idCompany == company)
            .all()
        
        if restaurants.isEmpty {
            throw Abort(.notFound)
        }
        
        return restaurants
    }
    
    /// Method tha retrieves a list of the restaurants based on restaurant type.
    /// - Parameter req: Contains the authorization parameters and the type.
    /// - Returns: A list of Restaurant.
    func getRestaurantByType(req: Request) async throws -> [Restaurant] {
        //TODO: Refactor to return an APIResponse<Restaurant.PublicRestaurant>
        let type = req.parameters.get("type", as: String.self) ?? ""
        
        let restaurants = try await Restaurant.query(on: req.db)
            .filter(\.$type == type)
            .all()
        
        if restaurants.isEmpty {
            throw Abort(.notFound)
        }
        
        return restaurants
    }
    
    /// Method that updates a specific restaurant based on the restaurant id.
    /// - Parameter req: Contains the authorization and the values needed to update the restaurant.
    /// - Returns: A HTTPStatus code.
    func updateRestaurant(req: Request) async throws -> HTTPStatus {
        let id = req.parameters.get("id", as: UUID.self)
        
        let updatedData = try req.content.decode(Restaurant.Create.self)
        
        /// Find the restaurant by ID
        guard let existingRestaurant = try await Restaurant.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        existingRestaurant.name = updatedData.name
        existingRestaurant.type = updatedData.type
        
        /// Changes values are updated in the database
        try await existingRestaurant.update(on: req.db)
        
        return .ok
    }
    
    /// Method that retrieves a specific restaurant based on the restaurant id.
    /// - Parameter req: Contains the authorization and the id needed to perform the query.
    /// - Returns: A Restaurant object.
    func restaurantByID(req: Request) async throws -> Restaurant {
        //TODO: Refactor to return a Restaurant.PublicRestaurant
        let id = req.parameters.get("id", as: UUID.self)
        
        guard let restaurant = try await Restaurant.find(id, on: req.db) else {
            throw Abort(.notFound)
        }
        return restaurant
    }
    
    
    // Retrieve one Restaurant with the List of Offers through RestaurantID
    /// Method that return a specific restaurant with a list of the offers posthed by said restaurant based on the restaurant id.
    /// - Parameter req: contains the authorization and the restaurant id parameter.
    /// - Returns: A Restaurant.RestaurantWithOffers object.
    func getRestaurantWithOffersByID(req: Request) async throws -> Restaurant.RestaurantWithOffers {
        
        let id = req.parameters.get("id", as: UUID.self)
        let retrievedOffers =  try await Offer.query(on: req.db)
            .with(\.$restaurant)
            .filter(\Offer.$restaurant.$id == id!)
            .all()
        
        let offerMappedList = OfferMappers.mapperFromOffersToOfferPublicList(offersList: retrievedOffers)
        let restaurant = retrievedOffers[0].restaurant
        
        return Restaurant.RestaurantWithOffers(id: restaurant.id!,
                                               name: restaurant.name,
                                               picture: restaurant.picture,
                                               type: restaurant.type,
                                               offers: offerMappedList)
    }
}

