//
//  GameBalance.swift
//  WalkRPG
//
//  ゲームバランスに関する定数
//  ここで値を調整することでゲーム全体のバランスを変更できます
//

import Foundation

struct GameBalance {
    // MARK: - レベルアップ

    /// レベルアップの基礎経験値
    static let baseExpForLevel: Double = 100.0

    /// 経験値の成長率（指数）
    static let expGrowthRate: Double = 1.5

    // MARK: - ステータス成長

    /// レベルアップ時のHP上昇量
    static let hpPerLevel: Int = 10

    /// レベルアップ時の攻撃力上昇量
    static let attackPerLevel: Int = 2

    /// レベルアップ時の防御力上昇量
    static let defensePerLevel: Int = 1

    // MARK: - 歩数システム

    /// 1歩あたりの経験値
    static let expPerStep: Int = 1

    /// デイリー目標歩数
    static let dailyStepGoal: Int = 10000

    /// 歩数マイルストーン
    static let stepMilestones: [(steps: Int, gold: Int, exp: Int, special: String?)] = [
        (1000, 100, 0, nil),
        (3000, 300, 500, nil),
        (5000, 500, 0, "gachaTicket"),
        (8000, 1000, 0, "rareItemBoost"),
        (10000, 0, 0, "goldBonus2x"),
        (15000, 500, 0, nil)
    ]

    // MARK: - 戦闘システム

    /// 最小戦闘間隔（秒）
    static let battleIntervalMin: TimeInterval = 600.0  // 10分

    /// 最大戦闘間隔（秒）
    static let battleIntervalMax: TimeInterval = 900.0  // 15分

    /// 最大放置戦闘数（8時間分）
    static let maxIdleBattles: Int = 48

    /// クリティカルヒット確率
    static let criticalHitChance: Double = 0.10  // 10%

    /// クリティカルダメージ倍率
    static let criticalDamageMultiplier: Double = 1.5

    /// 回避確率
    static let dodgeChance: Double = 0.05  // 5%

    /// 敗北時のゴールド損失率
    static let goldLossOnDefeat: Double = 0.1  // 10%

    /// 連勝ボーナス倍率（連勝数ごと）
    static let winStreakBonusMultiplier: Double = 0.05  // 5% per streak

    /// 最大連勝ボーナス倍率
    static let maxWinStreakBonus: Double = 0.50  // 50%

    // MARK: - ランダムイベント確率

    /// レアショップ出現確率
    static let rareShopChance: Double = 0.05  // 5%

    /// エリート敵出現確率
    static let eliteEnemyChance: Double = 0.10  // 10%

    /// 宝箱発見確率
    static let treasureBoxChance: Double = 0.08  // 8%

    /// 行商人遭遇確率
    static let merchantChance: Double = 0.03  // 3%

    // MARK: - ドロップ率

    /// 基本装備ドロップ率
    static let baseEquipmentDropRate: Double = 0.05  // 5%

    /// エリート敵からのドロップ率
    static let eliteDropRate: Double = 0.30  // 30%

    /// ボスからのドロップ率
    static let bossDropRate: Double = 0.80  // 80%

    // MARK: - ショップ

    /// レアショップの割引率
    static let rareShopDiscount: Double = 0.25  // 25%オフ

    /// 装備売却価格（購入価格の割合）
    static let equipmentSellPriceRatio: Double = 0.50  // 50%

    // MARK: - HP回復

    /// 戦闘後のHP回復率
    static let hpRecoveryAfterBattle: Double = 0.10  // 10%

    /// HP回復の最小値
    static let minHPRecovery: Int = 5

    // MARK: - バックグラウンド

    /// バックグラウンドタスクの間隔（秒）
    static let backgroundTaskInterval: TimeInterval = 600.0  // 10分

    /// 最大放置時間（秒）
    static let maxIdleTime: TimeInterval = 28800.0  // 8時間

    // MARK: - 通知

    /// レベルアップ通知の有効化
    static let enableLevelUpNotification: Bool = true

    /// イベント通知の有効化
    static let enableEventNotification: Bool = true

    /// デイリーミッション通知の有効化
    static let enableMissionNotification: Bool = true

    // MARK: - その他

    /// 初期ゴールド
    static let initialGold: Int = 500

    /// 初期HP
    static let initialHP: Int = 100

    /// 初期攻撃力
    static let initialAttack: Int = 10

    /// 初期防御力
    static let initialDefense: Int = 5

    /// デバッグモード（開発時にtrueにすると高速化）
    static let debugMode: Bool = false

    /// デバッグモード時の戦闘間隔（秒）
    static let debugBattleInterval: TimeInterval = 30.0  // 30秒
}

// MARK: - バランス調整ヘルパー
extension GameBalance {
    /// 戦闘間隔をランダムに取得
    static func randomBattleInterval() -> TimeInterval {
        if debugMode {
            return debugBattleInterval
        }
        return TimeInterval.random(in: battleIntervalMin...battleIntervalMax)
    }

    /// 連勝ボーナス倍率を計算
    static func calculateWinStreakBonus(streak: Int) -> Double {
        let bonus = Double(streak) * winStreakBonusMultiplier
        return min(bonus, maxWinStreakBonus)
    }

    /// 戦闘後のHP回復量を計算
    static func calculateHPRecovery(maxHP: Int, recoverySkillBonus: Double) -> Int {
        let baseRecovery = Int(Double(maxHP) * hpRecoveryAfterBattle)
        let withBonus = Int(Double(baseRecovery) * (1.0 + recoverySkillBonus))
        return max(withBonus, minHPRecovery)
    }

    /// 敗北時のゴールド損失額を計算
    static func calculateGoldLoss(currentGold: Int) -> Int {
        return Int(Double(currentGold) * goldLossOnDefeat)
    }

    /// クリティカルヒット判定
    static func rollCritical(bonusChance: Double = 0.0) -> Bool {
        return Double.random(in: 0...1) < (criticalHitChance + bonusChance)
    }

    /// 回避判定
    static func rollDodge(bonusChance: Double = 0.0) -> Bool {
        return Double.random(in: 0...1) < (dodgeChance + bonusChance)
    }

    /// 装備ドロップ判定
    static func rollEquipmentDrop(enemyType: EnemyType, luckyBonus: Double = 0.0) -> Bool {
        let baseRate: Double
        switch enemyType {
        case .normal:
            baseRate = baseEquipmentDropRate
        case .elite:
            baseRate = eliteDropRate
        case .boss:
            baseRate = bossDropRate
        }

        let totalRate = baseRate + luckyBonus
        return Double.random(in: 0...1) < totalRate
    }
}
