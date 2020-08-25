//
//  Created by Giancarlo Pacheco on 5/23/20.
//

import Foundation

extension Date {
    func dateString(from timestamp: Double) -> String? {
        let date = Date.init(timeIntervalSince1970: timestamp)
        if date > self.startOfDay {
            return "TODAY"
        }
        if date > self.yesterday {
            return "YESTERDAY"
        }
        let dateFormatter = DateFormatter()
        if date > self.thisWeek {
            dateFormatter.dateFormat = "EEEE"
            return dateFormatter.string(from: date).uppercased()
        }
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter.string(from: date).uppercased()
        // or use capitalized(with: locale) if you want
    }
    
    func timeString(from timestamp: Double) -> String? {
        let date = Date.init(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: date)
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: self.startOfDay)!
    }
    
    var thisWeek: Date {
        return Calendar.current.date(byAdding: .day, value: -6, to: self.startOfDay)!
    }
}
