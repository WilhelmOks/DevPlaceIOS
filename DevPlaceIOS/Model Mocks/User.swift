import Foundation
import DevPlaceSwiftSDK

extension User {
    static var mock: Self {
        .init(
            id: "u1",
            username: "cheeze_on_wheels",
            avatarSeed: nil,
            role: .member,
            bio: "No cheeze, no wheels.",
            location: "Bali, Indonesia",
            gitLink: "https://github.com/cheeze-on-wheels",
            website: "https://cheeze-on-wheels.dev",
            level: 1337,
            xp: 180,
            stars: 0,
            createdAt: Date().addingTimeInterval(-60 * 60 * 24 * 10),
        )
    }
    
    static var mock2: Self {
        .init(
            id: "u2",
            username: "null_void",
            avatarSeed: nil,
            role: .member,
            bio: "Voice of the Void",
            location: "Moscow, Russia",
            gitLink: "https://github.com/avoid-void",
            website: "https://avoid-void.dev",
            level: 1,
            xp: 54,
            stars: 13,
            createdAt: Date().addingTimeInterval(-60 * 60 * 24 * 9),
        )
    }
}
