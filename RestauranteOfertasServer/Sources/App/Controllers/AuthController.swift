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
            
            builder.group(User.authenticator(), User.guardMiddleware()) { builder in // L2, 1.44.45
                
                builder.get("signIn", use: signIn)
                
            }
            
            builder.group(JWTToken.authenticator(), JWTToken.guardMiddleware()) { builder in // L2, 2.14.05
                
                builder.get("refresh", use: refresh)
            }
        }
    }
    
    // MARK: - Routes
    func signUp(req: Request) async throws -> JWTToken.Public { // L1, 3.42.00, L2, 1.23.00
        
        // Validate // L2, 0.34.15, build
        try User.Create.validate(content: req)
        
        // Decode
        let userCreate = try req.content.decode(User.Create.self)
        let passwordHashed = try req.password.hash(userCreate.password) // L2, 0.42.00
        
        //
        var decodedUserType: UserType = .customer
        
        switch userCreate.type{
            //TODO: The next comentted code will allow creating admin users from Client Side, I think is dangerous and that is better to just give admin powers through PostgreSQL
            //case UserTypeEnum.admin.rawValue:
            // decodedUserType = .admin
        case UserType.company.rawValue:
            decodedUserType = .company
        default:
            decodedUserType = .customer
        }
        
        // Save user // L1, 3.45.10
        let user = User(name: userCreate.name, email: userCreate.email, password: passwordHashed, userType: decodedUserType) // L2, 0.42.00
        
        try await user.create(on: req.db)
        
        // Tokens // L2, 1.24.00
        let tokens = JWTToken.generateTokens(userID: user.id!, userType: decodedUserType.rawValue)
        let accessSigned = try req.jwt.sign(tokens.accessToken) // L2, 1.25.10
        let refreshSigned = try req.jwt.sign(tokens.refreshToken)
        
        return JWTToken.Public(accessToken: accessSigned, refreshToken: refreshSigned)
    }
    
    func signIn(req: Request) async throws -> JWTToken.Public { // L2, 1.30.30
        // https://docs.vapor.codes/security/authentication/#authentication
        // Get authenticated user
        let user = try req.auth.require(User.self)
        
        // Tokens // L2, 1.37.45
        let tokens = JWTToken.generateTokens(userID: user.id!, userType: user.userType.rawValue)
        let accessSigned = try req.jwt.sign(tokens.accessToken)
        let refreshSigned = try req.jwt.sign(tokens.refreshToken)
        
        return JWTToken.Public(accessToken: accessSigned, refreshToken: refreshSigned)
    }
    
    func refresh(req: Request) async throws -> JWTToken.Public { // L2, 2.08.00
        
        // Get refresh token // L2, 2.09.40
        let token = try req.auth.require(JWTToken.self)
        
        // Verify JWT type
        guard token.type == .refreshToken else {
            throw Abort(.methodNotAllowed)
        }
        
        // Get user ID
        guard let user = try await User.find(UUID(token.sub.value), on: req.db) else {
            throw Abort(.unauthorized)
        }
        
        // Tokens
        let tokens = JWTToken.generateTokens(userID: user.id!, userType: user.userType.rawValue)
        let accessSigned = try req.jwt.sign(tokens.accessToken)
        let refreshSigned = try req.jwt.sign(tokens.refreshToken)
        
        return JWTToken.Public(accessToken: accessSigned, refreshToken: refreshSigned)
    }
}
