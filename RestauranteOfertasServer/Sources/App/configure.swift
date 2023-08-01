import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor
import JWT
// L1 1.23.00, L1 1.35.00
// configures your application
public func configure(_ app: Application) async throws { // L1, 1.47.00
   
    // Environment // L1, 1.45.40
    guard let dbURL = Environment.process.DATABASE_URL else { fatalError("DATABASE_URL not found") }
    guard let _ = Environment.process.API_KEY else { fatalError("API_KEY not found") } // API_KEY
    guard let _ = Environment.process.APP_BUNDLE_ID else { fatalError("APP_BUNDLE_ID not found") } // APP_BUNDLE_ID
    guard let jwtKey = Environment.process.JWT_KEY else { fatalError("JWT_KEY not found") }
    
    // Configure JWT  // L2, 0.54.20 // https://jwt.io // https://docs.vapor.codes/security/jwt/#getting-started
    app.jwt.signers.use(.hs256(key: jwtKey))
    
    // Configure passwords hash type // L2, 0.41.15
    app.passwords.use(.bcrypt)
    
    // L1, 1.53.15 Error handling: do.. try.. catch
    do {
        // Connect to DB // L1 1.51.30, https://docs.vapor.codes/fluent/overview/#postgresql
        try app.databases.use(.postgres(url: dbURL), as: .psql)
//        print("dbURL connection successfull. dbURL: \(dbURL)\n")

    } catch {
        print("Error: \(error)")
        print("More detailed error info: \(error.localizedDescription)")
    }
    
    // Migrations // L1, 3.28.00
    app.migrations.add(ModelsMigration_v0())
    try await app.autoMigrate()
    
    // register routes
    try routes(app)
}
