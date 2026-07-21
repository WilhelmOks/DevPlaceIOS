import Foundation
import DevPlaceSwiftSDK

extension Collection where Element == Badge {
    static var mock: [Element] {
        [
            .init(
                name: "Early Adopter",
                createdAt: Date().addingTimeInterval(-60 * 60 * 24 * 365),
            ),
            .init(
                name: "Top Contributor",
                createdAt: Date().addingTimeInterval(-60 * 60 * 24 * 90),
            ),
            .init(
                name: "Bug Hunter",
                createdAt: Date().addingTimeInterval(-60 * 60 * 24 * 30),
            ),
            .init(
                name: "Star Gazer",
                createdAt: Date().addingTimeInterval(-60 * 60 * 24 * 7),
            ),
            .init(
                name: nil,
                createdAt: Date().addingTimeInterval(-60 * 60),
            ),
        ]
    }
}
