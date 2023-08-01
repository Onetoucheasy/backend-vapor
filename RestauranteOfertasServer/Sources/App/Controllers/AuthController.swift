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
    
    // MARK: - Routes
    func signUp(req: Request) async throws -> User.Public { // L1, 3.42.00, L2, 1.23.00
        
        // Validate // L2, 0.34.15, build
        try User.Create.validate(content: req)
        
        // Decode
        let userCreate = try req.content.decode(User.Create.self)
        let passwordHashed = try req.password.hash(userCreate.password) // L2, 0.42.00
        
        // Save user // L1, 3.45.10
        let user = User(name: userCreate.name, email: userCreate.email, password: passwordHashed) // L2, 0.42.00
        try await user.create(on: req.db)
        
        return User.Public(id: user.id?.uuidString ?? "", name: user.name, email: user.email)
        
    }
    
}
