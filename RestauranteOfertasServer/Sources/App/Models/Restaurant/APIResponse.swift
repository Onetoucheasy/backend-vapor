//
//  File.swift
//  
//
//  Created by Marta Maquedano on 3/9/23.
//

import Vapor
import Fluent

//TODO: Add pagination in the future.

/// APIResponse is a generic model that represents how the data lists will be sent to the FrontEnd.
struct APIResponse<T: Content>: Content{
    let items: Int
    let result: [T]
}
