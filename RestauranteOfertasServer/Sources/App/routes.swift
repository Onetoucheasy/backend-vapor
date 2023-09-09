import Fluent
import Vapor

func routes(_ app: Application) throws {
    
    try app.group("api") { builder in
        
        ///Traffic must pass through middleware
        try builder.group(APIKeyMiddleware()) { builder in
            
            /// Registration of the versioning controller.
            try builder.register(collection: VersioningController())
            
            /// Registration of the authentication controller.
            try builder.register(collection: AuthController())
            
            /// Registration of the restaurants controller.
            try builder.register(collection: RestaurantController())
            
            /// Registration of the offers controller.
            try builder.register(collection: OfferController())
        }
    }
}
