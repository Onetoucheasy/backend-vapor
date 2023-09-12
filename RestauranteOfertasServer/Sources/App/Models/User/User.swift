//
//  User.swift
//  
//
//  Created by Eric Olsson on 7/28/23.
//

import Vapor
import Fluent

/// Enum that contains the posible user types.
enum UserType: String, Codable{
    case admin = "admin"
    case company = "company"
    case customer = "customer"
}

/// The User model represents a user in the database context.
final class User: Model {
    
    /// Scheme
    static var schema = "users"
    
    //MARK: - Properties
    
    /// User identifier. PK.
    @ID(key: .id)
    var id: UUID?
    
    /// Timestamp that store the user creation complete date.
    @Timestamp(key: "created_at", on: .create, format: .iso8601)
    var createdAt: Date?
    
    /// User name.
    @Field(key: "name")
    var name: String
    
    /// User's email.
    @Field(key: "email")
    var email: String
    
    /// User's encrypted password.
    @Field(key: "password")
    var password: String
    
    /// User type. Determines the entry level to some functionalities.
    @Enum(key: "type")
    var userType: UserType
    
    //MARK: - Inits
    
    /// Empty initializer.
    init() { }
    
    /// Parameterized initializer.
    init(id: UUID? = nil, name: String, email: String, password: String, userType: UserType) {
        self.id = id
        self.name = name
        self.email = email
        self.password = password
        self.userType = userType
    }
}

// MARK: - DTOs
extension User {
    
    /// Data structure used for the creation of users in the database.
    struct Create: Content, Validatable {
        let name: String
        let email: String
        let password: String
        let type: String //TODO: Change to Bool
        
        // Method that validates the data types of the parameters sent in the body of the request.
        /// - Parameter validations: Elements to validate.
        static func validations(_ validations: inout Vapor.Validations) {
            validations.add("name", as: String.self, is: !.empty, required: true)
            validations.add("email", as: String.self, is: .email, required: true)
            validations.add("password", as: String.self, is: .count(6...), required: true)
            validations.add("type", as: String.self, required: true)
        }
    }
    
    /// Data structure used to generate the object that will be sent to the FrontEnd.
    struct Public: Content {
        let id: String
        let name: String
        let email: String
    }
}

// MARK: - Authenticable
extension User: ModelAuthenticatable {
    /// This extension implements the ModelAuthenticable protocol, which allows the user model to be authenticable, allowing to easily perform certain actions like the sign in authentication.
    static var usernameKey = \User.$email
    static var passwordHashKey = \User.$password
    
    /// Method that checks that the password is encrypted.
    /// - Parameter password: encrypted password.
    /// - Returns: A boolean if the condition is met.
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}
