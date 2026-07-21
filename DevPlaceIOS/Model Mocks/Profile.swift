import Foundation
import DevPlaceSwiftSDK

extension Profile {
    static var mock: Self {
        .init(
            user: .mock,
            posts: .mock,
            badges: [],
            badgeTotal: 0,
            badgeEarned: 0,
            projects: [],
            gists: [],
            currentTab: "posts",
            postsCount: 5,
            isFollowing: false,
            isBlocked: false,
            isMuted: false,
            isOwner: true,
            canViewApiKey: true,
            apiKey: "mock-api-key",
            aiCorrectionEnabled: false,
            aiCorrectionSync: false,
            aiCorrectionPrompt: nil,
            aiModifierEnabled: false,
            aiModifierSync: false,
            aiModifierPrompt: nil,
            telegramPaired: false,
            notifTelegramPaired: false,
            canManageCustomization: true,
            custDisableGlobal: false,
            custDisablePagetype: false,
            rank: 1,
            followersCount: 0,
            followingCount: 0,
            viewerIsAdmin: false,
            media: [],
        )
    }
}
