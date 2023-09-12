//
//  File.swift
//  
//
//  Created by Alberto Junquera Ramírez on 7/8/23.
//

import Vapor
import Fluent

///The Coordinates model represents a coordinate in the database context.
final class Coordinates: Model{
    
    ///Scheme
    static var schema = "coordinates"
    
    //MARK: - Properties
    
    /// Coordinates identifier. PK.
    @ID(key: .id)
    var id: UUID?
    
    /// The id of the restaurant related to the coordinates. Represents a relationship to the coordinates associated with a restaurant.
    @Children(for: \Restaurant.$coordinates)
    var restaurant: [Restaurant]
    
    /// Latitude.
    @Field(key: "latitude")
    var latitude: Double
    
    /// Longitude.
    @Field(key: "longitude")
    var longitude: Double
    
    //MARK: - Inits.
    
    /// Empty initializer.
    init(){}
    
    /// Parameterized initializer.
    init(id: UUID? = nil, latitude: Double, longitude: Double) throws {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
    }
}

//MARK: - DTOs -

extension Coordinates{
    
    /// Data structure used for the creation of coordiantes in the database.
    struct Create: Content, Validatable {
        //TODO: Fix the problem related with the double properties in the body of the request.
        let latitude: String
        let longitude: String
        
        /// Method that validates the data types of the parameters sent in the body of the request.
        /// - Parameter validations: Elements to validate.
        static func validations(_ validations: inout Vapor.Validations) {
            validations.add("latitude", as: String.self, required: true)
            validations.add("longitude", as: String.self, required: true)
        }
    }
    
    /// Data structure used to generate the object that will be sent to the FrontEnd.
    struct Public {
        //TODO: Fix the problem related with the double properties in the body of the request.
        let id: UUID
        let idRestaurant: UUID
        let latitude: String
        let longitude: String
    }
}
