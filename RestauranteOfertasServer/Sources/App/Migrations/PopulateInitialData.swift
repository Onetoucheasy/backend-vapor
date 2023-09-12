//
//  File.swift
//  
//
//  Created by Alberto Junquera Ramírez on 7/8/23.
//

import Vapor
import Fluent

/// Struct that provides the methods to preload the database tables with data.
struct PopulateInitialData: AsyncMigration{
   
    
    /// Method called after the migration that fill the tables with data.
    /// - Parameter database: The database.
    func prepare(on database: FluentKit.Database) async throws {
        //MARK: - Users -
        ///Company Users
        let user0 = User(name: "Maria", email: "maria@prueba.com", password: try Bcrypt.hash("password0"), userType: UserType.company)

        let user1 = User(name: "Jose", email: "jose@prueba.com", password: try Bcrypt.hash("password1"), userType: UserType.company)

        let user2 = User(name: "Rafael", email: "rafael@prueba.com", password: try Bcrypt.hash("password2"), userType: UserType.company)
        
        ///Customer Users
        let user3 = User(name: "Mario", email: "mario@prueba.com", password: try Bcrypt.hash("password3"), userType: UserType.customer)
        
        let user4 = User(name: "Elena", email: "elena@prueba.com", password: try Bcrypt.hash("password4"), userType: UserType.customer)
        
        let user5 = User(name: "Rafael", email: "rafael@prueba.com", password: try Bcrypt.hash("password5"), userType: UserType.customer)
        
        ///Add to the database
        try await [user0, user1, user2, user3, user4, user5].create(on: database)
        
        
        /**
         Manual steps using RapidApi & TablePlus
         1. Run user script
         2. Using RapidApi, sign in using user0: Header: HTTP Basic Auth email & password
         3. From Sign In JSON response, "Copy as Response Body Dynamic Value" from "accessToken"
         4. PASTE into Header > Authorization "Bearer <paste Response Body Dynamic Value>"
         5. TablePlus > "users" table > "Maria" record > copy "id" UUID value
         6. PASTE into: RapidAPI > "Create Restaurant" request > Body > "idCompany"
         7. Run requests > 200 OK
      **/
        
        //MARK: - Coordinates -
        
        ///Coordiantes.
        let coordinates1: Coordinates = try Coordinates(latitude: 40.3, longitude: -3.4)
        let coordinates2: Coordinates = try Coordinates(latitude: 40.2, longitude: -3.3)
        let coordinates3: Coordinates = try Coordinates(latitude: 40.0, longitude: -3.1)
        let coordinates4: Coordinates = try Coordinates(latitude: 40.2, longitude: -3.6)
        let coordinates5: Coordinates = try Coordinates(latitude: 40.0, longitude: -3.0)
        
        try await [coordinates1, coordinates2, coordinates3, coordinates4, coordinates5].create(on: database)
        
        //MARK: - Adrresses -
        ///Addresses.
        let address0 = Address(country: "Spain", state: "Comunidad de Madrid", city: "Móstoles", zipCode: "28661", address: "Calle Desengaño nº 21")
        let address1 = Address(country: "Spain", state: "Comunidad de Madrid", city: "Alcorcón", zipCode: "28634", address: "Avenida de Europa nº 32")
        let address2 = Address(country: "Spain", state: "Comunidad de Madrid", city: "Brunete", zipCode: "28345", address: "Calle Libro nº 1")
        let address3 = Address(country: "Spain", state: "Comunidad de Madrid", city: "Pozuelo de Alcorcón", zipCode: "28345", address: "Calle de la Paz nº 25")
        let address4 = Address(country: "Spain", state: "Comunidad de Madrid", city: "Villaviciosa de Odón", zipCode: "28645", address: "Calle Nueva nº 4")
        
        try await [address0, address1, address2, address3, address4].create(on: database)
        
        //MARK: - Restaurants -
        ///Restaurants.
        let restaurant0 = try Restaurant(
            idCompany: user0.id!,
            name: "Shushi Bar",
            picture: "https://images.pexels.com/photos/18078297/pexels-photo-18078297/free-photo-of-ciudad-calle-barra-urbano.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1", type: "Japonés",
            address: address0,
            coordinates: coordinates1,
            openingHour: "8:30",
            closingHour: "23:30"
        )
        
        
        let restaurant1 = try Restaurant(
            idCompany: user0.id!,
            name: "Mao Sushi",
            picture: "https://images.pexels.com/photos/3421920/pexels-photo-3421920.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1", type: "Japonés",
            address: address1,
            coordinates: coordinates2,
            openingHour: "8:30",
            closingHour: "23:30"
            
        )
        
        let restaurant2 = try Restaurant(
            idCompany: user0.id!,
            name: "El Paraíso",
            picture: "https://www.camarero10.com/wp-content/uploads/2020/02/como-distribuir-un-restaurante.jpg",
            type: "Chino",
            address: address2,
            coordinates: coordinates3,
            openingHour: "8:30",
            closingHour: "23:30"
        )
        
        
        let restaurant3 = try Restaurant(
            idCompany: user1.id!,
            name: "Pizza Pera",
            picture: "https://images.pexels.com/photos/7317358/pexels-photo-7317358.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
            type: "Pizzeria",
            address: address3,
            coordinates: coordinates4,
            openingHour: "8:30",
            closingHour: "23:30"
        )
        
        let restaurant4 = try Restaurant(
            idCompany: user1.id!,
            name: "Il Quattro",
            picture: "https://www.hotelaiguablava.com/media/restaurante/espacios/restaurante/01a-restaurante-hotel-aigua-blava.jpg",
            type: "Italiano",
            address: address4,
            coordinates: coordinates5,
            openingHour: "8:30",
            closingHour: "23:30"
        )
        
        try await [restaurant0, restaurant1, restaurant2, restaurant3, restaurant4].create(on: database)
        
        //MARK: - Offers -
        //TODO: price should be Double.
        ///Offers.
        let offer0 = Offer(restaurant: restaurant0,
                            idState: UUID(uuidString: "01dfd76b-efad-4783-baa7-da38e6535b1c")!,
                            title: "2 por 1 Sushi",
                            image: "https://www.camarero10.com/wp-content/uploads/2020/02/como-distribuir-un-restaurante.jpg",
                            description: "Disfruta doble de la comida.",
                            quantityOffered: 4,
                            startHour: Date.mapStringToDate(dateString: "2023-08-09T15:00:00Z"),
                            endHour: Date.mapStringToDate(dateString: "2023-08-09T17:00:00Z"),
                            price: 10,
                            idCurrency: UUID(uuidString: "841f0816-0c97-4820-a3de-7cfa543b481d")!,
                            minimumCustomers: 1,
                            maximumCustomers: 6)
        
        let offer1 = Offer(restaurant: restaurant0,
                            idState: UUID(uuidString: "01dfd76b-efad-4783-baa7-da38e6535b1c")!,
                            title: "3 por 1 Ramen",
                            image: "https://www.restaurantelua.com/wp-content/uploads/2020/11/01_slider_restaurante_movil.jpg",
                            description: "Disfruta muchoooo de la comida.",
                            quantityOffered: 15,
                            startHour: Date.mapStringToDate(dateString: "2023-08-09T15:00:00Z"),
                            endHour: Date.mapStringToDate(dateString: "2023-08-09T17:30:00Z"),
                            price: 104,
                            idCurrency: UUID(uuidString: "841f0816-0c97-4820-a3de-7cfa543b481d")!,
                            minimumCustomers: 3,
                            maximumCustomers: 6)
        
        let offer2 = Offer(restaurant: restaurant0,
                            idState: UUID(uuidString: "01dfd76b-efad-4783-baa7-da38e6535b1c")!,
                            title: "2 por 1 Sushi",
                            image: "https://www.hotelaiguablava.com/media/restaurante/espacios/restaurante/01a-restaurante-hotel-aigua-blava.jpg",
                            description: "Disfruta doble la comida.",
                            quantityOffered: 10,
                            startHour: Date.mapStringToDate(dateString: "2023-08-09T15:00:00Z"),
                            endHour: Date.mapStringToDate(dateString: "2023-08-09T17:00:00Z"),
                            price: 42,
                            idCurrency: UUID(uuidString: "841f0816-0c97-4820-a3de-7cfa543b481d")!,
                            minimumCustomers: 1,
                            maximumCustomers: 2)
        
        let offer3 = Offer(restaurant: restaurant1,
                            idState: UUID(uuidString: "01dfd76b-efad-4783-baa7-da38e6535b1c")!,
                            title: "50% dto en Sushi",
                            image: "https://images.pexels.com/photos/6249501/pexels-photo-6249501.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
                            description: "Disfruta a tope de la comida.",
                            quantityOffered: 9,
                            startHour: Date.mapStringToDate(dateString: "2023-08-09T15:30:00Z"),
                            endHour: Date.mapStringToDate(dateString: "2023-08-09T17:40:00Z"),
                            price: 0,
                            idCurrency: UUID(uuidString: "841f0816-0c97-4820-a3de-7cfa543b481d")!,
                            minimumCustomers: 1,
                            maximumCustomers: 1)
        
        let offer4 = Offer(restaurant: restaurant1,
                            idState: UUID(uuidString: "01dfd76b-efad-4783-baa7-da38e6535b1c")!,
                            title: "Tapas a Tope",
                            image: "https://images.pexels.com/photos/14907793/pexels-photo-14907793.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
                            description: "Tapa gratis con cualquier bebida.",
                            quantityOffered: 15,
                            startHour: Date.mapStringToDate(dateString: "2023-08-09T15:00:00Z"),
                            endHour: Date.mapStringToDate(dateString: "2023-08-09T19:00:00Z"),
                            price: 0,
                            idCurrency: UUID(uuidString: "841f0816-0c97-4820-a3de-7cfa543b481d")!,
                            minimumCustomers: 1,
                            maximumCustomers: 5)
        
        let offer5 = Offer(restaurant: restaurant3,
                            idState: UUID(uuidString: "01dfd76b-efad-4783-baa7-da38e6535b1c")!,
                            title: "3 x 1 en pizzas",
                            image: "https://images.pexels.com/photos/12046657/pexels-photo-12046657.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
                            description: "Pizzas para todos",
                            quantityOffered: 9,
                            startHour: Date.mapStringToDate(dateString: "2023-08-09T15:00:00Z"),
                            endHour: Date.mapStringToDate(dateString: "2023-08-09T17:00:00Z"),
                            price: 0,
                            idCurrency: UUID(uuidString: "841f0816-0c97-4820-a3de-7cfa543b481d")!,
                            minimumCustomers: 1,
                            maximumCustomers: 5)
        
        
        let offer6 = Offer(restaurant: restaurant2,
                            idState: UUID(uuidString: "01dfd76b-efad-4783-baa7-da38e6535b1c")!,
                            title: "Todo al 50% de Descuento",
                            image: "https://images.pexels.com/photos/5595427/pexels-photo-5595427.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
                            description: "Todo al 50% de descuento excepto en bebidas.",
                            quantityOffered: 8,
                            startHour: Date.mapStringToDate(dateString: "2023-08-09T15:00:00Z"),
                            endHour: Date.mapStringToDate(dateString: "2023-08-09T17:00:00Z"),
                            price: 0,
                            idCurrency: UUID(uuidString: "841f0816-0c97-4820-a3de-7cfa543b481d")!,
                            minimumCustomers: 3,
                            maximumCustomers: 8)
        
        let offer7 = Offer(restaurant: restaurant2,
                            idState: UUID(uuidString: "01dfd76b-efad-4783-baa7-da38e6535b1c")!,
                            title: "2 por 1 Onigiri",
                            image: "https://cdn.pixabay.com/photo/2022/10/13/17/52/onigiri-7519669_1280.jpg",
                            description: "Más arroz, más sabor.",
                            quantityOffered: 5,
                            startHour: Date.mapStringToDate(dateString: "2023-08-09T15:00:00Z"),
                            endHour: Date.mapStringToDate(dateString: "2023-08-09T17:30:00Z"),
                            price: 0,
                            idCurrency: UUID(uuidString: "841f0816-0c97-4820-a3de-7cfa543b481d")!,
                            minimumCustomers: 1,
                            maximumCustomers: 3)
        
        try await [offer0, offer1, offer2, offer3, offer4, offer5, offer6, offer7].create(on: database)
        
         /*
          Thread 1: Fatal error: Error raised at top level: PSQLError(
          code: server,
          serverInfo: [
              sqlState: 23503, detail: Key (id_company)=(2a714742-c546-4cba-898e-7068353eb386) is not present in table "users".,
              file: ri_triggers.c, line: 2607,
              message: insert or update on table "restaurants" violates foreign key constraint "restaurants_id_company_fkey",
              routine: ri_ReportViolation,
              localizedSeverity: ERROR,
              severity: ERROR,
              constraintName: restaurants_id_company_fkey,
              schemaName: public,
              tableName: restaurants
          ],
          triggeredFro
          */
    }
    
    /// Method that revert the populate data migration in case that something went wrong.
    /// - Parameter database:The dsatabase.
    func revert(on database: Database) async throws{
        try await User.query(on: database).delete()
        try await Coordinates.query(on: database).delete()
        try await Address.query(on: database).delete()
        try await Restaurant.query(on: database).delete()
        try await Offer.query(on: database).delete()
    }
    
}
