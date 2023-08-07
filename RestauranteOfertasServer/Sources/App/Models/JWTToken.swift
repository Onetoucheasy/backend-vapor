//
//  JWTToken.swift
//  
//
//  Created by Eric Olsson on 8/1/23.
//

import Vapor
import JWT
// L2, 0.59.00
enum JWTTokenType: String, Codable {
    case accesToken
    case refreshToken
}
// L2, 1.00.00 // https://docs.vapor.codes/security/jwt/#jwt
struct JWTToken: Content, JWTPayload, Authenticatable { // L2, 2.08.42 - Authenticatable
    
    // MARK: - Properties
    var exp: ExpirationClaim // https://datatracker.ietf.org/doc/rfc7519/
    var iss: IssuerClaim
    var sub: SubjectClaim
    var type: JWTTokenType
    var isCompany: String //TODO: Change to Bool
    
    // JWT verification // This is used to interrogate a user's JWT
    func verify(using signer: JWTKit.JWTSigner) throws {
        
        // Expired
        try exp.verifyNotExpired()
        
        // Validate bundle id // L2, 1.11.00
        guard iss.value == Environment.process.APP_BUNDLE_ID else {
            throw JWTError.claimVerificationFailure(name: "iss", reason: "Issuer is invalid")
        }
        
        // Validate subject
        guard let _ = UUID(sub.value) else {
            throw JWTError.claimVerificationFailure(name: "sub", reason: "Subject is invalid")
        }
        
        // Validate JWT type // L2, 1.13.30
        guard type == .accesToken || type == .refreshToken else {
            throw JWTError.claimVerificationFailure(name: "type", reason: "Type is invalid")
        }
        //Validate JWT audience //TODO: Change to Bool
        guard isCompany == "true" || isCompany == "false" else {
            throw JWTError.claimVerificationFailure(name: "aud", reason: "Aud is invalid")
        }
        
    }
    
}

// MARK: - DTOs
extension JWTToken { // L2, 1.15.10
    
    struct Public: Content {
        
        let accessToken: String
        let refreshToken: String
        
    }
    
}

// MARK: - Auxiliar
extension JWTToken { // L2, 1.16.20
    
    static func generateTokens(userID: UUID, isCompany: String) -> (accessToken: JWTToken, refreshToken: JWTToken) {
     
        let iss = Environment.process.APP_BUNDLE_ID!
        let sub = userID.uuidString
        let currentDate = Date()
      //  let isCompany: String //TODO: probably not necesary in here, as we donot modify the value
        
        // Acces token
        var expDate = currentDate.addingTimeInterval(Constants.accessTokenLifetime)
        let access = JWTToken(exp: .init(value: expDate), iss: .init(value: iss), sub: .init(value: sub), type: .accesToken, isCompany: isCompany)
        
        // Refresh token
        expDate = currentDate.addingTimeInterval(Constants.refreshTokenLifeTime)
        let refresh = JWTToken(exp: .init(value: expDate), iss: .init(value: iss), sub: .init(value: sub), type: .refreshToken, isCompany: isCompany)
        
        return (access, refresh)
        
    }
    
}
