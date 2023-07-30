//
//  User.swift
//  
//
//  Created by Eric Olsson on 7/28/23.
//

import Vapor
import Fluent
// L1, 3.14.00~ https://docs.vapor.codes/fluent/model/#models
final class User: Model {
    
    // Scheme
    static var schema = "users"
    
    // Properties
    @ID(key: .id)
    var id: UUID? // pq optional? respuesta: L1, 3.17.30
    
    @Timestamp(key: "created_at", on: .create, format: .iso8601) // https://docs.vapor.codes/fluent/model/#timestamp
    var createdAt: Date?
    
    @Field(key: "name") // https://docs.vapor.codes/fluent/model/#field
    var name: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password")
    var password: String
    
    // Inits
    init() { } // L1, 3.21.40
    
    init(id: UUID? = nil, name: String, email: String, password: String) {
        self.id = id
        self.name = name
        self.email = email
        self.password = password
    }
    
}

// MARK: - DTOs
extension User {
    
    struct Create: Content { // L2, 0.29.30
        
        let name: String
        let email: String
        let password: String
        
    }
    
    struct Public: Content {
        
        let id: String
        let name: String
        let email: String
        
    }
    
}
