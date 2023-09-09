//
//  File.swift
//  
//
//  Created by Alberto Junquera Ramírez on 7/9/23.
//

import Vapor
///Struct to map the offers results.
struct OfferMappers {
    /// Method that transforms one Offer into a Ofer.Public.
    /// - Parameter offer: An offer object.
    /// - Returns: An offer.public object.
    static func mapperFromOfferToOfferPublic(offer: Offer) -> Offer.Public{
        return Offer.Public(id: offer.id!,
                            idRestaurant: offer.restaurant.id!,
                            title: offer.title,
                            image: offer.image,
                            description: offer.description,
                            quantityOffered: offer.quantityOffered,
                            createdDate: offer.createdDate,
                            startHour: offer.startHour,
                            endHour: offer.endHour,
                            price: offer.price,
                            idCurrency: offer.idCurrency,
                            minimumCustomers: offer.minimumCustomers,
                            maximumCustomers: offer.maximumCustomers)
    }
    
    /// Method that transforms a [Offer] list into a [Offer.Public]
    /// - Parameter offersList: An Offer list [Offer]
    /// - Returns: An Offer.Public list [Offer.Public]
    static func mapperFromOffersToOfferPublicList(offersList: [Offer]) -> [Offer.Public]{
        var result : [Offer.Public] = []
        offersList.forEach { offer in
            result.append(mapperFromOfferToOfferPublic(offer: offer))
        }
        return result
    }
}
