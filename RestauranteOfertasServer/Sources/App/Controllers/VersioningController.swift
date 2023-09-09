//
//  VersioningController.swift
//  
//
//  Created by Eric Olsson on 7/30/23.
//
import Vapor
/// VersioningController is a struct with the EndPoints related with the versioning. Each methods function as an EndPoint. The "boot" method, defines how each EndPoint should be called.
struct VersioningController: RouteCollection {
    
    // MARK: - Override
    /// The boot method is part of the RouteCollection protocol. This method sets how the EndPoint should be invoked.
    /// - Parameter routes: Is a RouteBuilder, which registers all of the routes in the group to this router.
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.get("version", use: needsUpdate)
    }
    
    // MARK: - Routes
    /// Method that evaluates if the Front End apps need an updated version.
    /// - Parameter req: The request parameters.
    /// - Returns: A Version object.
    func needsUpdate(req: Request) async throws -> Version { // L1, 2.41.00
        
        guard let currentVersion: String = req.query["current"] else {
            throw Abort(.badRequest)
        }
        
        let appStoreLiveVersion = "1.2.0"
        let needsUpdate = currentVersion < appStoreLiveVersion
        
        return Version(current: currentVersion, live: appStoreLiveVersion, needsUpdate: needsUpdate)
    }
}
