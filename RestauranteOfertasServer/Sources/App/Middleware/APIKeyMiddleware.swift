//
//  APIKeyMiddleware.swift
//  
//
//  Created by Eric Olsson on 7/31/23.
//
import Vapor

/// Class that ensures that the request has a valid APIKey.
final class APIKeyMiddleware: AsyncMiddleware {
    
    func respond(to request: Vapor.Request, chainingTo next: Vapor.AsyncResponder) async throws -> Vapor.Response {
        
        guard let apiKey = request.headers.first(name: "CDS-ApiKey") else {
            throw Abort(.badRequest, reason: "CDS-APiKey header is missing")
        }

        guard let envApiKey = Environment.process.API_KEY else {
            throw Abort(.failedDependency)
        }

        guard apiKey == envApiKey else {
            throw Abort(.unauthorized, reason: "Invalid API Key")
        }
        
        return try await next.respond(to: request)
    }
}
