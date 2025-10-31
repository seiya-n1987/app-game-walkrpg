//
//  Equipment.swift
//  WalkRPG
//
//  装備のデータモデル
//

import Foundation
import SwiftData

@Model
class Equipment {
    // 基本情報
    var id: UUID
    var name: String
    var type: EquipmentType
    var rarity: Rarity

    // ステータスボーナス
    var attackBonus: Int
    var defenseBonus: Int

    // 経済
    var price: Int
    var sellPrice: Int // 売却価格

    // 説明
    var description: String
    var specialEffect: String? // 特殊効果（例: "goldBonus20", "expBonus20"）

    // UI
    var iconName: String

    // 所持状況
    var isOwned: Bool
    var isEquipped: Bool
    var quantity: Int // 所持数（同じ装備を複数持つことはないが、将来の拡張用）

    // 入手情報
    var acquiredAt: Date?

    // イニシャライザ
    init(
        id: UUID = UUID(),
        name: String,
        type: EquipmentType,
        rarity: Rarity,
        attackBonus: Int = 0,
        defenseBonus: Int = 0,
        price: Int,
        description: String,
        specialEffect: String? = nil,
        iconName: String,
        isOwned: Bool = false
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.rarity = rarity
        self.attackBonus = attackBonus
        self.defenseBonus = defenseBonus
        self.price = price
        self.sellPrice = price / 2 // 売却価格は購入価格の50%
        self.description = description
        self.specialEffect = specialEffect
        self.iconName = iconName
        self.isOwned = isOwned
        self.isEquipped = false
        self.quantity = isOwned ? 1 : 0
        self.acquiredAt = isOwned ? Date() : nil
    }

    // メソッド

    /// 装備を購入
    func purchase() {
        isOwned = true
        quantity = 1
        acquiredAt = Date()
    }

    /// 装備を売却
    func sell() {
        isOwned = false
        isEquipped = false
        quantity = 0
        acquiredAt = nil
    }

    /// 装備する
    func equip() {
        guard isOwned else { return }
        isEquipped = true
    }

    /// 装備を外す
    func unequip() {
        isEquipped = false
    }

    // 計算プロパティ

    /// 総ステータスボーナス
    var totalBonus: Int {
        return attackBonus + defenseBonus
    }

    /// レア度による価格補正
    var rarityMultiplier: Double {
        switch rarity {
        case .common: return 1.0
        case .rare: return 2.0
        case .epic: return 4.0
        case .legendary: return 8.0
        }
    }

    /// 特殊効果の説明文
    var specialEffectDescription: String? {
        guard let effect = specialEffect else { return nil }

        if effect.hasPrefix("goldBonus") {
            let value = effect.replacingOccurrences(of: "goldBonus", with: "")
            return "ゴールド獲得量 +\(value)%"
        } else if effect.hasPrefix("expBonus") {
            let value = effect.replacingOccurrences(of: "expBonus", with: "")
            return "経験値獲得量 +\(value)%"
        } else if effect.hasPrefix("dropRateBonus") {
            let value = effect.replacingOccurrences(of: "dropRateBonus", with: "")
            return "アイテムドロップ率 +\(value)%"
        } else if effect.hasPrefix("criticalBonus") {
            let value = effect.replacingOccurrences(of: "criticalBonus", with: "")
            return "クリティカル率 +\(value)%"
        }

        return effect
    }
}

// MARK: - 装備生成ファクトリー
struct EquipmentFactory {
    /// 武器を生成
    static func createWeapon(
        name: String,
        rarity: Rarity,
        attackBonus: Int,
        price: Int,
        description: String = "",
        specialEffect: String? = nil
    ) -> Equipment {
        return Equipment(
            name: name,
            type: .weapon,
            rarity: rarity,
            attackBonus: attackBonus,
            defenseBonus: 0,
            price: price,
            description: description,
            specialEffect: specialEffect,
            iconName: "figure.fencing"
        )
    }

    /// 防具を生成
    static func createArmor(
        name: String,
        rarity: Rarity,
        defenseBonus: Int,
        price: Int,
        description: String = "",
        specialEffect: String? = nil
    ) -> Equipment {
        return Equipment(
            name: name,
            type: .armor,
            rarity: rarity,
            attackBonus: 0,
            defenseBonus: defenseBonus,
            price: price,
            description: description,
            specialEffect: specialEffect,
            iconName: "shield.fill"
        )
    }

    /// アクセサリーを生成
    static func createAccessory(
        name: String,
        rarity: Rarity,
        price: Int,
        description: String,
        specialEffect: String
    ) -> Equipment {
        return Equipment(
            name: name,
            type: .accessory,
            rarity: rarity,
            attackBonus: 0,
            defenseBonus: 0,
            price: price,
            description: description,
            specialEffect: specialEffect,
            iconName: "star.fill"
        )
    }
}

// MARK: - デフォルト装備データ
extension EquipmentFactory {
    /// ゲーム開始時の初期装備データ
    static func getDefaultEquipment() -> [Equipment] {
        return [
            // 武器
            createWeapon(name: "木の棒", rarity: .common, attackBonus: 5, price: 100,
                        description: "初心者向けの簡素な武器"),
            createWeapon(name: "鉄の剣", rarity: .common, attackBonus: 15, price: 500,
                        description: "標準的な鉄製の剣"),
            createWeapon(name: "鋼の剣", rarity: .rare, attackBonus: 30, price: 2000,
                        description: "質の高い鋼で作られた剣"),
            createWeapon(name: "炎の剣", rarity: .epic, attackBonus: 50, price: 5000,
                        description: "炎の魔力が宿る剣", specialEffect: "criticalBonus10"),
            createWeapon(name: "伝説の聖剣", rarity: .legendary, attackBonus: 100, price: 20000,
                        description: "伝説の英雄が使ったと言われる聖剣"),

            // 防具
            createArmor(name: "布の服", rarity: .common, defenseBonus: 3, price: 100,
                       description: "簡素な布製の服"),
            createArmor(name: "革の鎧", rarity: .common, defenseBonus: 10, price: 500,
                       description: "丈夫な革でできた鎧"),
            createArmor(name: "鋼の鎧", rarity: .rare, defenseBonus: 20, price: 2000,
                       description: "重厚な鋼鉄の鎧"),
            createArmor(name: "ドラゴンアーマー", rarity: .epic, defenseBonus: 40, price: 5000,
                       description: "ドラゴンの鱗で作られた鎧"),
            createArmor(name: "神聖なる鎧", rarity: .legendary, defenseBonus: 80, price: 20000,
                       description: "神々の加護を受けた鎧"),

            // アクセサリー
            createAccessory(name: "幸運の指輪", rarity: .rare, price: 1000,
                          description: "ゴールド獲得量が増加する指輪",
                          specialEffect: "goldBonus20"),
            createAccessory(name: "経験値のお守り", rarity: .rare, price: 1000,
                          description: "経験値獲得量が増加するお守り",
                          specialEffect: "expBonus20"),
            createAccessory(name: "ドロップ率の腕輪", rarity: .epic, price: 3000,
                          description: "アイテムドロップ率が上昇する腕輪",
                          specialEffect: "dropRateBonus30"),
            createAccessory(name: "勇者のペンダント", rarity: .legendary, price: 10000,
                          description: "全ての報酬が大幅に増加する",
                          specialEffect: "goldBonus50_expBonus50")
        ]
    }
}
