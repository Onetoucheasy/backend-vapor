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
        let user0 = User(name: "Maria", email: "maria@prueba.com", password: try Bcrypt.hash("password0"), userType: UserType.company)

        let user1 = User(name: "Jose", email: "jose@prueba.com", password: try Bcrypt.hash("password1"), userType: UserType.company)

        let user2 = User(name: "Rafael", email: "rafael@prueba.com", password: try Bcrypt.hash("password2"), userType: UserType.company)
        
        //Customer Users
        let user3 = User(name: "Mario", email: "mario@prueba.com", password: try Bcrypt.hash("password3"), userType: UserType.customer)
        
        let user4 = User(name: "Elena", email: "elena@prueba.com", password: try Bcrypt.hash("password4"), userType: UserType.customer)
        
        let user5 = User(name: "Rafael", email: "rafael@prueba.com", password: try Bcrypt.hash("password5"), userType: UserType.customer)
        
        //Add to the database
        try await [user0, user1, user2, user3, user4, user5].create(on: database)
        
        // Load restaurants (need access tokens
        
        /* 
         Manual steps using RapidApi & TablePlus
         1. Run user script
         2. Using RapidApi, sign in using user0: Header: HTTP Basic Auth email & password
         3. From Sign In JSON response, "Copy as Response Body Dynamic Value" from "accessToken"
         4. PASTE into Header > Authorization "Bearer <paste Response Body Dynamic Value>"
         5. TablePlus > "users" table > "Maria" record > copy "id" UUID value
         6. PASTE into: RapidAPI > "Create Restaurant" request > Body > "idCompany"
         7. Run requests > 200 OK
      */
        let coordinates1: Coordinates = try Coordinates(latitude: 40.3, longitude: -3.4)
        let coordinates2: Coordinates = try Coordinates(latitude: 40.2, longitude: -3.3)
        let coordinates3: Coordinates = try Coordinates(latitude: 40.0, longitude: -3.1)
        let coordinates4: Coordinates = try Coordinates(latitude: 40.2, longitude: -3.6)
        let coordinates5: Coordinates = try Coordinates(latitude: 40.0, longitude: -3.0)
        
        try await [coordinates1, coordinates2, coordinates3, coordinates4, coordinates5].create(on: database)
        
        
        let restaurant0 = try Restaurant(
            idCompany: user0.id!,
            name: "Shushi Bar",
            type: "Japonés",
            idAddress: UUID(uuidString: "2a714742-c546-4cba-898e-7068353eb384")!,
            coordinates: coordinates1,
            idSchedule: UUID(uuidString: "2a714742-c546-4cba-898e-7068353eb381")!
        )
        
        
        let restaurant1 = try Restaurant(
            idCompany: user0.id!,
            name: "Mao Sushi",
            type: "Japonés",
            idAddress: UUID(uuidString: "2a714742-c546-4cba-898e-7068353eb383")!,
            coordinates: coordinates2,
            idSchedule: UUID(uuidString: "2a714742-c546-4cba-898e-7068353eb380")!
        )
        
        let restaurant2 = try Restaurant(
            idCompany: user0.id!,
            name: "El Paraíso",
            type: "Chino",
            idAddress: UUID(uuidString: "2a714742-c546-4cba-898e-7068353eb373")!,
            coordinates: coordinates3,
            idSchedule: UUID(uuidString: "2a714742-c546-4cba-898e-7068353eb370")!
        )
        
        
        let restaurant3 = try Restaurant(
            idCompany: user1.id!,
            name: "Pizza Napoli",
            type: "Pizzeria",
            idAddress: UUID(uuidString: "2a714742-c546-4cba-898e-7068353eb323")!,
            coordinates: coordinates4,
            idSchedule: UUID(uuidString: "2a714742-c546-4cba-898e-7068353eb320")!
        )
        
        let restaurant4 = try Restaurant(
            idCompany: user1.id!,
            name: "Il Quattro",
            type: "Italiano",
            idAddress: UUID(uuidString: "2a714742-c546-4cba-898e-7068353eb326")!,
            coordinates: coordinates5,
            idSchedule: UUID(uuidString: "2a714742-c546-4cba-898e-7068353eb321")!
        )
        
        
        try await [restaurant0, restaurant1, restaurant2, restaurant3, restaurant4].create(on: database)
        
        
         /*
          Thread 1: Fatal error: Error raised at top level: PSQLError(
          code: server,
          serverInfo: [
              sqlState: 23503, detail: Key (id_company)=(2a714742-c546-4cba-898e-7068353eb386) is not present in table "users".,
              file: ri_triggers.c, line: 2607,
              message: insert or update on table "restaurants" violates foreign key constraint "restaurants_id_company_fkey",
              routine: ri_ReportViolation,
              localizedSeverity: ERROR,
              severity: ERROR,
              constraintName: restaurants_id_company_fkey,
              schemaName: public,
              tableName: restaurants
          ],
          triggeredFro
          */
    }
    
    func revert(on database: Database) async throws{
        try await User.query(on: database).delete()
    }
    
}
