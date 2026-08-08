import Foundation
import UIKit
import UserNotifications

@MainActor
final class PushNotificationManager {
    static let shared = PushNotificationManager()

    private init() {}

    private var api: DevPlaceApi = .prod
    private var deviceTokenHex: String?

    func registerForPushNotifications(api: DevPlaceApi) async {
        self.api = api
        await requestAuthorization()
        UIApplication.shared.registerForRemoteNotifications()
        await sendDeviceTokenToBackend()
    }

    func unregisterForPushNotifications(api: DevPlaceApi) async {
        self.api = api
        if let deviceTokenHex {
            do {
                try await api.unregisterPushDevice(deviceToken: deviceTokenHex)
            } catch {
                dlog("Failed to unregister push device: \(error)")
            }
        }
        await setBadgeCount(0)
    }

    func didRegisterForRemoteNotifications(deviceToken: Data) {
        deviceTokenHex = deviceToken.map { String(format: "%02x", $0) }.joined()
        dlog("Registered for APNs with device token: \(deviceTokenHex ?? "nil")")
        Task {
            await sendDeviceTokenToBackend()
        }
    }

    func didFailToRegisterForRemoteNotifications(error: Error) {
        dlog("Failed to register for APNs: \(error)")
    }

    // TODO: The current push payload carries no badge number, so we refetch counts from the
    // backend on every received push. Once the backend adds `aps.badge` (server-side unread
    // count) to the payload, read it directly here and set the icon badge from it — that also
    // lets iOS update the icon badge while the app is backgrounded/terminated, without a fetch.
    func handleRemoteNotification(userInfo: [AnyHashable: Any]) async {
        dlog("Received push notification payload: \(Self.prettyPrinted(userInfo))")
        await AppState.shared.loadUnreadCounts(api: api)
        await setBadgeCount(AppState.shared.totalUnreadCount)
    }

    func handleNotificationTap(userInfo: [AnyHashable: Any]) async {
        await handleRemoteNotification(userInfo: userInfo)
        if let conversationUid = Self.conversationUid(in: userInfo) {
            AppState.shared.pendingConversationUid = conversationUid
        }
    }

    private func requestAuthorization() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            dlog("Push authorization granted: \(granted)")
        } catch {
            dlog("Push authorization request failed: \(error)")
        }
    }

    private func sendDeviceTokenToBackend() async {
        guard AppState.shared.isLoggedIn, let deviceTokenHex else {
            return
        }
        do {
            try await api.registerPushDevice(deviceToken: deviceTokenHex)
        } catch {
            dlog("Failed to register push device with backend: \(error)")
        }
    }

    private func setBadgeCount(_ count: Int) async {
        do {
            try await UNUserNotificationCenter.current().setBadgeCount(count)
        } catch {
            dlog("Failed to set app icon badge count: \(error)")
        }
    }

    private static func prettyPrinted(_ userInfo: [AnyHashable: Any]) -> String {
        if JSONSerialization.isValidJSONObject(userInfo),
           let data = try? JSONSerialization.data(withJSONObject: userInfo, options: [.prettyPrinted, .sortedKeys]),
           let json = String(data: data, encoding: .utf8) {
            return json
        }
        return String(describing: userInfo)
    }

    private static func conversationUid(in userInfo: [AnyHashable: Any]) -> String? {
        guard let urlString = userInfo["url"] as? String,
              let components = URLComponents(string: urlString),
              components.path.contains("messages"),
              let uid = components.queryItems?.first(where: { $0.name == "with_uid" })?.value,
              !uid.isEmpty else {
            return nil
        }
        return uid
    }
}
