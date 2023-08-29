//
//  File.swift
//  
//
//  Created by Alberto Junquera Ramírez on 7/8/23.
//

import Vapor
import Fluent
import CoreLocation

final class Coordinates: Model{
  
    //Scheme
    static var schema = "coordinates"
    
    //Properties
    @ID(key: .id) //PK
    var id: UUID?
    
    @Field(key: "id_restaurant") //PK & FK
    var idRestaurant: UUID
    
    @Field(key: "latitude")
    var latitude: CLLocationDegrees
    
    @Field(key: "longitude")
    var longitude: CLLocationDegrees
    
    //Inits:
    init(){}
    
    internal init(id: UUID? = nil, idRestaurant: UUID, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.id = id
        self.idRestaurant = idRestaurant
        self.latitude = latitude
        self.longitude = longitude
    }
}

 //MARK: - DTOs -

extension Coordinates{
    
    struct Create: Content, Validatable {
        let idRestaurant: UUID
        let latitude: CLLocationDegrees
        let longitude: CLLocationDegrees
        
        static func validations(_ validations: inout Vapor.Validations) {
            validations.add("idRestaurant", as: UUID.self, required: true)
            validations.add("latitude", as: CLLocationDegrees.self, required: true)
            validations.add("longitude", as: CLLocationDegrees.self, required: true)

        }
    }
    
    struct Public {
        let id: UUID
        let idRestaurant: UUID
        let latitude: CLLocationDegrees
        let longitude: CLLocationDegrees
    }
}
