//
//  RandomEvent.swift
//  WalkRPG
//
//  ランダムイベントのデータモデル
//

import Foundation
import SwiftData

@Model
class RandomEvent {
    // 基本情報
    var id: UUID
    var eventType: RandomEventType
    var timestamp: Date
    var expiryTime: Date

    // 状態
    var isActive: Bool
    var isCompleted: Bool
    var completedAt: Date?

    // イベント固有データ（JSON形式）
    var eventData: String?

    // イニシャライザ
    init(
        eventType: RandomEventType,
        timestamp: Date = Date(),
        expiryTime: Date,
        eventData: String? = nil
    ) {
        self.id = UUID()
        self.eventType = eventType
        self.timestamp = timestamp
        self.expiryTime = expiryTime
        self.isActive = true
        self.isCompleted = false
        self.completedAt = nil
        self.eventData = eventData
    }

    // メソッド

    /// イベントを完了させる
    func complete() {
        isCompleted = true
        isActive = false
        completedAt = Date()
    }

    /// イベントを期限切れにする
    func expire() {
        isActive = false
    }

    /// イベントが有効かチェック
    func checkExpiry() -> Bool {
        if Date() > expiryTime && isActive {
            expire()
            return false
        }
        return isActive
    }

    // 計算プロパティ

    /// 残り時間（秒）
    var remainingTime: TimeInterval {
        return max(0, expiryTime.timeIntervalSince(Date()))
    }

    /// 残り時間の文字列表現
    var remainingTimeText: String {
        let minutes = Int(remainingTime / 60)
        if minutes > 60 {
            let hours = minutes / 60
            let mins = minutes % 60
            return "\(hours)時間\(mins)分"
        } else {
            return "\(minutes)分"
        }
    }

    /// イベントが期限切れか
    var isExpired: Bool {
        return Date() > expiryTime
    }

    /// イベントの説明文
    var description: String {
        switch eventType {
        case .rareShop:
            return "レアなアイテムを販売するショップが出現！\n通常価格の70〜80%で購入できます"
        case .eliteEnemy:
            return "強力な敵が出現！\n報酬は通常の3〜5倍です"
        case .treasureBox:
            return "宝箱を発見！\n戦闘なしでアイテムが手に入ります"
        case .merchant:
            return "行商人と遭遇！\n装備の売却や特別なアイテムと交換できます"
        }
    }

    /// イベントの通知タイトル
    var notificationTitle: String {
        switch eventType {
        case .rareShop:
            return "レアショップ出現！"
        case .eliteEnemy:
            return "強敵が現れた！"
        case .treasureBox:
            return "宝箱を発見！"
        case .merchant:
            return "行商人と遭遇！"
        }
    }

    /// イベントの通知本文
    var notificationBody: String {
        return description + "\n残り時間: \(remainingTimeText)"
    }
}

// MARK: - ランダムイベント生成ファクトリー
struct RandomEventFactory {
    /// ランダムイベントを生成（確率に基づく）
    static func generateRandomEvent() -> RandomEvent? {
        let roll = Double.random(in: 0...1)

        // 累積確率で判定
        if roll < GameBalance.merchantChance { // 3%
            return createMerchantEvent()
        } else if roll < GameBalance.merchantChance + GameBalance.rareShopChance { // 3% + 5% = 8%
            return createRareShopEvent()
        } else if roll < GameBalance.merchantChance + GameBalance.rareShopChance + GameBalance.treasureBoxChance { // 16%
            return createTreasureBoxEvent()
        } else if roll < GameBalance.merchantChance + GameBalance.rareShopChance + GameBalance.treasureBoxChance + GameBalance.eliteEnemyChance { // 26%
            return createEliteEnemyEvent()
        }

        return nil // イベント発生しない
    }

    /// レアショップイベントを生成
    static func createRareShopEvent() -> RandomEvent {
        let expiryTime = Date().addingTimeInterval(1800) // 30分後
        return RandomEvent(
            eventType: .rareShop,
            expiryTime: expiryTime
        )
    }

    /// エリート敵イベントを生成
    static func createEliteEnemyEvent() -> RandomEvent {
        let expiryTime = Date().addingTimeInterval(3600) // 1時間後
        return RandomEvent(
            eventType: .eliteEnemy,
            expiryTime: expiryTime
        )
    }

    /// 宝箱イベントを生成
    static func createTreasureBoxEvent() -> RandomEvent {
        let expiryTime = Date().addingTimeInterval(7200) // 2時間後

        // 宝箱の報酬をランダムに決定
        let goldReward = Int.random(in: 200...1000)
        let eventData = "{\"gold\": \(goldReward)}"

        return RandomEvent(
            eventType: .treasureBox,
            expiryTime: expiryTime,
            eventData: eventData
        )
    }

    /// 行商人イベントを生成
    static func createMerchantEvent() -> RandomEvent {
        let expiryTime = Date().addingTimeInterval(1800) // 30分後
        return RandomEvent(
            eventType: .merchant,
            expiryTime: expiryTime
        )
    }
}

// MARK: - イベントデータのデコードヘルパー
extension RandomEvent {
    /// 宝箱の報酬ゴールドを取得
    var treasureBoxGold: Int? {
        guard eventType == .treasureBox,
              let data = eventData,
              let jsonData = data.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let gold = json["gold"] as? Int else {
            return nil
        }
        return gold
    }
}
