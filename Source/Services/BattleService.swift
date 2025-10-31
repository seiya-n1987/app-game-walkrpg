//
//  BattleService.swift
//  WalkRPG
//
//  戦闘システムのロジックを管理
//

import Foundation

class BattleService {
    static let shared = BattleService()

    private init() {}

    // MARK: - 戦闘シミュレーション

    /// プレイヤーと敵の戦闘をシミュレート
    func simulateBattle(
        player: Player,
        enemy: Enemy,
        equippedWeapon: Equipment?,
        equippedArmor: Equipment?
    ) -> Battle {
        // プレイヤーのステータス
        let playerAttack = player.totalAttack(withWeapon: equippedWeapon)
        let playerDefense = player.totalDefense(withArmor: equippedArmor)
        var playerHP = player.currentHP

        // 敵のステータス
        var enemyHP = enemy.hp
        let enemyAttack = enemy.attack
        let enemyDefense = enemy.defense

        var turnLog: [BattleTurn] = []
        var turnNumber = 1

        // 戦闘ループ
        while playerHP > 0 && enemyHP > 0 {
            // プレイヤーの攻撃ターン
            let (playerDamage, isCritical) = calculateDamage(
                attack: playerAttack,
                defense: enemyDefense,
                canCritical: true
            )
            enemyHP -= playerDamage

            // 敵が倒れたらループ終了
            if enemyHP <= 0 {
                enemyHP = 0
                turnLog.append(BattleTurn(
                    turnNumber: turnNumber,
                    playerDamage: playerDamage,
                    enemyDamage: 0,
                    playerHP: playerHP,
                    enemyHP: enemyHP,
                    isCritical: isCritical,
                    isDodged: false
                ))
                break
            }

            // 敵の攻撃ターン
            let isDodged = GameBalance.rollDodge()
            let enemyDamage: Int
            if isDodged {
                enemyDamage = 0
            } else {
                (enemyDamage, _) = calculateDamage(
                    attack: enemyAttack,
                    defense: playerDefense,
                    canCritical: false
                )
            }
            playerHP -= enemyDamage

            // ターン記録
            turnLog.append(BattleTurn(
                turnNumber: turnNumber,
                playerDamage: playerDamage,
                enemyDamage: enemyDamage,
                playerHP: max(0, playerHP),
                enemyHP: enemyHP,
                isCritical: isCritical,
                isDodged: isDodged
            ))

            turnNumber += 1

            // 無限ループ防止（100ターン超えたら強制終了）
            if turnNumber > 100 {
                break
            }
        }

        // 戦闘結果
        let result: BattleResult = playerHP > 0 ? .victory : .defeat

        // 報酬計算
        let (goldEarned, expEarned) = calculateRewards(
            enemy: enemy,
            result: result,
            consecutiveWins: player.consecutiveWins
        )

        // ドロップ判定
        let droppedEquipmentId = rollEquipmentDrop(enemy: enemy, player: player)

        // 戦闘記録を作成
        return Battle(
            timestamp: Date(),
            enemy: enemy,
            playerLevel: player.level,
            playerMaxHP: player.maxHP,
            playerAttack: playerAttack,
            playerDefense: playerDefense,
            result: result,
            goldEarned: goldEarned,
            expEarned: expEarned,
            droppedEquipmentId: droppedEquipmentId,
            turnLog: turnLog
        )
    }

    /// 放置中の戦闘を処理
    func processIdleBattles(
        since lastBattleTime: Date,
        player: Player,
        equippedWeapon: Equipment?,
        equippedArmor: Equipment?
    ) -> [Battle] {
        let now = Date()
        let timeElapsed = now.timeIntervalSince(lastBattleTime)

        // 戦闘回数を計算
        let averageInterval = (GameBalance.battleIntervalMin + GameBalance.battleIntervalMax) / 2
        var battleCount = Int(timeElapsed / averageInterval)

        // 最大戦闘数を制限
        battleCount = min(battleCount, GameBalance.maxIdleBattles)

        guard battleCount > 0 else {
            return []
        }

        var battles: [Battle] = []

        for _ in 0..<battleCount {
            // ランダムイベント判定
            let enemy: Enemy
            if let randomEvent = RandomEventFactory.generateRandomEvent(),
               randomEvent.eventType == .eliteEnemy {
                enemy = EnemyFactory.generateEliteEnemy(basedOnPlayerLevel: player.level)
            } else {
                enemy = EnemyFactory.generateNormalEnemy(basedOnPlayerLevel: player.level)
            }

            // 戦闘シミュレート
            let battle = simulateBattle(
                player: player,
                enemy: enemy,
                equippedWeapon: equippedWeapon,
                equippedArmor: equippedArmor
            )

            battles.append(battle)
        }

        return battles
    }

