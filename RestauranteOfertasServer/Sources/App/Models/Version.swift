//
//  Version.swift
//  
//
//  Created by Eric Olsson on 7/30/23.
//

import Vapor
// L1 2.22.00~ Docs: https://docs.vapor.codes/basics/content/#content-struct
struct Version: Content {
    
    let current: String
    let live: String
    let needsUpdate: Bool
    
}
