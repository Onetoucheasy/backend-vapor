//
//  File.swift
//  
//
//  Created by Alberto Junquera Ramírez on 5/9/23.
//

import Vapor

extension Date {
    
    static func mapStringToDate(dateString: String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"  //String example: 2023-08-09T15:00:00Z
        
        return dateFormatter.date(from: dateString)!
    }
}
