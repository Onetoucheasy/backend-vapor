//
//  File.swift
//  
//
//  Created by Alberto Junquera Ramírez on 7/8/23.
//

import Vapor
import Fluent
import CoreLocation //TODO: Delete? Keep coordiantes as double?

final class Coordinates: Model{
  
    //Scheme
    static var schema = "coordinates"
    
    //Properties
    @ID(key: .id) //PK
    var id: UUID?
    
    //@Parent(key: "id_restaurant") //PK & FK
    @Children(for: \Restaurant.$coordinates) //PK & FK
    var restaurant: [Restaurant]
    
    @Field(key: "latitude")
    //var latitude: CLLocationDegrees
    var latitude: Double
   // var latitude: String
    
    @Field(key: "longitude")
//    var longitude: CLLocationDegrees
    var longitude: Double
//    var longitude: String
    
    //Inits:
    init(){}
    
   // internal init(id: UUID? = nil, idRestaurant: Restaurant, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
    init(id: UUID? = nil, latitude: Double, longitude: Double) throws {
   // internal init(id: UUID? = nil, restaurant: Restaurant, latitude: String, longitude: String) throws{
        self.id = id
//        self.$restaurant.id = try restaurant.requireID() //idRestaurant.id!//(idRestaurant?.id!)!
       // self.$restaurant. = restaurant.id ?? UUID(uuidString: "ok55qweq4eqe")!
        //TODO: I think that the initializer should not have 
        self.latitude = latitude
        self.longitude = longitude
    }
}

 //MARK: - DTOs -

extension Coordinates{
    
    struct Create: Content, Validatable {
        //let idRestaurant: UUID
//        let latitude: CLLocationDegrees
//        let longitude: CLLocationDegrees
//        let latitude: Double
//        let longitude: Double
        
        let latitude: String
        let longitude: String
        
        static func validations(_ validations: inout Vapor.Validations) {
            //validations.add("idRestaurant", as: UUID.self, required: true)
//            validations.add("latitude", as: Double.self, required: true)
//            validations.add("longitude", as: Double.self, required: true)
            
            validations.add("latitude", as: String.self, required: true)
            validations.add("longitude", as: String.self, required: true)

        }
    }
    
    struct Public {
        let id: UUID
        let idRestaurant: UUID
//        let latitude: CLLocationDegrees
//        let longitude: CLLocationDegrees
//        let latitude: Double
//        let longitude: Double
        let latitude: String
        let longitude: String
    }
}
