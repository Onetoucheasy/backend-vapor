import Fluent
import Vapor

func routes(_ app: Application) throws {
    
    try app.group("api") { builder in
        
        try builder.group(APIKeyMiddleware()) { builder in // L1, 3.08.10, L2 0.16.00. Traffic must pass through middleware
            
            try builder.register(collection: VersioningController()) // L1, 2.32.00~ first run
            try builder.register(collection: AuthController()) // L1, 3.38.30
            
        }
        
    }
}
