//
//  Enemy.swift
//  WalkRPG
//
//  敵のデータモデル
//

import Foundation

struct Enemy: Identifiable, Codable {
    // 基本情報
    var id: UUID
    var name: String
    var type: EnemyType

    // レベルとステータス
    var level: Int
    var hp: Int
    var attack: Int
    var defense: Int

    // 報酬
    var goldReward: Int
    var expReward: Int

    // ドロップ
    var dropTable: [EquipmentDrop]

    // UI
    var iconName: String
    var description: String

    // イニシャライザ
    init(
        id: UUID = UUID(),
        name: String,
        type: EnemyType,
        level: Int,
        hp: Int,
        attack: Int,
        defense: Int,
        goldReward: Int,
        expReward: Int,
        dropTable: [EquipmentDrop] = [],
        iconName: String,
        description: String = ""
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.level = level
        self.hp = hp
        self.attack = attack
        self.defense = defense
        self.goldReward = goldReward
        self.expReward = expReward
        self.dropTable = dropTable
        self.iconName = iconName
        self.description = description
    }
}

/// 装備ドロップ情報
struct EquipmentDrop: Codable, Identifiable {
    var id: UUID { equipmentId }
    var equipmentId: UUID
    var dropRate: Double // 0.0 〜 1.0

    init(equipmentId: UUID, dropRate: Double) {
        self.equipmentId = equipmentId
        self.dropRate = dropRate
    }
}

// MARK: - 敵生成ファクトリー
struct EnemyFactory {
    /// プレイヤーレベルに基づいて通常の敵を生成
    static func generateNormalEnemy(basedOnPlayerLevel playerLevel: Int) -> Enemy {
        let enemyLevel = max(1, playerLevel + Int.random(in: -2...2))
        let enemies = getNormalEnemyTemplates()
        let template = enemies.randomElement()!

        return createEnemyFromTemplate(template, level: enemyLevel, type: .normal)
    }

    /// プレイヤーレベルに基づいてエリート敵を生成
    static func generateEliteEnemy(basedOnPlayerLevel playerLevel: Int) -> Enemy {
        let enemyLevel = max(1, playerLevel + Int.random(in: 0...5))
        let enemies = getEliteEnemyTemplates()
        let template = enemies.randomElement()!

        return createEnemyFromTemplate(template, level: enemyLevel, type: .elite)
    }

    /// プレイヤーレベルに基づいてボスを生成
    static func generateBoss(basedOnPlayerLevel playerLevel: Int) -> Enemy {
        let enemyLevel = max(1, playerLevel + 10)
        let bosses = getBossTemplates()
        let template = bosses.randomElement()!

        return createEnemyFromTemplate(template, level: enemyLevel, type: .boss)
    }

    // プライベートメソッド

    private static func createEnemyFromTemplate(_ template: EnemyTemplate, level: Int, type: EnemyType) -> Enemy {
        // タイプによる倍率
        let multiplier: Double
        switch type {
        case .normal:
            multiplier = 1.0
        case .elite:
            multiplier = 2.5
        case .boss:
            multiplier = 5.0
        }

        // レベルによるスケーリング
        let levelScale = 1.0 + (Double(level - 1) * 0.15)

        let hp = Int(Double(template.baseHP) * levelScale * multiplier)
        let attack = Int(Double(template.baseAttack) * levelScale * multiplier)
        let defense = Int(Double(template.baseDefense) * levelScale * multiplier)
        let goldReward = Int(Double(template.baseGold) * levelScale * multiplier)
        let expReward = Int(Double(template.baseExp) * levelScale * multiplier)

        return Enemy(
            name: template.name,
            type: type,
            level: level,
            hp: hp,
            attack: attack,
            defense: defense,
            goldReward: goldReward,
            expReward: expReward,
            dropTable: template.drops,
            iconName: template.iconName,
            description: template.description
        )
    }

    // 敵テンプレート

