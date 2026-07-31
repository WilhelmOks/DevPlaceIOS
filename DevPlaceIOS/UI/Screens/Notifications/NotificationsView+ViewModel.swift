import Foundation
import Observation
import DevPlaceSwiftSDK

extension NotificationsView {
    struct NavigationTarget: Hashable, Identifiable {
        let slug: String
        let scrollToCommentId: String?

        var id: Self { self }
    }

    @Observable final class ViewModel {
        let api: DevPlaceApi

        var notifications: Notifications? {
            didSet {
                let count = unreadCount
                Task { @MainActor in
                    AppState.shared.unreadNotificationCount = count
                }
            }
        }
        var alertMessage: AlertMessage = .none()
        var isLoadingMore = false

        init(api: DevPlaceApi) {
            self.api = api
        }

        var groups: [NotificationGroup] {
            notifications?.groups ?? []
        }

        var unreadCount: Int {
            groups.reduce(0) { total, group in
                total + group.entries.filter { !$0.data.read }.count
            }
        }

        var hasUnread: Bool {
            unreadCount > 0
        }

        func load() async {
            do {
                notifications = try await api.notifications()
            } catch {
                alertMessage = .presentedError(error)
            }
        }

        func refresh() async {
            do {
                notifications = try await api.notifications()
            } catch {
                alertMessage = .presentedError(error)
            }
        }

        func loadMore() async {
            guard !isLoadingMore, let cursor = notifications?.nextCursor else { return }
            isLoadingMore = true
            defer { isLoadingMore = false }
            do {
                let older = try await api.notifications(before: cursor)
                if let existing = notifications {
                    notifications = merged(existing, with: older)
                } else {
                    notifications = older
                }
            } catch {
                alertMessage = .presentedError(error)
            }
        }

        func navigationTarget(for notification: DevPlaceSwiftSDK.Notification) -> NavigationTarget? {
            guard let slug = postSlug(fromTargetUrl: notification.data.targetUrl) else {
                return nil
            }
            let scrollToCommentId = commentUid(for: notification).map { "comment:" + $0 }
            return NavigationTarget(slug: slug, scrollToCommentId: scrollToCommentId)
        }

        private func postSlug(fromTargetUrl targetUrl: String) -> String? {
            guard let components = URLComponents(string: targetUrl) else { return nil }
            let segments = components.path.split(separator: "/").map(String.init)
            guard let postsIndex = segments.firstIndex(of: "posts"),
                  postsIndex + 1 < segments.count else {
                return nil
            }
            return segments[postsIndex + 1]
        }

        private func commentUid(for notification: DevPlaceSwiftSDK.Notification) -> String? {
            if let fromUrl = commentUid(fromTargetUrl: notification.data.targetUrl) {
                return fromUrl
            }
            return isCommentNotification(notification) ? notification.data.relatedId : nil
        }

        private func commentUid(fromTargetUrl targetUrl: String) -> String? {
            guard let components = URLComponents(string: targetUrl) else { return nil }

            if let fragment = components.fragment, let uid = commentUid(fromToken: fragment) {
                return uid
            }

            let commentQueryNames = ["comment", "comment_id", "commentId", "comment_uid"]
            if let value = components.queryItems?.first(where: { commentQueryNames.contains($0.name) })?.value,
               !value.isEmpty {
                return value
            }

            let segments = components.path.split(separator: "/").map(String.init)
            if let commentsIndex = segments.firstIndex(of: "comments"), commentsIndex + 1 < segments.count {
                return segments[commentsIndex + 1]
            }

            return nil
        }

        private func commentUid(fromToken token: String) -> String? {
            let prefixes = ["comment-", "comment_", "comment:", "comment"]
            for prefix in prefixes where token.hasPrefix(prefix) {
                let uid = String(token.dropFirst(prefix.count))
                return uid.isEmpty ? nil : uid
            }
            return nil
        }

        private func isCommentNotification(_ notification: DevPlaceSwiftSDK.Notification) -> Bool {
            let type = notification.data.type.lowercased()
            return type.contains("comment") || type.contains("reply") || type.contains("mention")
        }

        func markRead(uid: String) async {
            notifications = applyingRead(uids: [uid])
            do {
                try await api.markNotificationRead(uid: uid)
            } catch {
                alertMessage = .presentedError(error)
                await load()
            }
        }

        func markAllRead() async {
            let allUids = Set(groups.flatMap { $0.entries }.map { $0.data.id })
            notifications = applyingRead(uids: allUids)
            do {
                try await api.markAllNotificationsRead()
            } catch {
                alertMessage = .presentedError(error)
                await load()
            }
        }

        private func merged(_ existing: Notifications, with older: Notifications) -> Notifications {
            var groups = existing.groups
            for group in older.groups {
                if let index = groups.firstIndex(where: { $0.label == group.label }) {
                    groups[index] = NotificationGroup(
                        label: group.label,
                        entries: groups[index].entries + group.entries,
                    )
                } else {
                    groups.append(group)
                }
            }
            return deduplicated(Notifications(groups: groups, nextCursor: older.nextCursor))
        }

        private func deduplicated(_ notifications: Notifications) -> Notifications {
            var seenIds: Set<String> = []
            var duplicateIds: [String] = []
            let groups = notifications.groups.map { group in
                let uniqueEntries = group.entries.filter { entry in
                    let id = entry.data.id
                    guard seenIds.insert(id).inserted else {
                        duplicateIds.append(id)
                        return false
                    }
                    return true
                }
                return NotificationGroup(label: group.label, entries: uniqueEntries)
            }
            if !duplicateIds.isEmpty {
                dlog("Dropped duplicate notification IDs while loading more (backend pagination bug — report to backend team): \(duplicateIds.joined(separator: ", "))")
            }
            return Notifications(
                groups: groups.filter { !$0.entries.isEmpty },
                nextCursor: notifications.nextCursor,
            )
        }

        private func applyingRead(uids: Set<String>) -> Notifications? {
            guard let notifications else { return nil }
            let groups = notifications.groups.map { group in
                NotificationGroup(
                    label: group.label,
                    entries: group.entries.map { entry in
                        guard uids.contains(entry.data.id), !entry.data.read else {
                            return entry
                        }
                        return DevPlaceSwiftSDK.Notification(
                            data: .init(
                                id: entry.data.id,
                                type: entry.data.type,
                                message: entry.data.message,
                                read: true,
                                relatedId: entry.data.relatedId,
                                targetUrl: entry.data.targetUrl,
                                createdAt: entry.data.createdAt,
                            ),
                            actor: entry.actor,
                        )
                    },
                )
            }
            return Notifications(groups: groups, nextCursor: notifications.nextCursor)
        }
    }
}
