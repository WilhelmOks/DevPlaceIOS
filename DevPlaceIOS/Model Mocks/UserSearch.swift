import Foundation
import DevPlaceSwiftSDK

extension UserSearch {
    static var mock: Self {
        .init(
            results: [
                .init(id: "u1", username: "cheeze_on_wheels", avatarSeed: nil),
                .init(id: "u2", username: "null_void", avatarSeed: nil),
                .init(id: "u3", username: "async_await", avatarSeed: nil),
                .init(id: "u4", username: "pixel_pusher", avatarSeed: nil),
                .init(id: "u5", username: "segfault_sally", avatarSeed: nil),
            ],
        )
    }
}
