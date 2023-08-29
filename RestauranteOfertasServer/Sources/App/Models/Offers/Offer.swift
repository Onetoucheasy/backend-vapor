//
//  File.swift
//  
//
//  Created by Camila Laura Lopez on 22/8/23.
//

import Vapor
import Fluent

final class Offer: Content, Model {
    
    //Scheme
    static var schema = "offers"
    
    //Properties
    @ID(key: .id) //PK
    var id: UUID?
    
    @Field(key: "id_restaurant") //FK
    var idRestaurant: UUID

    @Field(key: "id_state") //TODO FK
    var idState: UUID
    
    @Field(key: "title")
    var title: String
    
    @Timestamp(key: "created_date", on: .none, format: .iso8601)
    var createdDate: Date?
    
    @Timestamp(key: "start_hour", on: .none, format: .iso8601)
    var startHour: Date?
    
    @Timestamp(key: "end_hour", on: .none, format: .iso8601)
    var endHour: Date?
    
    @Field(key: "image")
    var image: String?
    
    @Field(key: "description")
    var description: String
    
    @Field(key: "quantity_offered")
    var quantityOffered: Int
    
    @Field(key: "price")
    var price: Int
    
    @Field(key: "id_currency") //TODO FK
    var idCurrency: UUID
    
    @Field(key: "minimum_customers")
    var minimumCustomers: Int
    
    @Field(key: "maximum_customers") 
    var maximumCustomers: Int
    
    // Inits
    init() { }
    
    internal init(id: UUID?, idRestaurant: UUID, idState: UUID , title: String, image: String, description: String, quantityOffered: Int, createdDate: Date?, startHour: Date, endHour: Date, price: Int, idCurrency: UUID,minimumCustomers: Int,maximumCustomers: Int) {
        self.id = id
        self.idRestaurant = idRestaurant
        self.idState = idState
        self.title = title
        self.createdDate = createdDate
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
    
    struct Public: Content {
        
        let id: UUID
        let idRestaurant: UUID
        let title: String
        let image: String
        let description: String
        let quantityOffered: Int
        let createdDate: Date
        let startHour: Date
        let endHour: Date
        let price: Int
        let idCurrency: UUID
        let minimumCustomers: Int
        let maximumCustomers: Int
    }
}

