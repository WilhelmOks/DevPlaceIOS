import Foundation
import Observation
import SwiftUI

@Observable
final class AppSettingsStore {
    static let shared = AppSettingsStore()
    
    private let userDefaults: UserDefaults = .standard
    private let appearanceKey = "appearance"
    private let showFeedAttachmentsKey = "showFeedAttachments"
    private let showFeedCommentsKey = "showFeedComments"
    private let recentEmojisKey = "recentEmojis"
    
    private let maxRecentEmojis = 30
    
    var appearance: AppearanceMode {
        didSet {
            userDefaults.set(appearance.rawValue, forKey: appearanceKey)
        }
    }
    
    var showFeedAttachments: Bool {
        didSet {
            userDefaults.set(showFeedAttachments, forKey: showFeedAttachmentsKey)
        }
    }
    
    var showFeedComments: Bool {
        didSet {
            userDefaults.set(showFeedComments, forKey: showFeedCommentsKey)
        }
    }
    
    var recentEmojis: [String] {
        didSet {
            userDefaults.set(recentEmojis, forKey: recentEmojisKey)
        }
    }
    
    private init() {
        let raw = UserDefaults.standard.string(forKey: appearanceKey)
        self.appearance = raw.flatMap(AppearanceMode.init(rawValue:)) ?? .dark
        self.showFeedAttachments = (userDefaults.object(forKey: showFeedAttachmentsKey) as? Bool) ?? true
        self.showFeedComments = (userDefaults.object(forKey: showFeedCommentsKey) as? Bool) ?? true
        self.recentEmojis = (userDefaults.array(forKey: recentEmojisKey) as? [String]) ?? []
    }
    
    func recordEmojiPick(_ emoji: String) {
        var updated = recentEmojis.filter { $0 != emoji }
        updated.insert(emoji, at: 0)
        recentEmojis = Array(updated.prefix(maxRecentEmojis))
    }
}

extension AppSettingsStore {
    enum AppearanceMode: String, CaseIterable, Identifiable, Sendable {
        case system
        case light
        case dark
        
        var id: Self { self }
        
        var title: String {
            switch self {
            case .system: return "System"
            case .light: return "Light"
            case .dark: return "Dark"
            }
        }
        
        var colorScheme: ColorScheme? {
            switch self {
            case .system: return nil
            case .light: return .light
            case .dark: return .dark
            }
        }
    }
}
