import Foundation

public struct WACUser: Codable {
    var firstName: String
    var lastName: String
    var phoneNumber: String
    
    init(firstName name: String, lastName surname: String, phone number: String) {
        self.firstName = name
        self.lastName = surname
        self.phoneNumber = number
    }
}
