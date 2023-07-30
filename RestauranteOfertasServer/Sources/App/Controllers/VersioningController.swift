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
    /* Partes sincillas
     
     //    func needsUpdate(req: Request) async throws -> String { // L1, 2.25.00
     //        "Test String" // // pega http://127.0.0.1:8080/version en Safari y ves "Test String" ✅
     //    }
         
     //    func needsUpdate(req: Request) async throws -> Version { // L1, 2.33.00~
     //
     //        let test = Version(current: "1.0", live: "1.1", needsUpdate: true)
     //        return test
     //        // pega http://127.0.0.1:8080/version en Safari y ves "{"current":"1.0","needsUpdate":true,"live":"1.1"}" ✅
     //        // RapidAPI Test 1: Version https://docs.google.com/document/d/1P-a5OIAxO44VewPy_5ACdchxnvbDO0MSJi6rR6Y1tp8/edit#bookmark=id.3ied13kmlgo3
     //    }
     
     */

    // TODO: ⚠️ Añadir ¨SplashView¨ como CloudDragon para comprobar la versión
    
    // MARK: - Routes
    // L1, 2.41.00
    func needsUpdate(req: Request) async throws -> Version {

        guard let currentVersion: String = req.query["current"] else { // L1, 2.41.00~, https://docs.vapor.codes/fluent/model/#query
            throw Abort(.badRequest) // L1, 2.44.00, this is a much simpler line than is available, jump to .badrequest def to see all options
        }

        let appStoreLiveVersion = "1.2.0" // L1, 2.44.50 hardcoded for testing
        let needsUpdate = currentVersion < appStoreLiveVersion

        return Version(current: currentVersion, live: appStoreLiveVersion, needsUpdate: needsUpdate) // L1, 2.46.30
        // RapidAPI Test 2: Version https://docs.google.com/document/d/1P-a5OIAxO44VewPy_5ACdchxnvbDO0MSJi6rR6Y1tp8/edit#bookmark=kix.38612i361drk
    }
    
}
