//
//  DailyMission.swift
//  WalkRPG
//
//  デイリーミッションのデータモデル
//

import Foundation
import SwiftData

@Model
class DailyMission {
    // 基本情報
    var id: UUID
    var date: Date // その日の0時0分0秒
    var createdAt: Date

    // ミッション情報
    var missionType: MissionType
    var targetValue: Int
    var currentProgress: Int

    // 報酬
    var goldReward: Int
    var expReward: Int
    var specialReward: String? // "gachaTicket", "itemBox", etc.

    // 表示用
    var title: String
    var description: String

    // 状態
    var isCompleted: Bool
    var completedAt: Date?

    // イニシャライザ
    init(
        date: Date,
        missionType: MissionType,
        targetValue: Int,
        title: String,
        description: String,
        goldReward: Int = 0,
        expReward: Int = 0,
        specialReward: String? = nil
    ) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.createdAt = Date()

        self.missionType = missionType
        self.targetValue = targetValue
        self.currentProgress = 0

        self.goldReward = goldReward
        self.expReward = expReward
        self.specialReward = specialReward

        self.title = title
        self.description = description

        self.isCompleted = false
        self.completedAt = nil
    }

    // メソッド

    /// 進捗を更新
    func updateProgress(_ progress: Int) {
        currentProgress = min(progress, targetValue)

        if !isCompleted && currentProgress >= targetValue {
            complete()
        }
    }

    /// 進捗を追加
    func addProgress(_ amount: Int) {
        updateProgress(currentProgress + amount)
    }

    /// ミッション完了
    private func complete() {
        isCompleted = true
        completedAt = Date()
    }

    /// 報酬を受け取る（手動受け取りの場合）
    func claimRewards() -> MissionReward {
        return MissionReward(
            gold: goldReward,
            exp: expReward,
            specialReward: specialReward
        )
    }

    // 計算プロパティ

    /// 進捗率（0.0〜1.0）
    var progressPercentage: Double {
        guard targetValue > 0 else { return 0 }
        return Double(currentProgress) / Double(targetValue)
    }

    /// 進捗バーの文字列
    var progressText: String {
        return "\(currentProgress) / \(targetValue)"
    }

    /// ミッションのアイコン名
    var iconName: String {
        switch missionType {
        case .steps:
            return "figure.walk"
        case .battles:
            return "crossed.swords"
        case .wins:
            return "trophy.fill"
        case .consecutiveWins:
            return "flame.fill"
        case .levelUp:
            return "arrow.up.circle.fill"
        case .purchaseEquipment:
            return "cart.fill"
        case .upgradeSkill:
            return "star.circle.fill"
        }
    }

    /// ミッションの総報酬値
    var totalRewardValue: Int {
        return goldReward + expReward
    }
}

/// ミッションの報酬
struct MissionReward {
    var gold: Int
    var exp: Int
    var specialReward: String?

    var hasSpecialReward: Bool {
        return specialReward != nil
    }
}

// MARK: - デイリーミッション生成ファクトリー
struct DailyMissionFactory {
    /// その日のデイリーミッションを生成
    static func generateDailyMissions(for date: Date = Date()) -> [DailyMission] {
        let startOfDay = Calendar.current.startOfDay(for: date)

        return [
            // 歩数系
            DailyMission(
                date: startOfDay,
                missionType: .steps,
                targetValue: 5000,
                title: "5,000歩達成",
                description: "今日中に5,000歩歩きましょう",
                goldReward: 500,
                expReward: 0
            ),
            DailyMission(
                date: startOfDay,
                missionType: .steps,
                targetValue: 10000,
                title: "10,000歩達成",
                description: "今日中に10,000歩歩きましょう",
                goldReward: 1500,
                expReward: 0,
                specialReward: "gachaTicket"
            ),

            // 戦闘系
            DailyMission(
                date: startOfDay,
                missionType: .battles,
                targetValue: 10,
                title: "10回戦闘",
                description: "敵と10回戦闘しましょう",
                goldReward: 300,
                expReward: 0
            ),
            DailyMission(
                date: startOfDay,
                missionType: .wins,
                targetValue: 10,
                title: "10勝達成",
                description: "敵を10体倒しましょう",
                goldReward: 500,
                expReward: 200
            ),
            DailyMission(
                date: startOfDay,
                missionType: .consecutiveWins,
                targetValue: 5,
                title: "5連勝達成",
                description: "連続で5回勝利しましょう",
                goldReward: 800,
                expReward: 0,
                specialReward: "itemBox"
            )
        ]
    }

    /// ウィークリーミッションを生成
    static func generateWeeklyMissions(for date: Date = Date()) -> [DailyMission] {
        let startOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!

        return [
            DailyMission(
                date: startOfWeek,
                missionType: .steps,
                targetValue: 50000,
                title: "週間50,000歩達成",
                description: "今週中に50,000歩歩きましょう",
                goldReward: 5000,
                expReward: 0,
                specialReward: "specialGachaTicket_3"
            ),
            DailyMission(
                date: startOfWeek,
                missionType: .wins,
                targetValue: 50,
                title: "週間50勝達成",
                description: "今週中に50回勝利しましょう",
                goldReward: 3000,
                expReward: 1000
            )
        ]
    }
}