    // MARK: - ダメージ計算

    /// ダメージを計算
    private func calculateDamage(
        attack: Int,
        defense: Int,
        canCritical: Bool
    ) -> (damage: Int, isCritical: Bool) {
        // 基本ダメージ = 攻撃力 - 防御力（最低1ダメージ）
        var damage = max(1, attack - defense)

        // クリティカル判定
        let isCritical = canCritical && GameBalance.rollCritical()
        if isCritical {
            damage = Int(Double(damage) * GameBalance.criticalDamageMultiplier)
        }

        return (damage, isCritical)
    }

    // MARK: - 報酬計算

    /// 戦闘報酬を計算
    private func calculateRewards(
        enemy: Enemy,
        result: BattleResult,
        consecutiveWins: Int
    ) -> (gold: Int, exp: Int) {
        if result == .victory {
            // 勝利時の報酬
            let baseGold = enemy.goldReward
            let baseExp = enemy.expReward

            // 連勝ボーナス
            let winStreakBonus = GameBalance.calculateWinStreakBonus(streak: consecutiveWins)
            let gold = Int(Double(baseGold) * (1.0 + winStreakBonus))
            let exp = Int(Double(baseExp) * (1.0 + winStreakBonus))

            return (gold, exp)
        } else {
            // 敗北時はゴールド損失のみ（経験値は0）
            return (0, 0)
        }
    }

    /// 装備ドロップ判定
    private func rollEquipmentDrop(enemy: Enemy, player: Player) -> UUID? {
        // ラッキースキルのボーナスを取得
        let luckyBonus = player.getSkillBonus(for: .lucky)

        // ドロップ判定
        guard GameBalance.rollEquipmentDrop(enemyType: enemy.type, luckyBonus: luckyBonus) else {
            return nil
        }

        // 敵のドロップテーブルからランダムに選択
        guard !enemy.dropTable.isEmpty else {
            return nil
        }

        // ドロップ率に基づいて選択
        let roll = Double.random(in: 0...1)
        var accumulatedRate = 0.0

        for drop in enemy.dropTable {
            accumulatedRate += drop.dropRate
            if roll <= accumulatedRate {
                return drop.equipmentId
            }
        }

        return nil
    }

    // MARK: - 戦闘後処理

    /// 戦闘後のHP回復を計算
    func calculateHPRecovery(player: Player) -> Int {
        let recoveryBonus = player.getSkillBonus(for: .recovery)
        return GameBalance.calculateHPRecovery(maxHP: player.maxHP, recoverySkillBonus: recoveryBonus)
    }

    /// 戦闘結果をプレイヤーに適用
    func applyBattleResults(
        battle: Battle,
        to player: Player
    ) {
        if battle.isVictory {
            // 勝利時
            player.addGold(battle.goldEarned)
            player.addExp(battle.expEarned)
            player.totalWins += 1
            player.consecutiveWins += 1

            // HP回復
            let recovery = calculateHPRecovery(player: player)
            player.heal(recovery)
        } else {
            // 敗北時
            let goldLoss = GameBalance.calculateGoldLoss(currentGold: player.gold)
            player.spendGold(goldLoss)
            player.totalLosses += 1
            player.consecutiveWins = 0

            // HPを半分まで回復
            player.currentHP = player.maxHP / 2
        }

        player.totalBattles += 1
        player.lastBattleTime = battle.timestamp
    }

    // MARK: - 戦闘予測

    /// 勝率を予測（簡易版）
    func estimateWinRate(
        playerAttack: Int,
        playerDefense: Int,
        playerHP: Int,
        enemy: Enemy
    ) -> Double {
        // 簡易的な勝率計算
        let playerPower = Double(playerAttack + playerDefense + playerHP)
        let enemyPower = Double(enemy.attack + enemy.defense + enemy.hp)

        let ratio = playerPower / enemyPower

        // 0.0〜1.0にクランプ
        return min(max(ratio / 2.0, 0.0), 1.0)
    }

    /// 予想ターン数を計算
    func estimateTurnCount(
        playerAttack: Int,
        playerDefense: Int,
        playerHP: Int,
        enemy: Enemy
    ) -> Int {
        let playerDamagePerTurn = max(1, playerAttack - enemy.defense)
        let enemyDamagePerTurn = max(1, enemy.attack - playerDefense)

        let turnsToKillEnemy = (enemy.hp + playerDamagePerTurn - 1) / playerDamagePerTurn
        let turnsToKillPlayer = (playerHP + enemyDamagePerTurn - 1) / enemyDamagePerTurn

        return min(turnsToKillEnemy, turnsToKillPlayer)
    }
}
