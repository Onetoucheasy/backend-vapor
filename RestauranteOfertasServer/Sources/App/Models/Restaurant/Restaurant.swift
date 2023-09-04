//
//  File.swift
//  
//
//  Created by Alberto Junquera Ramírez on 7/8/23.
//

import Vapor
import Fluent
import CoreLocation

final class Restaurant: Content, Model {
     
    //Scheme
    static var schema = "restaurants"
    
    //Properties
    @ID(key: .id) //PK
    var id: UUID?
    
    @Field(key: "id_company") //FK
    var idCompany: UUID
    
    @Timestamp(key: "created_at", on: .create, format: .iso8601)
    var createdAt: Date?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "cif") //TODO: Are we going to request "cif"?
    var cif: String?
    
    @Field(key: "type") //FK?
    var type: String //TODO: String or Enum?
    
//    @Field(key: "id_address") //FK
//    var idAddress: UUID
    @Parent(key: "id_address") //FK
    var address: Address
    
    //TODO: I think that the parent table is restaurant
   // @Parent(key: "id_coordinates") //FK // One Restaurant have one set of coordinates, but a set of coordiantes can be used by diferent restaurants.
    @OptionalParent(key: "id_coordinates") //FK // One Restaurant have one set of coordinates, but a set of coordiantes can be used by diferent restaurants.
    var coordinates: Coordinates?
//    @Children(for: \.$restaurant) //FK // One Restaurant have one set of coordinates, but a set of coordiantes can be used by diferent restaurants.
//    var coordinates: [Coordinates]
    
    //TODO: do not remove the id schedule commented file
//    @Field(key: "id_schedule") //FK
//    var idSchedule: UUID
    
    @Field(key: "opening_hour")
    var openingHour: String
    
    @Field(key: "closing_hour")
    var closingHour: String
    
    // Inits
    init() { }
    
 
    internal init(id: UUID? = nil, idCompany: UUID, createdAt: Date? = nil, name: String, cif: String? = nil, type: String, address: Address, coordinates: Coordinates, openingHour: String, closingHour: String) throws {
        self.id = id
        self.idCompany = idCompany
        self.createdAt = createdAt
        self.name = name
        self.cif = cif
        self.type = type
        self.$address.id = try address.requireID() // coordinates.id //TODO: Check
        //self.$coordinates.id = try coordinates.requireID()
        self.$coordinates.id = coordinates.id
        self.openingHour = openingHour
        self.closingHour = closingHour
    }
    
}

// MARK: - DTOs -
extension Restaurant {

    struct Create: Content, Validatable {
        let idCompany: UUID
        let name: String
        let cif: String?
        let type: String
        let country: String
        let state: String
        let city: String
        let zipCode: String //ZipCode is a number, but it does not work as an average number. As a string is more flexible.
        let address: String
        let latitude: Double
        let longitude: Double
        let openingHour : String
        let closingHour : String //The api request can not send the Date Type, it can send numer, string, bool , object, but not date
        
        static func validations(_ validations: inout Vapor.Validations) {
            
            validations.add("idCompany", as: UUID.self, required: true)
            validations.add("name", as: String.self, is: !.empty, required: true)
            validations.add("cif", as: String.self, required: true)
            validations.add("type", as: String.self, is: !.empty, required: true)
           
            //Address validations
            //validations.add("idAddress", as: UUID.self, required: true)
            validations.add("country", as: String.self, required: true)
            validations.add("state", as: String.self, required: true)
            validations.add("city", as: String.self, required: true)
            validations.add("zipCode", as: String.self, required: true)
            validations.add("address", as: String.self, required: true)
            
            //Coordinates validations
            //validations.add("idCoordinates", as: UUID.self, required: true)
            validations.add("latitude", as: Double.self, required: true)
            validations.add("longitude", as: Double.self, required: true)
            
            //validations.add("idSchedule", as: UUID.self, required: true)
            //TODO: Maybe the validator is String
            validations.add("openingHour", as: String.self, required: true)
            validations.add("closingHour", as: String.self, required: true)
        }
        
    }
    
    struct Public: Content {
        
        let id: UUID
        let idCompany: UUID
        let name: String
        //let cif: String?
        let type: String
       //TODO: The next id should not be shown. Do the Query and return the real values as nested Objects. 
        let idAddress: UUID
        let idCoordinates: UUID
        let adSchedule: UUID
        
    }
    //Struct to return all the restaurants with the nested values.
    struct APIResponse: Content{
        let code: HTTPStatus
        let status: String
        let totalResults: Int
        let restaurants: [Restaurant]
    }
    
}
