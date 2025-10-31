//
//  Constants.swift
//  WalkRPG
//
//  アプリ全体で使用する定数
//

import Foundation

struct Constants {
    // MARK: - アプリ情報

    static let appName = "WalkRPG"
    static let appVersion = "1.0.0"

    // MARK: - UserDefaults Keys

    struct UserDefaultsKeys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let lastAppOpenDate = "lastAppOpenDate"
        static let lastDailyResetDate = "lastDailyResetDate"
        static let totalPlayTime = "totalPlayTime"
        static let musicEnabled = "musicEnabled"
        static let soundEffectsEnabled = "soundEffectsEnabled"
        static let notificationsEnabled = "notificationsEnabled"
    }

    // MARK: - Notification Identifiers

    struct NotificationIdentifiers {
        static let levelUp = "com.walkrpg.notification.levelup"
        static let randomEvent = "com.walkrpg.notification.randomevent"
        static let dailyMission = "com.walkrpg.notification.dailymission"
        static let battleResult = "com.walkrpg.notification.battleresult"
        static let stepMilestone = "com.walkrpg.notification.stepmilestone"
    }

    // MARK: - Background Task Identifiers

    struct BackgroundTaskIdentifiers {
        static let battle = "com.walkrpg.background.battle"
        static let stepUpdate = "com.walkrpg.background.stepupdate"
    }

    // MARK: - HealthKit Identifiers

    struct HealthKitIdentifiers {
        static let stepCountType = "HKQuantityTypeIdentifierStepCount"
    }

    // MARK: - Animation Durations

    struct AnimationDuration {
        static let short: Double = 0.2
        static let medium: Double = 0.3
        static let long: Double = 0.5
    }

    // MARK: - UI Constants

    struct UI {
        static let cornerRadius: CGFloat = 12
        static let shadowRadius: CGFloat = 4
        static let padding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        static let largePadding: CGFloat = 24

        static let iconSize: CGFloat = 24
        static let largeIconSize: CGFloat = 48

        static let buttonHeight: CGFloat = 50
        static let cardHeight: CGFloat = 120
    }

    // MARK: - Color Names

    struct ColorNames {
        static let primary = "PrimaryColor"
        static let secondary = "SecondaryColor"
        static let accent = "AccentColor"
        static let background = "BackgroundColor"
        static let surface = "SurfaceColor"
        static let error = "ErrorColor"
        static let success = "SuccessColor"
        static let warning = "WarningColor"

        // Rarity Colors
        static let rarityCommon = "RarityCommonColor"
        static let rarityRare = "RarityRareColor"
        static let rarityEpic = "RarityEpicColor"
        static let rarityLegendary = "RarityLegendaryColor"
    }

    // MARK: - SF Symbols

    struct SFSymbols {
        // Navigation
        static let home = "house.fill"
        static let shop = "cart.fill"
        static let skills = "star.circle.fill"
        static let battle = "crossed.swords"
        static let missions = "list.bullet.clipboard.fill"
        static let settings = "gearshape.fill"

        // Status
        static let health = "heart.fill"
        static let attack = "bolt.fill"
        static let defense = "shield.fill"
        static let level = "arrow.up.circle.fill"
        static let exp = "sparkles"
        static let gold = "dollarsign.circle.fill"
        static let steps = "figure.walk"

        // Equipment
        static let weapon = "figure.fencing"
        static let armor = "shield.lefthalf.filled"
        static let accessory = "star.fill"

        // Actions
        static let equip = "checkmark.circle.fill"
        static let unequip = "xmark.circle.fill"
        static let buy = "cart.badge.plus"
        static let sell = "cart.badge.minus"

        // Events
        static let event = "exclamationmark.triangle.fill"
        static let treasure = "gift.fill"
        static let merchant = "person.fill"

        // Other
        static let timer = "timer"
        static let info = "info.circle"
        static let close = "xmark"
        static let refresh = "arrow.clockwise"
    }

    // MARK: - Date Formats

    struct DateFormat {
        static let full = "yyyy-MM-dd HH:mm:ss"
        static let date = "yyyy-MM-dd"
        static let time = "HH:mm:ss"
        static let shortTime = "HH:mm"
        static let dayMonth = "MM/dd"
    }

    // MARK: - Database

    struct Database {
        static let modelName = "WalkRPGModel"
        static let dbFileName = "WalkRPG.sqlite"
    }

    // MARK: - URLs

    struct URLs {
        static let privacyPolicy = "https://example.com/privacy"
        static let termsOfService = "https://example.com/terms"
        static let support = "https://example.com/support"
    }

    // MARK: - Limits

    struct Limits {
        static let maxPlayerNameLength = 20
        static let maxBattleLogCount = 100
        static let maxSavedEquipment = 50
    }
}

// MARK: - 便利な拡張
extension Constants {
    /// デバッグモードかどうか
    static var isDebugMode: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    /// シミュレーターかどうか
    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
}
