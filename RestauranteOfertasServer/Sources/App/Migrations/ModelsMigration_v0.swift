//
//  ModelsMigration_v0.swift
//  
//
//  Created by Eric Olsson on 7/30/23.
//
import Vapor
import Fluent

/// ModelsMigrations_v0 prepare all the enums and structs needed to generate the database.
struct ModelsMigration_v0: AsyncMigration {
    
    /// Method that contains the creation of the database tables if this migration hasn't been loaded before.
    /// - Parameter database: The database.
    func prepare(on database: FluentKit.Database) async throws {
       
        ///Important note: I hadn't been able to remove enum data typres using queries like the one above. In order to run this migration, enums shoud be removed too from the database. Steps:
        /// - 1: Locate the enum type name with SELECT * FROM pg_enum; or the OID with SELECT * FROM pg_type;
        /// - 2: Run DROP TYPE IF EXISTS "custom_enum_name";
        /// - 3: In this case, is "user_type"
        
        ///Enum: "user_type" enum need for the user table field "type".
        try await database
            .enum("user_type")
            .case("admin")
            .case("company")
            .case("customer")
            .create()
        
        ///The enum has to be retrieved from the PostgreSQL data types table before using it.
        let userType = try await database.enum("user_type").read()
        
        ///User table migration.
        try await database
            .schema(User.schema)
            .id()
            .field("created_at", .string)
            .field("name", .string, .required)
            .field("email", .string, .required)
            .field("password", .string, .required)
            .field("type", userType,.required)
            .create()
        
        ///Coordinates table migration.
        try await database
               .schema(Coordinates.schema)
               .id()
               .field("latitude", .double, .required )
               .field("longitude", .double, .required )
               .create()
        
        ///Addresses table migration.
        try await database
            .schema(Address.schema)
            .id()
            .field("country", .string, .required)
            .field("state", .string, .required)
            .field("city", .string, .required)
            .field("zip_code", .string, .required)
            .field("address", .string, .required)
            .create()
            
        ///Restaurant table migration.
        try await database
            .schema(Restaurant.schema)
            .id()
            .field("id_company", .uuid, .required, .references(User.schema, .id)) //FK
            .field("created_at", .string)
            .field("name", .string, .required)
            .field("picture", .string, .required)
            .field("cif", .string)
            .field("type", .string, .required)
            .field("id_address", .uuid,.references(Address.schema, "id")) //FK //One to one
            .field("id_coordinates", .uuid, .references(Coordinates.schema, "id")) //FK //One to many
            //.field("id_schedule", .string,.required) //FK
            .field("opening_hour", .string)
            .field("closing_hour", .string)
            .create()
        
        ///Offer table migration.
        try await database
            .schema(Offer.schema)
            .id()
            .field("id_restaurant", .uuid, .required, .references(Restaurant.schema, "id")) //FK
            .field("id_state", .uuid)
            .field("title", .string, .required)
            .field("created_date", .string)
            .field("start_hour", .string, .required)
            .field("end_hour", .string,.required)
            .field("image", .string, .required) //FK
            .field("description", .string)
            .field("quantity_offered", .int)
            .field("price", .int, .required)
            .field("id_currency", .uuid) //FK TODO
            .field("minimum_customers", .int)
            .field("maximum_customers", .int)
            .create()
    }
    
    /// Method that undoes the migration tables in case of an error.
    /// - Parameter database: The database.
    func revert(on database: Database) async throws {
        try await database.enum("user_type").delete()
        try await database.schema(User.schema).delete()
        try await database.schema(Coordinates.schema).delete()
        try await database.schema(Address.schema).delete()
        try await database.schema(Restaurant.schema).delete()
        try await database.schema(Offer.schema).delete()
    }
}
