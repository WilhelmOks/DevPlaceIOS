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
    
    private init() {
        let raw = UserDefaults.standard.string(forKey: appearanceKey)
        self.appearance = raw.flatMap(AppearanceMode.init(rawValue:)) ?? .dark
        self.showFeedAttachments = (userDefaults.object(forKey: showFeedAttachmentsKey) as? Bool) ?? true
        self.showFeedComments = (userDefaults.object(forKey: showFeedCommentsKey) as? Bool) ?? true
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
