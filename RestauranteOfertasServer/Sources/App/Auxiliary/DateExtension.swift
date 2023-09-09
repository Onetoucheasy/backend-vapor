//
//  File.swift
//  
//
//  Created by Alberto Junquera Ramírez on 5/9/23.
//

import Vapor

extension Date {
    
    /// This method allows to easily formate a date String into a date Date.
    /// - Parameter dateString: A date as String type.
    /// - Returns: The date as Date type. Formatter result example:  2023-08-09T15:00:00Z
    static func mapStringToDate(dateString: String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        
        return dateFormatter.date(from: dateString)!
    }
}
