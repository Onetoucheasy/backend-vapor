//
//  APIKeyMiddleware.swift
//  
//
//  Created by Eric Olsson on 7/31/23.
//
// L2, 0.07.10 https://docs.vapor.codes/advanced/middleware/#middleware
import Vapor

final class APIKeyMiddleware: AsyncMiddleware {
    
    func respond(to request: Vapor.Request, chainingTo next: Vapor.AsyncResponder) async throws -> Vapor.Response {
        
        guard let apiKey = request.headers.first(name: "CDS-ApiKey") else { // L2, 0.13.20
            throw Abort(.badRequest, reason: "CDS-APiKey header is missing")
        }

        print(apiKey) // Test print works
        guard let envApiKey = Environment.process.API_KEY else { // L2, 0.22.20
            throw Abort(.failedDependency)
        }

        guard apiKey == envApiKey else {
            throw Abort(.unauthorized, reason: "Invalid API Key")
        }
        
        return try await next.respond(to: request)
        
    }

}
