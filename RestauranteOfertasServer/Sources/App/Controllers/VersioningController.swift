//
//  VersioningController.swift
//  
//
//  Created by Eric Olsson on 7/30/23.
//
// L1, 2.24.00~
import Vapor

struct VersioningController: RouteCollection {
    
    // MARK: - Override
    // L1, 2.26.00~
    func boot(routes: Vapor.RoutesBuilder) throws {
        
        routes.get("version", use: needsUpdate) // docs: https://docs.vapor.codes/basics/routing/#router-methods
        
    }

    // TODO: ⚠️ Añadir ¨SplashView¨ como CloudDragon para comprobar la versión
    
    // MARK: - Routes
    func needsUpdate(req: Request) async throws -> Version { // L1, 2.41.00

        guard let currentVersion: String = req.query["current"] else { // L1, 2.41.00~, https://docs.vapor.codes/fluent/model/#query
            throw Abort(.badRequest) // L1, 2.44.00
        }

        let appStoreLiveVersion = "1.2.0" // L1, 2.44.50 hardcoded for testing
        let needsUpdate = currentVersion < appStoreLiveVersion
        
        return Version(current: currentVersion, live: appStoreLiveVersion, needsUpdate: needsUpdate) // L1, 2.46.30
        // RapidAPI Test 2: Version https://docs.google.com/document/d/1P-a5OIAxO44VewPy_5ACdchxnvbDO0MSJi6rR6Y1tp8/edit#bookmark=kix.38612i361drk
    }
    
}
