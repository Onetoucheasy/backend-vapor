//
//  File.swift
//  
//
//  Created by Eric Olsson on 7/28/23.
//

import Vapor
import Fluent
// L1, 3.34.40~
struct AuthController: RouteCollection {

    // MARK: - Override
    func boot(routes: Vapor.RoutesBuilder) throws {
        
        routes.group("auth") { builder in
            
            builder.post("signUp", use: signUp)
            
        }
        
    }
    
//    func signUp(req: Request) async throws -> String {
//        return "Test signup" // Test successful
//    }
    
    // MARK: - Routes
    func signUp(req: Request) async throws -> User.Public { // L1, 3.42.00
        
        // Decode
        let userCreate = try req.content.decode(User.Create.self)
        
        // Save user // L1, 3.45.10
        let user = User(name: userCreate.name, email: userCreate.email, password: userCreate.password)
        try await user.create(on: req.db)
        
        return User.Public(id: user.id?.uuidString ?? "", name: user.name, email: user.email)
        
    }
    
}
