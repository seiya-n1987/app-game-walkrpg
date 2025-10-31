//
//  Enums.swift
//  WalkRPG
//
//  共通で使用する列挙型の定義
//

import Foundation

/// 装備の種類
enum EquipmentType: String, Codable, CaseIterable {
    case weapon   // 武器
    case armor    // 防具
    case accessory // アクセサリー

    var displayName: String {
        switch self {
        case .weapon: return "武器"
        case .armor: return "防具"
        case .accessory: return "アクセサリー"
        }
    }
}

/// 装備のレア度
enum Rarity: String, Codable, CaseIterable {
    case common    // 一般
    case rare      // レア
    case epic      // エピック
    case legendary // レジェンド

    var displayName: String {
        switch self {
        case .common: return "一般"
        case .rare: return "レア"
        case .epic: return "エピック"
        case .legendary: return "レジェンド"
        }
    }

    var color: String {
        switch self {
        case .common: return "gray"
        case .rare: return "blue"
        case .epic: return "purple"
        case .legendary: return "orange"
        }
    }
}

/// 敵のタイプ
enum EnemyType: String, Codable {
    case normal    // 通常の敵
    case elite     // エリート（強敵）
    case boss      // ボス

    var displayName: String {
        switch self {
        case .normal: return "通常"
        case .elite: return "エリート"
        case .boss: return "ボス"
        }
    }
}

/// 戦闘結果
enum BattleResult: String, Codable {
    case victory   // 勝利
    case defeat    // 敗北

    var displayName: String {
        switch self {
        case .victory: return "勝利"
        case .defeat: return "敗北"
        }
    }
}

/// デイリーミッションの種類
enum MissionType: String, Codable {
    case steps              // 歩数達成
    case battles            // 戦闘回数
    case wins               // 勝利回数
    case consecutiveWins    // 連勝
    case levelUp            // レベルアップ
    case purchaseEquipment  // 装備購入
    case upgradeSkill       // スキル強化

    var displayName: String {
        switch self {
        case .steps: return "歩数"
        case .battles: return "戦闘"
        case .wins: return "勝利"
        case .consecutiveWins: return "連勝"
        case .levelUp: return "レベルアップ"
        case .purchaseEquipment: return "装備購入"
        case .upgradeSkill: return "スキル強化"
        }
    }
}

/// スキルの種類
enum SkillType: String, Codable, CaseIterable {
    case powerAttack   // 攻撃力ボーナス
    case ironDefense   // 防御力ボーナス
    case recovery      // HP回復量ボーナス
    case lucky         // ドロップ率ボーナス

    var displayName: String {
        switch self {
        case .powerAttack: return "パワーアタック"
        case .ironDefense: return "鉄壁"
        case .recovery: return "回復"
        case .lucky: return "ラッキー"
        }
    }

    var description: String {
        switch self {
        case .powerAttack: return "攻撃力が上昇します"
        case .ironDefense: return "防御力が上昇します"
        case .recovery: return "戦闘後のHP回復量が上昇します"
        case .lucky: return "アイテムのドロップ率が上昇します"
        }
    }

    var bonusPerLevel: Double {
        switch self {
        case .powerAttack: return 0.05  // 5%
        case .ironDefense: return 0.05  // 5%
        case .recovery: return 0.10     // 10%
        case .lucky: return 0.05        // 5%
        }
    }
}

/// ランダムイベントの種類
enum RandomEventType: String, Codable {
    case rareShop      // レアショップ出現
    case eliteEnemy    // 強敵出現
    case treasureBox   // 宝箱発見
    case merchant      // 行商人との遭遇

    var displayName: String {
        switch self {
        case .rareShop: return "レアショップ"
        case .eliteEnemy: return "強敵出現"
        case .treasureBox: return "宝箱発見"
        case .merchant: return "行商人"
        }
    }

    var iconName: String {
        switch self {
        case .rareShop: return "cart.fill"
        case .eliteEnemy: return "exclamationmark.triangle.fill"
        case .treasureBox: return "gift.fill"
        case .merchant: return "person.fill"
        }
    }
}
