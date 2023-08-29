//
//  File.swift
//  
//
//  Created by Alberto Junquera Ramírez on 7/8/23.
//

import Vapor
import Fluent

final class Restaurant: Content, Model {
     
    //Scheme
    static var schema = "restaurants"
    
    //Properties
    @ID(key: .id) //PK
    var id: UUID?
    
    @Field(key: "id_company") //FK
    var idCompany: UUID
    
    @Timestamp(key: "created_at", on: .create, format: .iso8601)
    var createdAt: Date?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "cif") //TODO: Are we going to request "cif"?
    var cif: String?
    
    @Field(key: "type") //FK?
    var type: String //TODO: String or Enum?
    
    @Field(key: "id_address") //FK
    var idAddress: UUID
    
    @Field(key: "id_coordinates") //FK
    var idCoordinates: UUID
    
    @Field(key: "id_schedule") //FK
    var idSchedule: UUID
    
    // Inits
    init() { }
    
    internal init(id: UUID? = nil, idCompany: UUID, createdAt: Date? = nil, name: String, cif: String? = nil, type: String, idAddress: UUID, idCoordinates: UUID, idSchedule: UUID) {
        self.id = id
        self.idCompany = idCompany
        self.createdAt = createdAt
        self.name = name
        self.cif = cif
        self.type = type
        self.idAddress = idAddress
        self.idCoordinates = idCoordinates
        self.idSchedule = idSchedule
    }
    
}

// MARK: - DTOs -
extension Restaurant {
    
    struct Create: Content, Validatable {
        let idCompany: UUID
        let name: String
        let cif: String?
        let type: String
        let idAddress: UUID
        let idCoordinates: UUID
        let idSchedule: UUID
        
        static func validations(_ validations: inout Vapor.Validations) {
            
            validations.add("idCompany", as: UUID.self, required: true)
            validations.add("name", as: String.self, is: !.empty, required: true)
            validations.add("cif", as: String.self, required: true)
            validations.add("type", as: String.self, is: !.empty, required: true)
            validations.add("idAddress", as: UUID.self, required: true)
            validations.add("idCoordinates", as: UUID.self, required: true)
            validations.add("idSchedule", as: UUID.self, required: true)
        }
        
    }
    
    struct Public: Content {
        
        let id: UUID
        let idCompany: UUID
        let name: String
        //let cif: String?
        let type: String
       //TODO: The next id should not be shown. Do the Query and return the real values as nested Objects. 
        let idAddress: UUID
        let idCoordinates: UUID
        let adSchedule: UUID
        
    }
    
}
