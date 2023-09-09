//
//  File.swift
//  
//
//  Created by Eric Olsson on 7/28/23.
//

import Vapor
import Fluent

/// AuthController is a struct with the EndPoints related with the Sign In, Sign Up and the JWT Tokens. Each methods function as an EndPoint. The "boot" method, defines how each EndPoint should be called.
struct AuthController: RouteCollection {
    
    // MARK: - Override
    
    /// The boot method is part of the RouteCollection protocol. This method sets how the EndPoint should be invoked.
    /// - Parameter routes: Is a RouteBuilder, which registers all of the routes in the group to this router.
    func boot(routes: Vapor.RoutesBuilder) throws {
        /// The authentication related EndPoints are declared under the authentication path "auth".
        routes.group("auth") { builder in
            
            /// "signUp": Performs the sign up.
            builder.post("signUp", use: signUp)
            
            /// "signIn": Performs the sign in authentication.
            builder.group(User.authenticator(), User.guardMiddleware()) { builder in
                builder.get("signIn", use: signIn)
            }
            ///"refresh": Refreshes the JWT Tokens.
            builder.group(JWTToken.authenticator(), JWTToken.guardMiddleware()) { builder in
                builder.get("refresh", use: refresh)
            }
        }
    }
    
    // MARK: - Routes
    
    /// This method performs the "Sign Up" of a user in the database taking into account the user type.
    /// - Parameter req: Has all the information needed for the request. In this case, the request has four elements body. Those are name, email, password and type (user type).
    /// - Returns: A JWT.Public object, which stores both, the accessToken and the refreshToken.
    func signUp(req: Request) async throws -> JWTToken.Public {
        
        ///Validation of the body parameters.
        try User.Create.validate(content: req)
        
        ///Decodification of the parameters sent with the request.
        let userCreate = try req.content.decode(User.Create.self)
        
        ///The password is hashed before storing it in the data base, using BCrypt.
        let passwordHashed = try req.password.hash(userCreate.password)
        
        /// The decoded user is passed through a switch case to ensure that this EndPoint does not create an Admin user.
        var decodedUserType: UserType = .customer
        
        switch userCreate.type{
        case UserType.company.rawValue:
            decodedUserType = .company
        default:
            decodedUserType = .customer
        }
        
        ///The manufactured body parameters are used to create the user object, which has the structure of the database.
        let user = User(name: userCreate.name, email: userCreate.email, password: passwordHashed, userType: decodedUserType)
        
        ///The user is stored in the database.
        try await user.create(on: req.db)
        
        ///The JWT Tokens are generated taking into account the user type.
        let tokens = JWTToken.generateTokens(userID: user.id!, userType: decodedUserType.rawValue)
        let accessSigned = try req.jwt.sign(tokens.accessToken) // L2, 1.25.10
        let refreshSigned = try req.jwt.sign(tokens.refreshToken)
        
        return JWTToken.Public(accessToken: accessSigned, refreshToken: refreshSigned)
    }
    
    /// This method perform the authentication. If the user is successfully authenticated, the method return the access and refresh JWT Tokens.
    /// - Parameter req: Has the information needed to perfom the authentication.
    /// - Returns: A JWTToken.Public that contains both, the access and refresh token with the user type in the payload.
    func signIn(req: Request) async throws -> JWTToken.Public {
        
        ///The user data are retrieved and used to performing the authentication.
        let user = try req.auth.require(User.self)
        
        ///If the authentication was a success, the JWT tokens are generated.
        let tokens = JWTToken.generateTokens(userID: user.id!, userType: user.userType.rawValue)
        let accessSigned = try req.jwt.sign(tokens.accessToken)
        let refreshSigned = try req.jwt.sign(tokens.refreshToken)
        
        return JWTToken.Public(accessToken: accessSigned, refreshToken: refreshSigned)
    }
    
    /// This method refreshes the user JWT Tokens.
    /// - Parameter req: The request contains the current refresh token.
    /// - Returns: A new object JWTToken.Public that contains both, the new accesToken and the new refreshToken.
    func refresh(req: Request) async throws -> JWTToken.Public {
        
        ///The refresh token is retrived.
        let token = try req.auth.require(JWTToken.self)
        
        ///Verification of the JWT Token type.
        guard token.type == .refreshToken else {
            throw Abort(.methodNotAllowed)
        }
        
        ///Retrieving user id from the database.
        guard let user = try await User.find(UUID(token.sub.value), on: req.db) else {
            throw Abort(.unauthorized)
        }
        
        ///If all of the above code was a success, the JWT Token are generated.
        let tokens = JWTToken.generateTokens(userID: user.id!, userType: user.userType.rawValue)
        let accessSigned = try req.jwt.sign(tokens.accessToken)
        let refreshSigned = try req.jwt.sign(tokens.refreshToken)
        
        return JWTToken.Public(accessToken: accessSigned, refreshToken: refreshSigned)
    }
}
