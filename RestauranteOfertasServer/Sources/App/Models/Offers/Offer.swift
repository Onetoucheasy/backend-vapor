//
//  Offer.swift
//  
//
//  Created by Camila Laura Lopez on 22/8/23.
//

import Vapor
import Fluent

///The Offer model represents an Offer in the database context.
final class Offer: Content, Model {
    
    ///Scheme
    static var schema = "offers"
    
    //MARK: - Properties.
    
    ///Offer identifier. PK.
    @ID(key: .id) //PK
    var id: UUID?
    
    /// FK: The id of the restaurant that created the offer.
    @Parent(key: "id_restaurant")
    var restaurant: Restaurant
    
    ///FK: The id of the offer's state.
    @Field(key: "id_state") //TODO: Create the states table.
    var idState: UUID
    
    ///Offer's title.
    @Field(key: "title")
    var title: String
    
    /// Timestamp that store the offer's creation complete date.
    @Timestamp(key: "created_date", on: .create, format: .iso8601)
    var createdDate: Date?
    
    /// Time in which the offer starts.
    @Timestamp(key: "start_hour", on: .none, format: .iso8601) //TODO: @Date
    var startHour: Date?
    
    /// Time in which the offer ends.
    @Timestamp(key: "end_hour", on: .none, format: .iso8601) //TODO: @Date
    var endHour: Date?
    
    /// Promotial image related to the offer.
    @Field(key: "image")
    var image: String?
    
    /// The description of the offer.
    @Field(key: "description")
    var description: String
    
    /// The quantity of offered offers.
    @Field(key: "quantity_offered")
    var quantityOffered: Int
    
    /// Price. Some offers can have a fixed price.
    @Field(key: "price")
    var price: Int
    
    /// The currency in which the price is set.
    @Field(key: "id_currency") //TODO FK
    var idCurrency: UUID
    
    /// Minimum number of costumers needed per offer in order to the user to be able to redeem the offer.
    @Field(key: "minimum_customers")
    var minimumCustomers: Int
    
    /// Maximum number of costumers needed per offer in order to the user to be able to redeem the offer.
    @Field(key: "maximum_customers")
    var maximumCustomers: Int
    
    
    //MARK: - Inits
    /// Empty initializer.
    init() { }
    
    /// Parameterized initializer.
    init(id: UUID? = nil, restaurant: Restaurant, idState: UUID , title: String, image: String, description: String, quantityOffered: Int, startHour: Date, endHour: Date, price: Int, idCurrency: UUID,minimumCustomers: Int,maximumCustomers: Int) {
        self.id = id
        self.$restaurant.id = restaurant.id!
        self.idState = idState
        self.title = title
        self.image = image
        self.description = description
        self.quantityOffered = quantityOffered
        self.startHour = startHour
        self.endHour = endHour
        self.price = price
        self.idCurrency = idCurrency
        self.minimumCustomers = minimumCustomers
        self.maximumCustomers =  maximumCustomers
    }
}
// MARK: - DTOs -
extension Offer {
    
    /// Data structure used for the creation of offers in the database.
    struct Create: Content, Validatable {
        
        let idRestaurant: UUID
        let idState: UUID
        let title: String
        let image: String?
        let description: String
        let quantityOffered: Int
        let startHour: Date
        let endHour: Date
        let price: Int
        let idCurrency: UUID
        let minimumCustomers: Int
        let maximumCustomers: Int
        
        /// Method that validates the data types of the parameters sent in the body of the request.
        /// - Parameter validations: Elements to validate.
        static func validations(_ validations: inout Vapor.Validations) {
            
            validations.add("idRestaurant", as: UUID.self, required: true)
            validations.add("idState", as: UUID.self, required: true)
            validations.add("title", as: String.self, required: true)
            validations.add("image", as: String.self, is: !.empty, required: true)
            validations.add("description", as: String.self, required: true)
            validations.add("quantityOffered", as: Int.self, required: true)
            validations.add("startHour", as: Date.self, required: true)
            validations.add("endHour", as: Date.self, required: true)
            validations.add("price", as: Int.self, required: true)
            validations.add("idCurrency", as: UUID.self, required: true)
            validations.add("minimumCustomers", as: Int.self, required: true)
            validations.add("maximumCustomers", as: Int.self, required: true)
        }
    }
    
    /// Data structure used to generate the object that will be sent to the FrontEnd.
    struct Public: Content {
        
        let id: UUID
        let idRestaurant: UUID
        let title: String
        let image: String?
        let description: String
        let quantityOffered: Int
        let createdDate: Date?
        let startHour: Date?
        let endHour: Date?
        let price: Int
        let idCurrency: UUID
        let minimumCustomers: Int
        let maximumCustomers: Int
    }
}
