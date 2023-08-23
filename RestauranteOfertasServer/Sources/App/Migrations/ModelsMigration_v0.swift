//
//  ModelsMigration_v0.swift
//  
//
//  Created by Eric Olsson on 7/30/23.
//
// L1, 3.23.30
import Vapor
import Fluent

struct ModelsMigration_v0: AsyncMigration {
    
    func prepare(on database: FluentKit.Database) async throws {
        
        try await database // L1, 3.24.40
            .schema(User.schema)
            .id()
            .field("created_at", .string)
            .field("name", .string, .required)
            .field("email", .string, .required)
            .field("password", .string, .required)
            .field("isCompany", .string,.required) //TODO: Change to Bool
            .create() // L1, 3.27.25 creates DB...
        
        try await database
            .schema(Restaurant.schema)
            .id()
            .field("id_company", .uuid, .required, .references(User.schema, .id)) //FK
            .field("created_at", .string)
            .field("name", .string, .required)
            .field("cif", .string) //Required?
            .field("type", .string, .required)
            .field("id_address", .string,.required) //FK
            .field("id_coordinates", .string,.required) //FK
            .field("id_schedule", .string,.required) //FK
            .create()
        
        try await database
            .schema(Offert.schema)
            .id()
            .field("id_restaurant", .uuid, .required, .references(Restaurant.schema, .id)) //FK
            .field("created_at", .string)
            .field("offertName", .string, .required)
            .field("description", .string)
            .field("image", .string)
            .field("startTime", .string)
            .field("endTime", .string)
            .field("postTime", .string)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(User.schema).delete()
        try await database.schema(Restaurant.schema).delete()
        try await database.schema(Offert.schema).delete()
    }
    
}
