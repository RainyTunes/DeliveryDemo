import Foundation

struct Delivery: Codable {
    let id: String
    let remarks: String?
    let pickupTime: String?
    let goodsPicture: String?
    let deliveryFee: String?
    let surcharge: String?
    let route: Route?
    let sender: Sender?
    var offset: Int?

    var isValid: Bool {
        return !id.isEmpty && remarks != nil && pickupTime != nil && goodsPicture != nil && deliveryFee != nil && surcharge != nil && route != nil && sender != nil
    }
}

struct Route: Codable {
    let start: String?
    let end: String?
}

struct Sender: Codable {
    let phone: String?
    let name: String?
    let email: String?
}
