//
//  DateHelper.swift
//  MyMobileED
//
//  Created by Admin on 1/24/17.
//  Copyright © 2017 Company. All rights reserved.
//

import Foundation

class DateHelper: NSObject {

    static let DateFilterFormat = "MM/dd/yyyy"
    static let TimestampFormat = "yyyy-MM-dd HH:mm:ss"
    static let TimeFormat = "hh:mm a"
    static let DateFormat = "MMM dd, yyyy"
    static let DateFormatDay = "EEEE, MMM dd, yyyy"
    static let CommentDateFormat =  "EEEE, MMM d, yyyy, hh:mm a"
    
    static var dateFormatter = DateFormatter()
    
    class func dateFrom(string stringDate: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = NSCalendar.current
        dateFormatter.dateFormat = TimestampFormat
        let dateString = dateFormatter.date(from: stringDate)
        
        return dateString
    }
    
    class func stringDateFrom(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = NSCalendar.current
        dateFormatter.dateFormat = TimestampFormat
        let dateString = dateFormatter.string(from: date)
        
        return dateString
    }
    
    class func stringFilterDateFrom(_ date: Date) -> String {
        dateFormatter.dateFormat = DateFilterFormat
        let filterDateString = dateFormatter.string(from: date)
        
        return filterDateString
    }
    
    class func formatedStringTime(fromDate date: Date) -> String {
        dateFormatter.dateFormat = TimeFormat
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let timeString = dateFormatter.string(from: date)
        
        return timeString
    }
    
    class func formatedStringDate(fromDate date: Date) -> String {
        dateFormatter.dateFormat = DateFormat
        let dateString = dateFormatter.string(from: date)
        
        return dateString
    }
    
    class func formatedStringDateWithDayName(fromDate date: Date) -> String {
        dateFormatter.dateFormat = DateFormatDay
        let dateString = dateFormatter.string(from: date)
        
        return dateString
    }
    
    class func formattedStringDateForComment(fromDate date: Date) -> String {
        dateFormatter.dateFormat = CommentDateFormat
        let dateString = dateFormatter.string(from: date)
        
        return dateString
    }
    
}
