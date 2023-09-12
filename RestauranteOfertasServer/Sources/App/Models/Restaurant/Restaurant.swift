//
//  File.swift
//  
//
//  Created by Alberto Junquera Ramírez on 7/8/23.
//

import Vapor
import Fluent

///The Offer model represents an Offer in the database context.
final class Restaurant: Content, Model {
    
    ///Scheme
    static var schema = "restaurants"
    
    //MARK: - Properties
    
    /// Address identifier. PK.
    @ID(key: .id) //PK
    var id: UUID?
    
    /// FK. The id of the company related to the restaurant.
    @Field(key: "id_company") //TODO: @Parent?
    var idCompany: UUID
    
    /// Timestamp that store the restaurant's creation complete date.
    @Timestamp(key: "created_at", on: .create, format: .iso8601)
    var createdAt: Date?
    
    /// Name.
    @Field(key: "name")
    var name: String
    
    /// Picture. URL.
    @Field(key: "picture")
    var picture: String
    
    /// Governmental code that identifies the restaurant. Optional value.
    @Field(key: "cif")
    var cif: String?
    
    /// Type of restaurant. Ej. Japanese.
    @Field(key: "type")
    var type: String
    
    /// FK: The id of the address of the restaurant.
    @Parent(key: "id_address") //FK
    var address: Address
    
    /// FK: The id of the coordinates of the restaurant.
    @OptionalParent(key: "id_coordinates")
    var coordinates: Coordinates?
    
    /// List of the offers related to the restaurant. This field is not stored in the Restaurant table. Is only used for the purposes of retrieving some data.
    @Children(for: \Offer.$restaurant)
    var offers: [Offer]
    
    /// Opening hour of the restaurante.
    @Field(key: "opening_hour")
    var openingHour: String //TODO: It should be an hour only Date. But the formatting gives a full date.
    
    /// Closing hour of the restaurant.
    @Field(key: "closing_hour")
    var closingHour: String //TODO: It should be an hour only Date. But the formatting gives a full date.
    
    //MARK: - Inits
    
    /// Empty initializer.
    init() { }
    
    /// Parameterized initializer.
    init(id: UUID? = nil, idCompany: UUID, createdAt: Date? = nil, name: String, picture: String, cif: String? = nil, type: String, address: Address, coordinates: Coordinates, openingHour: String, closingHour: String) throws {
        self.id = id
        self.idCompany = idCompany
        self.createdAt = createdAt
        self.name = name
        self.picture = picture
        self.cif = cif
        self.type = type
        self.$address.id = try address.requireID() //TODO: Check
        self.$coordinates.id = coordinates.id
        self.openingHour = openingHour
        self.closingHour = closingHour
    }
}

// MARK: - DTOs -
extension Restaurant {
    
    /// Data structure used for the creation of restaurants in the database.
    struct Create: Content, Validatable {
        let idCompany: UUID
        let name: String
        let picture: String
        let cif: String?
        let type: String
        let country: String
        let state: String
        let city: String
        let zipCode: String ///ZipCode is a number, but it does not work as an average number. As a string is more flexible.
        let address: String
        let latitude: Double
        let longitude: Double
        let openingHour : String ///The request send from RapidApi can not send the Date Type, it can send numer, string, bool , object, but not date
        let closingHour : String ///The request send from RapidApi can not send the Date Type, it can send numer, string, bool , object, but not date
        
        /// Method that validates the data types of the parameters sent in the body of the request.
        /// - Parameter validations: Elements to validate.
        static func validations(_ validations: inout Vapor.Validations) {
            /// Core restaurant validations
            validations.add("idCompany", as: UUID.self, required: true)
            validations.add("name", as: String.self, is: !.empty, required: true)
            validations.add("picture", as: String.self, is: !.empty, required: true)
            validations.add("cif", as: String.self, required: true)
            validations.add("type", as: String.self, is: !.empty, required: true)
            
            ///Address validations
            validations.add("country", as: String.self, required: true)
            validations.add("state", as: String.self, required: true)
            validations.add("city", as: String.self, required: true)
            validations.add("zipCode", as: String.self, required: true)
            validations.add("address", as: String.self, required: true)
            
            ///Coordinates validations
            validations.add("latitude", as: Double.self, required: true)
            validations.add("longitude", as: Double.self, required: true)
            
            /// The request send from RapidApi can not send the Date Type, it can send numer, string, bool , object, but not date
            validations.add("openingHour", as: String.self, required: true)
            validations.add("closingHour", as: String.self, required: true)
        }
    }
    
    /// Data structure used to generate the object that will be sent to the FrontEnd.
    struct PublicRestaurant: Content{
        let id: UUID
        let idCompany: UUID
        let name: String
        let picture: String
        let type: String
        let address: Address
        let coordinates: Coordinates
    }
    
    /// Data structure used to generate the object that will be sent to the FrontEnd. In this case, a restaurant with the list of offers posted by it..
    struct RestaurantWithOffers: Content{
        
        ///Restautrant ID.
        let id: UUID
        
        /// Restaurant name.
        let name: String
        
        /// Restaurant picture.
        let picture: String
        
        /// Restaurant type.
        let type: String
        
        /// List of the offers posted by the restaurant.
        let offers: [Offer.Public]
    }
}

