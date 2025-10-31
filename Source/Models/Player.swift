//
//  Player.swift
//  WalkRPG
//
//  プレイヤーのデータモデル
//

import Foundation
import SwiftData

@Model
class Player {
    // 基本情報
    var id: UUID
    var name: String
    var createdAt: Date

    // ステータス
    var level: Int
    var currentExp: Int
    var maxHP: Int
    var currentHP: Int
    var baseAttack: Int
    var baseDefense: Int

    // 通貨
    var gold: Int

    // 歩数
    var totalSteps: Int
    var todaySteps: Int
    var lastStepUpdate: Date
    var yesterdaySteps: Int // 前日の歩数（デイリーリセット用）

    // 装備（オプショナル）
    var equippedWeaponId: UUID?
    var equippedArmorId: UUID?
    var equippedAccessoryId: UUID?

    // スキル
    var skillPoints: Int
    var skills: [PlayerSkill]

    // 統計情報
    var totalBattles: Int
    var totalWins: Int
    var totalLosses: Int
    var consecutiveWins: Int
    var highestLevel: Int
    var totalGoldEarned: Int

    // 放置システム
    var lastBattleTime: Date
    var lastAppOpenTime: Date

    // 実績・進行状況
    var unlockedAchievements: [String]
    var currentArea: Int // エリア番号（将来の拡張用）

    // イニシャライザ
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.createdAt = Date()

        // 初期ステータス
        self.level = 1
        self.currentExp = 0
        self.maxHP = 100
        self.currentHP = 100
        self.baseAttack = 10
        self.baseDefense = 5

        self.gold = 0

        self.totalSteps = 0
        self.todaySteps = 0
        self.lastStepUpdate = Date()
        self.yesterdaySteps = 0

        self.equippedWeaponId = nil
        self.equippedArmorId = nil
        self.equippedAccessoryId = nil

        self.skillPoints = 0
        self.skills = []

        self.totalBattles = 0
        self.totalWins = 0
        self.totalLosses = 0
        self.consecutiveWins = 0
        self.highestLevel = 1
        self.totalGoldEarned = 0

        self.lastBattleTime = Date()
        self.lastAppOpenTime = Date()

        self.unlockedAchievements = []
        self.currentArea = 1
    }

    // 計算プロパティ

    /// 次のレベルまでに必要な経験値
    var expToNextLevel: Int {
        LevelCalculator.expForLevel(level + 1) - currentExp
    }

    /// 現在のレベルの開始経験値
    var currentLevelStartExp: Int {
        LevelCalculator.expForLevel(level)
    }

    /// 次のレベルの開始経験値
    var nextLevelStartExp: Int {
        LevelCalculator.expForLevel(level + 1)
    }

    /// 現在のレベルでの進捗（0.0〜1.0）
    var levelProgress: Double {
        let currentLevelExp = currentExp - currentLevelStartExp
        let expNeeded = nextLevelStartExp - currentLevelStartExp
        return Double(currentLevelExp) / Double(expNeeded)
    }

    /// HP割合（0.0〜1.0）
    var hpPercentage: Double {
        return Double(currentHP) / Double(maxHP)
    }

    // スキルボーナスを考慮した実際のステータス

    /// 総攻撃力（基礎 + 装備 + スキル）
    func totalAttack(withWeapon weapon: Equipment?) -> Int {
        let baseWithEquipment = baseAttack + (weapon?.attackBonus ?? 0)
        let skillBonus = getSkillBonus(for: .powerAttack)
        return Int(Double(baseWithEquipment) * (1.0 + skillBonus))
    }

    /// 総防御力（基礎 + 装備 + スキル）
    func totalDefense(withArmor armor: Equipment?) -> Int {
        let baseWithEquipment = baseDefense + (armor?.defenseBonus ?? 0)
        let skillBonus = getSkillBonus(for: .ironDefense)
        return Int(Double(baseWithEquipment) * (1.0 + skillBonus))
    }

    /// 指定したスキルのボーナス値を取得
    func getSkillBonus(for skillType: SkillType) -> Double {
        guard let skill = skills.first(where: { $0.skillType == skillType }) else {
            return 0.0
        }
        return Double(skill.level) * skillType.bonusPerLevel
    }

    // メソッド

    /// レベルアップ処理
    func levelUp() {
        level += 1
        maxHP += GameBalance.hpPerLevel
        baseAttack += GameBalance.attackPerLevel
        baseDefense += GameBalance.defensePerLevel
        skillPoints += 1
        currentHP = maxHP // 全回復

        if level > highestLevel {
            highestLevel = level
        }
    }

    /// ダメージを受ける
    func takeDamage(_ damage: Int) {
        currentHP = max(0, currentHP - damage)
    }

    /// 回復
    func heal(_ amount: Int) {
        currentHP = min(maxHP, currentHP + amount)
    }

    /// HP全回復
    func fullHeal() {
        currentHP = maxHP
    }

    /// ゴールドを追加
    func addGold(_ amount: Int) {
        gold += amount
        totalGoldEarned += amount
    }

    /// ゴールドを消費（不足していればfalseを返す）
    @discardableResult
    func spendGold(_ amount: Int) -> Bool {
        guard gold >= amount else {
            return false
        }
        gold -= amount
        return true
    }

    /// 歩数を追加
    func addSteps(_ steps: Int) {
        totalSteps += steps
        todaySteps += steps
        lastStepUpdate = Date()
    }

    /// 経験値を追加（レベルアップチェック含む）
    func addExp(_ exp: Int) {
        currentExp += exp

        // レベルアップチェック
        while currentExp >= nextLevelStartExp {
            levelUp()
        }
    }

    /// デイリーリセット（日付が変わった時）
    func resetDaily() {
        yesterdaySteps = todaySteps
        todaySteps = 0
    }

    /// スキルをレベルアップ
    @discardableResult
    func upgradeSkill(_ skillType: SkillType) -> Bool {
        guard skillPoints > 0 else {
            return false
        }

        if let index = skills.firstIndex(where: { $0.skillType == skillType }) {
            guard skills[index].level < skills[index].maxLevel else {
                return false // 最大レベル
            }
            skills[index].level += 1
        } else {
            // 新しいスキルを追加
            skills.append(PlayerSkill(skillType: skillType, level: 1))
        }

        skillPoints -= 1
        return true
    }
}

// MARK: - レベル計算ユーティリティ
struct LevelCalculator {
    /// レベルnに到達するために必要な累計経験値
    static func expForLevel(_ level: Int) -> Int {
        if level <= 1 {
            return 0
        }
        // 指数関数的な成長: 100 * (level - 1) ^ 1.5
        return Int(GameBalance.baseExpForLevel * pow(Double(level - 1), GameBalance.expGrowthRate))
    }

    /// 経験値からレベルを計算
    static func calculateLevel(exp: Int) -> Int {
        var level = 1
        while exp >= expForLevel(level + 1) {
            level += 1
        }
        return level
    }
}
