import Foundation
import Observation
import DevPlaceSwiftSDK

extension NotificationsView {
    @Observable final class ViewModel {
        let api: DevPlaceApi

        var notifications: Notifications?
        var alertMessage: AlertMessage = .none()
        var isLoadingMore = false

        init(api: DevPlaceApi) {
            self.api = api
        }

        var groups: [NotificationGroup] {
            notifications?.groups ?? []
        }

        var hasUnread: Bool {
            groups.contains { group in
                group.entries.contains { !$0.data.read }
            }
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
            return Notifications(groups: groups, nextCursor: older.nextCursor)
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
