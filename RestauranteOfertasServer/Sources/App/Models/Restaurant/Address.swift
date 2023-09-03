//
//  File.swift
//  
//
//  Created by Alberto Junquera Ramírez on 2/9/23.
//

import Vapor
import Fluent

final class Address: Model{
    
    //Scheme
    static var schema = "addresses"
    
    //Properties
    @ID(key: .id) //PK
    var id: UUID?
    
    @OptionalChild(for: \Restaurant.$address)
    var restaurant: Restaurant?
    
    @Field(key: "country")
    var country: String
    
    @Field(key: "state")
    var state: String
    
    @Field(key: "city")
    var city: String
    
    @Field(key: "zip_code")
    var zipCode: String
    
    @Field(key: "address")
    var address: String //TODO: Change to a bigger data type?
    
    //Mark: - Inits -
    
    init() {}
    
    init(id: UUID? = nil, restaurant: Restaurant? = nil ,country: String, state: String, city: String, zipCode: String, address: String) {
        self.id = id
        //self.restaurant = restaurant
        self.country = country
        self.state = state
        self.city = city
        self.zipCode = zipCode
        self.address = address
    }
    
    
    
}
