import Fluent
import Vapor

func routes(_ app: Application) throws {

    // L1, 2.31.54 delete the below
//    app.get { req async in
//        "It works!" // pega http://127.0.0.1:8080 en Safari y ves "It Works!"
//    }
//
//    app.get("hello") { req async -> String in
//        "Hello, world!"
//    }
    
//    try app.register(collection: VersioningController())
    
    try app.group("api") { builder in
        
//        try builder.group(APIKeyMiddleware()) { builder in // L1, 3.08.10, L2 0.16.00
            
            try builder.register(collection: VersioningController()) // L1, 2.32.00~ first run
//            try builder.register(collection: AuthController()) // L1
//            try builder.register(collection: NewsController())
//            try builder.register(collection: EpisodesController())
            
//        }
        
    }
}
