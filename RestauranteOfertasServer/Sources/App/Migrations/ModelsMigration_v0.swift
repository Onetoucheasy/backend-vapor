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
            .create() // L1, 3.27.25 creates DB...
        
    }
    
    func revert(on database: Database) async throws {
        
        
    }
    
}
