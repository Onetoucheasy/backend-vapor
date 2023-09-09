//
//  Version.swift
//  
//
//  Created by Eric Olsson on 7/30/23.
//

import Vapor

///The Version model represents an Version in the database context.
struct Version: Content {
    let current: String
    let live: String
    let needsUpdate: Bool
}
