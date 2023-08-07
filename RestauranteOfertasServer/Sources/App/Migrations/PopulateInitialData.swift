//
//  File.swift
//  
//
//  Created by Alberto Junquera Ramírez on 7/8/23.
//

import Vapor
import Fluent

struct PopulateInitialData: AsyncMigration{
    func prepare(on database: FluentKit.Database) async throws {
        //Hashed Password
        
        //Company Users
        
        //Custpmer Users
        
        //Add to the database
        
    }
    func revert(on database: Database) async throws{
        try await User.query(on: database).delete()
    }
    
}
