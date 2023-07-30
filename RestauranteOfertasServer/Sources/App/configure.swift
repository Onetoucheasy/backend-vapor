import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor
// L1 1.23.00, L1 1.35.00
// configures your application
public func configure(_ app: Application) async throws {

    // Borrar todo abajo, L1, 1.44.50

    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

//    app.databases.use(.postgres(configuration: SQLPostgresConfiguration(
//        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
//        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
//        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
//        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
//        database: Environment.get("DATABASE_NAME") ?? "vapor_database",
//        tls: .prefer(try .init(configuration: .clientDefault)))
//    ), as: .psql)
//
//    app.migrations.add(CreateTodo())
    
    // L1, 1.47.00
    
    // Environment // L1, 1.45.40
    guard let dbURL = Environment.process.DATABASE_URL else { fatalError("DATABASE_URL not found") }
    print("dbURL: \(dbURL)\n")
    guard let _ = Environment.process.API_KEY else { fatalError("API_KEY not found") } // API_KEY
    guard let _ = Environment.process.APP_BUNDLE_ID else { fatalError("APP_BUNDLE_ID not found") } // APP_BUNDLE_ID
//    guard let jwtKey = Environment.process.JWT_KEY else { fatalError("JWT_KEY not found") }
    
    // Connect to DB // L1 1.51.30, https://docs.vapor.codes/fluent/overview/#postgresql
//    try app.databases.use(.postgres(url: dbURL), as: .psql)
    
    // L1, 1.53.15 Error handling: do.. try.. catch
    do {
        // Connect to DB // L1 1.51.30, https://docs.vapor.codes/fluent/overview/#postgresql
        try app.databases.use(.postgres(url: dbURL), as: .psql)
        print("dbURL connection successfull. dbURL: \(dbURL)\n")

    } catch {
        print("Error: \(error)")
        print("More detailed error info: \(error.localizedDescription)")
        //        print("DB connection error")
    }
    
    // Migrations // L1, 3.28.00
    app.migrations.add(ModelsMigration_v0())
    try await app.autoMigrate()
    
    // register routes
    try routes(app)
}
