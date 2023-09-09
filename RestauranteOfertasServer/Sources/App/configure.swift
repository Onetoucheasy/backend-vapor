import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor
import JWT

/// Configures the application.
/// - Parameter app: The application.
/// - Throws: If the environment properties fail to be configured, this method fails and the database is not created.
public func configure(_ app: Application) async throws {
    
    /// Environment.
    guard let dbURL = Environment.process.DATABASE_URL else { fatalError("DATABASE_URL not found")}
    guard let _ = Environment.process.API_KEY else { fatalError("API_KEY not found")}
    guard let _ = Environment.process.APP_BUNDLE_ID else { fatalError("APP_BUNDLE_ID not found")}
    guard let jwtKey = Environment.process.JWT_KEY else { fatalError("JWT_KEY not found")}
    
    /// Configure JWT.
    app.jwt.signers.use(.hs256(key: jwtKey))
    
    /// Configure passwords hash type. By default, bcrypt is used to make the encoding of the passwords.
    app.passwords.use(.bcrypt)
    
    do {
        /// Connect to DB
        try app.databases.use(.postgres(url: dbURL), as: .psql)
    } catch {
        print("Error: \(error)")
        print("More detailed error info: \(error.localizedDescription)")
    }
    
    /// Migrations handling.
    app.migrations.add(ModelsMigration_v0())
    app.migrations.add(PopulateInitialData())
    try await app.autoMigrate()
    
    /// Routes registration.
    try routes(app)
}