    private static func getNormalEnemyTemplates() -> [EnemyTemplate] {
        return [
            EnemyTemplate(
                name: "スライム",
                baseHP: 30,
                baseAttack: 5,
                baseDefense: 2,
                baseGold: 10,
                baseExp: 15,
                iconName: "drop.fill",
                description: "最も基本的なモンスター"
            ),
            EnemyTemplate(
                name: "ゴブリン",
                baseHP: 50,
                baseAttack: 8,
                baseDefense: 3,
                baseGold: 20,
                baseExp: 25,
                iconName: "figure.walk",
                description: "小型の人型モンスター"
            ),
            EnemyTemplate(
                name: "オオカミ",
                baseHP: 40,
                baseAttack: 12,
                baseDefense: 2,
                baseGold: 15,
                baseExp: 20,
                iconName: "hare.fill",
                description: "素早い攻撃を得意とする"
            ),
            EnemyTemplate(
                name: "スケルトン",
                baseHP: 60,
                baseAttack: 10,
                baseDefense: 5,
                baseGold: 25,
                baseExp: 30,
                iconName: "figure.stand",
                description: "骨だけの戦士"
            ),
            EnemyTemplate(
                name: "オーク",
                baseHP: 80,
                baseAttack: 15,
                baseDefense: 8,
                baseGold: 40,
                baseExp: 45,
                iconName: "figure.arms.open",
                description: "力が強い人型モンスター"
            )
        ]
    }

    private static func getEliteEnemyTemplates() -> [EnemyTemplate] {
        return [
            EnemyTemplate(
                name: "キングスライム",
                baseHP: 30,
                baseAttack: 5,
                baseDefense: 2,
                baseGold: 10,
                baseExp: 15,
                iconName: "drop.fill",
                description: "スライムの王"
            ),
            EnemyTemplate(
                name: "ホブゴブリン",
                baseHP: 50,
                baseAttack: 8,
                baseDefense: 3,
                baseGold: 20,
                baseExp: 25,
                iconName: "figure.walk",
                description: "強化されたゴブリン"
            ),
            EnemyTemplate(
                name: "デスナイト",
                baseHP: 60,
                baseAttack: 10,
                baseDefense: 5,
                baseGold: 25,
                baseExp: 30,
                iconName: "figure.stand",
                description: "闇の騎士"
            ),
            EnemyTemplate(
                name: "ミノタウロス",
                baseHP: 80,
                baseAttack: 15,
                baseDefense: 8,
                baseGold: 40,
                baseExp: 45,
                iconName: "figure.arms.open",
                description: "牛頭の戦士"
            )
        ]
    }

    private static func getBossTemplates() -> [EnemyTemplate] {
        return [
            EnemyTemplate(
                name: "ドラゴン",
                baseHP: 100,
                baseAttack: 20,
                baseDefense: 15,
                baseGold: 100,
                baseExp: 200,
                iconName: "flame.fill",
                description: "炎を吐く古龍"
            ),
            EnemyTemplate(
                name: "デーモンロード",
                baseHP: 120,
                baseAttack: 25,
                baseDefense: 20,
                baseGold: 150,
                baseExp: 250,
                iconName: "bolt.fill",
                description: "魔界の支配者"
            ),
            EnemyTemplate(
                name: "古代の巨人",
                baseHP: 200,
                baseAttack: 18,
                baseDefense: 25,
                baseGold: 120,
                baseExp: 220,
                iconName: "mountain.2.fill",
                description: "太古に封印された巨人"
            )
        ]
    }
}

// MARK: - 敵テンプレート構造体
private struct EnemyTemplate {
    let name: String
    let baseHP: Int
    let baseAttack: Int
    let baseDefense: Int
    let baseGold: Int
    let baseExp: Int
    let iconName: String
    let description: String
    let drops: [EquipmentDrop]

    init(
        name: String,
        baseHP: Int,
        baseAttack: Int,
        baseDefense: Int,
        baseGold: Int,
        baseExp: Int,
        iconName: String,
        description: String,
        drops: [EquipmentDrop] = []
    ) {
        self.name = name
        self.baseHP = baseHP
        self.baseAttack = baseAttack
        self.baseDefense = baseDefense
        self.baseGold = baseGold
        self.baseExp = baseExp
        self.iconName = iconName
        self.description = description
        self.drops = drops
    }
}
