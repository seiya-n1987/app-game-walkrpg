//
//  PlayerSkill.swift
//  WalkRPG
//
//  プレイヤースキルのデータモデル
//

import Foundation

struct PlayerSkill: Codable, Identifiable {
    var id: UUID
    var skillType: SkillType
    var level: Int
    var maxLevel: Int

    init(
        id: UUID = UUID(),
        skillType: SkillType,
        level: Int,
        maxLevel: Int = 10
    ) {
        self.id = id
        self.skillType = skillType
        self.level = level
        self.maxLevel = maxLevel
    }

    // 計算プロパティ

    /// スキルによる現在のボーナス値
    var currentBonus: Double {
        return Double(level) * skillType.bonusPerLevel
    }

    /// 次のレベルでのボーナス値
    var nextLevelBonus: Double {
        guard level < maxLevel else { return currentBonus }
        return Double(level + 1) * skillType.bonusPerLevel
    }

    /// 最大レベルに到達しているか
    var isMaxLevel: Bool {
        return level >= maxLevel
    }

    /// レベルアップに必要なスキルポイント
    var requiredSkillPoints: Int {
        return 1
    }

    /// スキルの進捗率（0.0〜1.0）
    var progressPercentage: Double {
        return Double(level) / Double(maxLevel)
    }

    /// スキルレベルの表示文字列
    var levelText: String {
        return "Lv.\(level)/\(maxLevel)"
    }

    /// ボーナスの表示文字列
    var bonusText: String {
        let percentage = Int(currentBonus * 100)
        switch skillType {
        case .powerAttack:
            return "+\(percentage)% 攻撃力"
        case .ironDefense:
            return "+\(percentage)% 防御力"
        case .recovery:
            return "+\(percentage)% HP回復"
        case .lucky:
            return "+\(percentage)% ドロップ率"
        }
    }

    /// 次のレベルのボーナス表示文字列
    var nextLevelBonusText: String {
        guard !isMaxLevel else { return "最大レベル" }
        let percentage = Int(nextLevelBonus * 100)
        return "→ +\(percentage)%"
    }
}

// MARK: - スキル管理ヘルパー
struct SkillManager {
    /// 全スキルタイプの初期状態を生成
    static func createInitialSkills() -> [PlayerSkill] {
        return SkillType.allCases.map { skillType in
            PlayerSkill(skillType: skillType, level: 0, maxLevel: 10)
        }
    }

    /// スキルレベルアップ可能かチェック
    static func canUpgradeSkill(_ skill: PlayerSkill, availablePoints: Int) -> Bool {
        return !skill.isMaxLevel && availablePoints >= skill.requiredSkillPoints
    }

    /// スキル強化の推奨度を計算（簡易的なAIアドバイス用）
    static func recommendSkill(
        skills: [PlayerSkill],
        playerLevel: Int,
        currentArea: Int
    ) -> SkillType? {
        // 低レベル: 攻撃力重視
        if playerLevel < 10 {
            return .powerAttack
        }
        // 中レベル: 防御力と攻撃力のバランス
        else if playerLevel < 30 {
            let powerAttackSkill = skills.first { $0.skillType == .powerAttack }
            let ironDefenseSkill = skills.first { $0.skillType == .ironDefense }

            if let power = powerAttackSkill, let defense = ironDefenseSkill {
                return power.level > defense.level ? .ironDefense : .powerAttack
            }
            return .ironDefense
        }
        // 高レベル: ラッキーで装備集め
        else {
            let luckySkill = skills.first { $0.skillType == .lucky }
            if let lucky = luckySkill, lucky.level < 5 {
                return .lucky
            }
            return .recovery
        }
    }

    /// 全スキルの総レベルを計算
    static func totalSkillLevel(skills: [PlayerSkill]) -> Int {
        return skills.reduce(0) { $0 + $1.level }
    }

    /// 特定スキルのレベルを取得
    static func getSkillLevel(skills: [PlayerSkill], skillType: SkillType) -> Int {
        return skills.first { $0.skillType == skillType }?.level ?? 0
    }
}
