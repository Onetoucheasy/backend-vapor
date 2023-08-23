//
//  Offert.swift
//  
//
//  Created by Eric Olsson on 8/17/23.
//

import Vapor
import Fluent

final class Offert: Content, Model {
     
    //Scheme
    static var schema = "offerts"
    
    //Properties
    @ID(key: .id) //PK for offer
    var id: UUID?
    
    @Field(key: "id_restaurant") // FK to match restaurant
    var idRestaurant: UUID
    
    @Timestamp(key: "created_at", on: .create, format: .iso8601)
    var createdAt: Date?
    
    @Field(key: "offertName")
    var offertName: String
    
    @Field(key: "description")
    var description: String?
    
    @Field(key: "image")
    var image: String?
    
    @Field(key: "startTime")
    var startTime: Date?
    
    @Field(key: "endTime")
    var endTime: Date?
    
    @Field(key: "postTime")
    var postTime: Date?
    
    // Inits
    init() { }
    
    internal init(
        id: UUID? = nil,
        idRestaurant: UUID,
        createdAt: Date? = nil,
        offertName: String,
        description: String? = nil,
        image: String,
        startTime: Date?,
        endTime: Date,
        postTime: Date
    )
    {
        self.id = id
        self.idRestaurant = idRestaurant
        self.createdAt = createdAt
        self.offertName = offertName
        self.description = description
        self.image = image
        self.startTime = startTime
        self.endTime = endTime
        self.postTime = postTime
    }
    
}

// MARK: - DTOs -
extension Offert {
    
    struct Create: Content, Validatable {
        let idRestaurant: UUID
        let createdAt: Date?
        let offertName: String
        let description: String?
        let image: String
        let startTime: Date?
        let endTime: Date
        let postTime: Date
        
        static func validations(_ validations: inout Vapor.Validations) {
            
            validations.add("idRestaurant", as: UUID.self, required: true)
            validations.add("offertName", as: String.self, is: !.empty, required: true)
        }
        
    }
    
    struct Public: Content {
        
        let id: UUID
        let idRestaurant: UUID
        let offertName: String
        let description: String?
        let image: String
        let startTime: Date?
        let endTime: Date
        let postTime: Date
        
    }
    
}
