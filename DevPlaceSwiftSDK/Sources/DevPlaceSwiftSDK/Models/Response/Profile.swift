import Foundation

public struct Profile: Hashable, Sendable, Identifiable {
    public var id: String { "profile:" + user.id }
    public let user: User
    public let posts: [Post]
    public let badges: [Badge]
    public let badgeTotal: Int
    public let badgeEarned: Int
    public let projects: [Project.Data]
    public let gists: [Gist]
    public let currentTab: String
    public let postsCount: Int
    public let isFollowing: Bool
    public let isBlocked: Bool
    public let isMuted: Bool
    public let isOwner: Bool
    public let canViewApiKey: Bool
    public let apiKey: String
    public let aiCorrectionEnabled: Bool
    public let aiCorrectionSync: Bool
    public let aiCorrectionPrompt: String?
    public let aiModifierEnabled: Bool
    public let aiModifierSync: Bool
    public let aiModifierPrompt: String?
    public let telegramPaired: Bool
    public let notifTelegramPaired: Bool
    public let canManageCustomization: Bool
    public let custDisableGlobal: Bool
    public let custDisablePagetype: Bool
    public let rank: Int
    public let followersCount: Int
    public let followingCount: Int
    public let viewerIsAdmin: Bool
    public let media: [Media]
    //public let achievements: [???] // array of empty objects in sample - type unknown
    //public let aiQuota: ??? // empty object in sample - type unknown
    //public let correctionUsage: ??? // empty object in sample - type unknown
    //public let modifierUsage: ??? // empty object in sample - type unknown
    //public let activities: [???] // array with null in sample - type unknown
    //public let heatmap: ??? // null in sample - type unknown
    //public let heatmapMonths: ??? // null in sample - type unknown
    //public let streak: ??? // null in sample - type unknown
    //public let people: [???] // array with null in sample - type unknown
    //public let followPagination: ??? // null in sample - type unknown
    //public let mediaPagination: ??? // null in sample - type unknown
    //public let notificationPrefs: [???] // array with null in sample - type unknown

    public init(
        user: User,
        posts: [Post],
        badges: [Badge],
        badgeTotal: Int,
        badgeEarned: Int,
        projects: [Project.Data],
        gists: [Gist],
        currentTab: String,
        postsCount: Int,
        isFollowing: Bool,
        isBlocked: Bool,
        isMuted: Bool,
        isOwner: Bool,
        canViewApiKey: Bool,
        apiKey: String,
        aiCorrectionEnabled: Bool,
        aiCorrectionSync: Bool,
        aiCorrectionPrompt: String?,
        aiModifierEnabled: Bool,
        aiModifierSync: Bool,
        aiModifierPrompt: String?,
        telegramPaired: Bool,
        notifTelegramPaired: Bool,
        canManageCustomization: Bool,
        custDisableGlobal: Bool,
        custDisablePagetype: Bool,
        rank: Int,
        followersCount: Int,
        followingCount: Int,
        viewerIsAdmin: Bool,
        media: [Media],
    ) {
        self.user = user
        self.posts = posts
        self.badges = badges
        self.badgeTotal = badgeTotal
        self.badgeEarned = badgeEarned
        self.projects = projects
        self.gists = gists
        self.currentTab = currentTab
        self.postsCount = postsCount
        self.isFollowing = isFollowing
        self.isBlocked = isBlocked
        self.isMuted = isMuted
        self.isOwner = isOwner
        self.canViewApiKey = canViewApiKey
        self.apiKey = apiKey
        self.aiCorrectionEnabled = aiCorrectionEnabled
        self.aiCorrectionSync = aiCorrectionSync
        self.aiCorrectionPrompt = aiCorrectionPrompt
        self.aiModifierEnabled = aiModifierEnabled
        self.aiModifierSync = aiModifierSync
        self.aiModifierPrompt = aiModifierPrompt
        self.telegramPaired = telegramPaired
        self.notifTelegramPaired = notifTelegramPaired
        self.canManageCustomization = canManageCustomization
        self.custDisableGlobal = custDisableGlobal
        self.custDisablePagetype = custDisablePagetype
        self.rank = rank
        self.followersCount = followersCount
        self.followingCount = followingCount
        self.viewerIsAdmin = viewerIsAdmin
        self.media = media
    }
}

extension Profile {
    struct CodingData: Decodable {
        let profile_user: User.CodingData
        let posts: [Post.CodingData]
        let badges: [Badge.CodingData]
        let badge_total: Int
        let badge_earned: Int
        let projects: [Project.Data.CodingData]
        let gists: [Gist.CodingData]
        let current_tab: String
        let posts_count: Int
        let is_following: Bool
        let is_blocked: Bool
        let is_muted: Bool
        let is_owner: Bool
        let can_view_api_key: Bool
        let api_key: String
        let ai_correction_enabled: Bool
        let ai_correction_sync: Bool
        let ai_correction_prompt: String?
        let ai_modifier_enabled: Bool
        let ai_modifier_sync: Bool
        let ai_modifier_prompt: String?
        let telegram_paired: Bool
        let notif_telegram_paired: Bool
        let can_manage_customization: Bool
        let cust_disable_global: Bool
        let cust_disable_pagetype: Bool
        let rank: Int
        let followers_count: Int
        let following_count: Int
        let viewer_is_admin: Bool
        let media: [Media.CodingData]
        //let achievements: [???] // array of empty objects in sample - type unknown
        //let ai_quota: ??? // empty object in sample - type unknown
        //let correction_usage: ??? // empty object in sample - type unknown
        //let modifier_usage: ??? // empty object in sample - type unknown
        //let activities: [???] // array with null in sample - type unknown
        //let heatmap: ??? // null in sample - type unknown
        //let heatmap_months: ??? // null in sample - type unknown
        //let streak: ??? // null in sample - type unknown
        //let people: [???] // array with null in sample - type unknown
        //let follow_pagination: ??? // null in sample - type unknown
        //let media_pagination: ??? // null in sample - type unknown
        //let notification_prefs: [???] // array with null in sample - type unknown
    }
}

extension Profile.CodingData {
    var decoded: Profile {
        .init(
            user: profile_user.decoded,
            posts: posts.map(\.decoded),
            badges: badges.map(\.decoded),
            badgeTotal: badge_total,
            badgeEarned: badge_earned,
            projects: projects.map(\.decoded),
            gists: gists.map(\.decoded),
            currentTab: current_tab,
            postsCount: posts_count,
            isFollowing: is_following,
            isBlocked: is_blocked,
            isMuted: is_muted,
            isOwner: is_owner,
            canViewApiKey: can_view_api_key,
            apiKey: api_key,
            aiCorrectionEnabled: ai_correction_enabled,
            aiCorrectionSync: ai_correction_sync,
            aiCorrectionPrompt: ai_correction_prompt,
            aiModifierEnabled: ai_modifier_enabled,
            aiModifierSync: ai_modifier_sync,
            aiModifierPrompt: ai_modifier_prompt,
            telegramPaired: telegram_paired,
            notifTelegramPaired: notif_telegram_paired,
            canManageCustomization: can_manage_customization,
            custDisableGlobal: cust_disable_global,
            custDisablePagetype: cust_disable_pagetype,
            rank: rank,
            followersCount: followers_count,
            followingCount: following_count,
            viewerIsAdmin: viewer_is_admin,
            media: media.map(\.decoded),
        )
    }
}
