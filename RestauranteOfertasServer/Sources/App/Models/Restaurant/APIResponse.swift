//
//  File.swift
//  
//
//  Created by Marta Maquedano on 3/9/23.
//

import Vapor
import Fluent
import CoreLocation

//Struct to return all the restaurants with the nested values.
//TODO: Add pagination in the future.

struct APIResponse<T: Content>: Content{

    let items: Int
    let result: [T]
}
   

