//
//  JWTToken.swift
//  
//
//  Created by Eric Olsson on 8/1/23.
//

import Vapor
import JWT

/// Enum that contains the posible JWT types.
enum JWTTokenType: String, Codable {
    case accesToken
    case refreshToken
}

///The JWTToken model represents a JWTToken in the database context.
struct JWTToken: Content, JWTPayload, Authenticatable {
    
    // MARK: - Properties
    
    var exp: ExpirationClaim
    var iss: IssuerClaim
    var sub: SubjectClaim
    var type: JWTTokenType
    var userType: String
    
    /// JWT verification.  It is used to interrogate a user's JWT.
    func verify(using signer: JWTKit.JWTSigner) throws {
        
        /// Expired.
        try exp.verifyNotExpired()
        
        /// Validate bundle id.
        guard iss.value == Environment.process.APP_BUNDLE_ID else {
            throw JWTError.claimVerificationFailure(name: "iss", reason: "Issuer is invalid")
        }
        
        /// Validate subject.
        guard let _ = UUID(sub.value) else {
            throw JWTError.claimVerificationFailure(name: "sub", reason: "Subject is invalid")
        }
        
        /// Validate JWT type.
        guard type == .accesToken || type == .refreshToken else {
            throw JWTError.claimVerificationFailure(name: "type", reason: "Type is invalid")
        }
        
        /// Validate JWT user type.
        guard userType == UserType.admin.rawValue ||
                userType == UserType.company.rawValue ||
                userType == UserType.customer.rawValue else {
            throw JWTError.claimVerificationFailure(name: "userType", reason: "Unknown user type")
        }
    }
}

// MARK: - DTOs
extension JWTToken {
    
    /// Data structure used to generate the object that will be sent to the FrontEnd.
    struct Public: Content {
        let accessToken: String
        let refreshToken: String
    }
}

// MARK: - Auxiliar
extension JWTToken {
    
    /// Method that generates the custom JWTs. The customization is based un userID and userType.
    /// - Parameters:
    ///   - userID: UUID related to the user.
    ///   - userType: User type. Which restrics some functionalities dependiend on its value.
    /// - Returns: The customized JWTs (accessToken and refreshToken).
    static func generateTokens(userID: UUID, userType: String) -> (accessToken: JWTToken, refreshToken: JWTToken) {
        
        let iss = Environment.process.APP_BUNDLE_ID!
        let sub = userID.uuidString
        let currentDate = Date()
        
        /// Acces token generation.
        var expDate = currentDate.addingTimeInterval(Constants.accessTokenLifeTime)
        let access = JWTToken(exp: .init(value: expDate), iss: .init(value: iss), sub: .init(value: sub), type: .accesToken, userType: userType)
        
        /// Refresh token generation.
        expDate = currentDate.addingTimeInterval(Constants.refreshTokenLifeTime)
        let refresh = JWTToken(exp: .init(value: expDate), iss: .init(value: iss), sub: .init(value: sub), type: .refreshToken, userType: userType)
        
        return (access, refresh)
    }
}
