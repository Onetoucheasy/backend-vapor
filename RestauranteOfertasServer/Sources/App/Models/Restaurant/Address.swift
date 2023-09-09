//
//  File.swift
//  
//
//  Created by Alberto Junquera Ramírez on 2/9/23.
//

import Vapor
import Fluent

/// The Address model represents an Address in the database context.
final class Address: Model{
    
    /// Scheme
    static var schema = "addresses"
    
    //MARK: - Properties
    
    /// Address identifier. PK.
    @ID(key: .id)
    var id: UUID?
    
    /// The id of the restaurant related to the address. Represents an optional relationship to the address associated with a restaurant.
    @OptionalChild(for: \Restaurant.$address)
    var restaurant: Restaurant?
    
    /// Country.
    @Field(key: "country")
    var country: String
    
    /// State.
    @Field(key: "state")
    var state: String
    
    /// City.
    @Field(key: "city")
    var city: String
    
    /// Zip Code is a String because even thou zip codes are numbers, zip codes do not follow the logic and mathematical rules expected for numbers.
    @Field(key: "zip_code")
    var zipCode: String
    
    /// Address.
    @Field(key: "address")
    var address: String //TODO: Change to a bigger data type?
    
    //MARK: - Inits -
    
    /// Empty initializer.
    init() {}
    
    /// Parameterized initializer.
    init(id: UUID? = nil, restaurant: Restaurant? = nil ,country: String, state: String, city: String, zipCode: String, address: String) {
        self.id = id
        self.country = country
        self.state = state
        self.city = city
        self.zipCode = zipCode
        self.address = address
    }
}
