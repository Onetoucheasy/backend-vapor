//
//  PasswordHashingTests.swift
//  
//
//  Created by Eric Olsson on 8/12/23.
//

import XCTest
import XCTVapor
import Fluent
//@testable import RestauranteOfertasServer

final class PasswordHashingTests: XCTestCase {
    var app: Application!

    override func setUpWithError() throws {
        app = Application(.testing)
//        try configure(app)
        try app.autoMigrate().wait()
    }

    override func tearDownWithError() throws {
        app.shutdown()
    }

    func testHashingFunctionality() throws {
        let password = "test_password"
        let hashedPassword = try Bcrypt.hash(password)

        XCTAssertFalse(password == hashedPassword, "Hashed password should not be the same as the plain password.")
        XCTAssertTrue(try Bcrypt.verify(password, created: hashedPassword), "Verification of hashed password failed.")
    }
}
