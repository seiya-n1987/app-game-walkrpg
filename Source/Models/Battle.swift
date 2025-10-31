//
//  Battle.swift
//  WalkRPG
//
//  戦闘のデータモデル
//

import Foundation
import SwiftData

@Model
class Battle {
    // 基本情報
    var id: UUID
    var timestamp: Date

    // 敵情報（保存用にCodableデータとして保持）
    var enemyData: Data // Enemyをエンコードしたもの

    // プレイヤー情報（戦闘時点）
    var playerLevel: Int
    var playerMaxHP: Int
    var playerAttack: Int
    var playerDefense: Int

    // 戦闘結果
    var result: BattleResult
    var goldEarned: Int
    var expEarned: Int
    var droppedEquipmentId: UUID?

    // 戦闘ログ
    var turnLogData: Data // [BattleTurn]をエンコードしたもの
    var totalTurns: Int
    var damageDealt: Int // 与えたダメージ総量
    var damageTaken: Int // 受けたダメージ総量

    // イニシャライザ
    init(
        timestamp: Date = Date(),
        enemy: Enemy,
        playerLevel: Int,
        playerMaxHP: Int,
        playerAttack: Int,
        playerDefense: Int,
        result: BattleResult,
        goldEarned: Int,
        expEarned: Int,
        droppedEquipmentId: UUID? = nil,
        turnLog: [BattleTurn]
    ) {
        self.id = UUID()
        self.timestamp = timestamp

        // Enemyをエンコード
        self.enemyData = (try? JSONEncoder().encode(enemy)) ?? Data()

        self.playerLevel = playerLevel
        self.playerMaxHP = playerMaxHP
        self.playerAttack = playerAttack
        self.playerDefense = playerDefense

        self.result = result
        self.goldEarned = goldEarned
        self.expEarned = expEarned
        self.droppedEquipmentId = droppedEquipmentId

        // TurnLogをエンコード
        self.turnLogData = (try? JSONEncoder().encode(turnLog)) ?? Data()
        self.totalTurns = turnLog.count

        // ダメージ総量を計算
        self.damageDealt = turnLog.reduce(0) { $0 + $1.playerDamage }
        self.damageTaken = turnLog.reduce(0) { $0 + $1.enemyDamage }
    }

    // デコード用の計算プロパティ

    var enemy: Enemy? {
        try? JSONDecoder().decode(Enemy.self, from: enemyData)
    }

    var turnLog: [BattleTurn] {
        (try? JSONDecoder().decode([BattleTurn].self, from: turnLogData)) ?? []
    }

    // 便利プロパティ

    var isVictory: Bool {
        result == .victory
    }

    var resultEmoji: String {
        isVictory ? "🏆" : "💀"
    }

    var resultColor: String {
        isVictory ? "green" : "red"
    }
}

/// 戦闘の1ターンのデータ
struct BattleTurn: Codable {
    var turnNumber: Int
    var playerDamage: Int    // プレイヤーが与えたダメージ
    var enemyDamage: Int     // 敵が与えたダメージ
    var playerHP: Int        // ターン終了時のプレイヤーHP
    var enemyHP: Int         // ターン終了時の敵HP
    var isCritical: Bool     // クリティカルヒット
    var isDodged: Bool       // 回避

    init(
        turnNumber: Int,
        playerDamage: Int,
        enemyDamage: Int,
        playerHP: Int,
        enemyHP: Int,
        isCritical: Bool = false,
        isDodged: Bool = false
    ) {
        self.turnNumber = turnNumber
        self.playerDamage = playerDamage
        self.enemyDamage = enemyDamage
        self.playerHP = playerHP
        self.enemyHP = enemyHP
        self.isCritical = isCritical
        self.isDodged = isDodged
    }
}

// MARK: - 戦闘統計
extension Battle {
    /// 平均ターンダメージ
    var averageDamagePerTurn: Double {
        guard totalTurns > 0 else { return 0 }
        return Double(damageDealt) / Double(totalTurns)
    }

    /// 戦闘時間（推定、1ターン = 1秒）
    var estimatedDuration: TimeInterval {
        return Double(totalTurns)
    }

    /// 戦闘の説明文
    var battleDescription: String {
        if let enemy = enemy {
            let result = isVictory ? "を倒した！" : "に敗北..."
            return "\(enemy.name) Lv.\(enemy.level) \(result)"
        }
        return "不明な戦闘"
    }

    /// 短い説明文
    var shortDescription: String {
        guard let enemy = enemy else { return "戦闘記録" }
        return "\(resultEmoji) \(enemy.name) Lv.\(enemy.level)"
    }
}
