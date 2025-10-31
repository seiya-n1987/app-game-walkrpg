//
//  NotificationService.swift
//  WalkRPG
//
//  ローカル通知を管理
//

import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()

    private let notificationCenter = UNUserNotificationCenter.current()

    private init() {}

    // MARK: - Authorization

    /// 通知の許可をリクエスト
    func requestAuthorization() async throws -> Bool {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        return try await notificationCenter.requestAuthorization(options: options)
    }

    /// 通知の許可状態を確認
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - Schedule Notifications

    /// レベルアップ通知をスケジュール
    func scheduleLevel UpNotification(newLevel: Int) {
        guard GameBalance.enableLevelUpNotification else { return }

        let content = UNMutableNotificationContent()
        content.title = "🎉 レベルアップ！"
        content.body = "レベル\(newLevel)に到達しました！"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: Constants.NotificationIdentifiers.levelUp + "_\(newLevel)",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule level up notification: \(error.localizedDescription)")
            }
        }
    }

    /// ランダムイベント通知をスケジュール
    func scheduleRandomEventNotification(event: RandomEvent) {
        guard GameBalance.enableEventNotification else { return }

        let content = UNMutableNotificationContent()
        content.title = event.notificationTitle
        content.body = event.notificationBody
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: Constants.NotificationIdentifiers.randomEvent + "_\(event.id.uuidString)",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule event notification: \(error.localizedDescription)")
            }
        }
    }

    /// デイリーミッション完了通知をスケジュール
    func scheduleMissionCompleteNotification(mission: DailyMission) {
        guard GameBalance.enableMissionNotification else { return }

        let content = UNMutableNotificationContent()
        content.title = "✅ ミッション達成！"
        content.body = "\(mission.title)を達成しました！"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: Constants.NotificationIdentifiers.dailyMission + "_\(mission.id.uuidString)",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule mission notification: \(error.localizedDescription)")
            }
        }
    }

    /// 歩数マイルストーン達成通知をスケジュール
    func scheduleStepMilestoneNotification(steps: Int, reward: String) {
        let content = UNMutableNotificationContent()
        content.title = "🚶 歩数目標達成！"
        content.body = "\(steps)歩到達！報酬: \(reward)"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: Constants.NotificationIdentifiers.stepMilestone + "_\(steps)",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule milestone notification: \(error.localizedDescription)")
            }
        }
    }

    /// 戦闘結果通知をスケジュール
    func scheduleBattleResultNotification(isVictory: Bool, enemyName: String, goldEarned: Int) {
        let content = UNMutableNotificationContent()

        if isVictory {
            content.title = "⚔️ 勝利！"
            content.body = "\(enemyName)を倒しました！ゴールド +\(goldEarned)"
        } else {
            content.title = "💀 敗北..."
            content.body = "\(enemyName)に敗れました"
        }

        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: Constants.NotificationIdentifiers.battleResult + "_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule battle notification: \(error.localizedDescription)")
            }
        }
    }

    /// デイリーリマインダー通知をスケジュール（毎日決まった時間）
    func scheduleDailyReminder(hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "🎮 WalkRPGで冒険しよう！"
        content.body = "今日の歩数を確認して、装備を強化しましょう"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "dailyReminder",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("Failed to schedule daily reminder: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Cancel Notifications

    /// 特定の通知をキャンセル
    func cancelNotification(withIdentifier identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    /// すべての通知をキャンセル
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }

    /// 配信済みの通知をクリア
    func clearDeliveredNotifications() {
        notificationCenter.removeAllDeliveredNotifications()
    }

    // MARK: - Badge Management

    /// バッジカウントを設定
    func setBadgeCount(_ count: Int) {
        UNUserNotificationCenter.current().setBadgeCount(count) { error in
            if let error = error {
                print("Failed to set badge count: \(error.localizedDescription)")
            }
        }
    }

    /// バッジをクリア
    func clearBadge() {
        setBadgeCount(0)
    }
}
