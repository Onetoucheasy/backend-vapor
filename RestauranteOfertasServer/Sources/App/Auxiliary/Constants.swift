//
//  Constants.swift
//  
//
//  Created by Eric Olsson on 7/28/23.
//

import Foundation

struct Constants {
    ///Constants that set the lifespan of the AccessToken and RefreshToken.
    /// - accessTokenLifeTime: 30 minutes.
    /// - refreshTokenLifeTime: 1 week.
    static let accessTokenLifeTime: Double = 60 * 30
    static let refreshTokenLifeTime: Double = 60 * 60 * 24 * 7
}
