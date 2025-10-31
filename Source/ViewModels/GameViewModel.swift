//
//  GameViewModel.swift
//  WalkRPG
//
//  ゲーム全体の状態を管理するメインViewModel
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
class GameViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var player: Player
    @Published var equipmentList: [Equipment] = []
    @Published var battleLog: [Battle] = []
    @Published var dailyMissions: [DailyMission] = []
    @Published var activeRandomEvents: [RandomEvent] = []

    @Published var todaySteps: Int = 0
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Services

    private let healthKitService = HealthKitService.shared
    private let battleService = BattleService.shared
    private let notificationService = NotificationService.shared

    // MARK: - Computed Properties

    var equippedWeapon: Equipment? {
        equipmentList.first { $0.id == player.equippedWeaponId }
    }

    var equippedArmor: Equipment? {
        equipmentList.first { $0.id == player.equippedArmorId }
    }

    var equippedAccessory: Equipment? {
        equipmentList.first { $0.id == player.equippedAccessoryId }
    }

    var totalAttack: Int {
        player.totalAttack(withWeapon: equippedWeapon)
    }

    var totalDefense: Int {
        player.totalDefense(withArmor: equippedArmor)
    }

    var ownedEquipment: [Equipment] {
        equipmentList.filter { $0.isOwned }
    }

    var shopEquipment: [Equipment] {
        equipmentList.filter { !$0.isOwned }
    }

    // MARK: - Initialization

    init() {
        // 新しいプレイヤーを作成
        self.player = Player(name: "冒険者")

        // 初期ゴールドを設定
        player.gold = GameBalance.initialGold

        // デフォルト装備をロード
        self.equipmentList = EquipmentFactory.getDefaultEquipment()

        // デイリーミッションを生成
        self.dailyMissions = DailyMissionFactory.generateDailyMissions()

        // 初期化処理
        Task {
            await initialize()
        }
    }

    // MARK: - Initialization Methods

    func initialize() async {
        // HealthKitの認証をリクエスト
        do {
            try await healthKitService.requestAuthorization()

            // 今日の歩数を取得
            await updateSteps()

            // 歩数の変更を監視開始
            healthKitService.startObservingSteps { [weak self] steps in
                Task { @MainActor in
                    self?.handleStepUpdate(steps)
                }
            }
        } catch {
            errorMessage = "HealthKitの初期化に失敗しました: \(error.localizedDescription)"
        }

        // 通知の許可をリクエスト
        do {
            _ = try await notificationService.requestAuthorization()
        } catch {
            print("Notification authorization failed: \(error)")
        }

        // 放置戦闘を処理
        await processIdleBattles()

        // デイリーリセットチェック
        checkDailyReset()
    }

    // MARK: - Step Management

    func updateSteps() async {
        do {
            let steps = try await healthKitService.getTodaySteps()
            todaySteps = steps

            // 歩数を経験値に変換
            let newSteps = steps - player.todaySteps
            if newSteps > 0 {
                addStepsToPlayer(newSteps)
            }
        } catch {
            print("Failed to update steps: \(error)")
        }
    }

    private func handleStepUpdate(_ steps: Int) {
        todaySteps = steps

        // 新しい歩数を計算
        let newSteps = steps - player.todaySteps
        if newSteps > 0 {
            addStepsToPlayer(newSteps)
        }
    }

    private func addStepsToPlayer(_ steps: Int) {
        let previousLevel = player.level

        // 歩数を追加
        player.addSteps(steps)

        // 経験値を追加
        let exp = steps * GameBalance.expPerStep
        player.addExp(exp)

        // レベルアップチェック
        if player.level > previousLevel {
            handleLevelUp(from: previousLevel, to: player.level)
        }

        // 歩数マイルストーンチェック
        checkStepMilestones()

        // ミッション進捗更新
        updateMissionProgress(missionType: .steps, value: player.todaySteps)
    }

    // MARK: - Battle Management

    func processSingleBattle() {
        // 敵を生成
        let enemy = EnemyFactory.generateNormalEnemy(basedOnPlayerLevel: player.level)

        // 戦闘を実行
        let battle = battleService.simulateBattle(
            player: player,
            enemy: enemy,
            equippedWeapon: equippedWeapon,
            equippedArmor: equippedArmor
        )

        // 結果を適用
        battleService.applyBattleResults(battle: battle, to: player)

        // 戦闘ログに追加
        battleLog.insert(battle, at: 0)

        // ログを制限
        if battleLog.count > Constants.Limits.maxBattleLogCount {
            battleLog.removeLast()
        }

        // ミッション進捗更新
        updateMissionProgress(missionType: .battles, value: player.totalBattles)
        if battle.isVictory {
            updateMissionProgress(missionType: .wins, value: player.totalWins)
            updateMissionProgress(missionType: .consecutiveWins, value: player.consecutiveWins)
        }

        // 装備ドロップ処理
        if let droppedEquipmentId = battle.droppedEquipmentId,
           let equipment = equipmentList.first(where: { $0.id == droppedEquipmentId }) {
            equipment.purchase()
        }
    }

    func processIdleBattles() async {
        let battles = battleService.processIdleBattles(
            since: player.lastBattleTime,
            player: player,
            equippedWeapon: equippedWeapon,
            equippedArmor: equippedArmor
        )

        for battle in battles {
            battleService.applyBattleResults(battle: battle, to: player)
            battleLog.insert(battle, at: 0)

            // 装備ドロップ処理
            if let droppedEquipmentId = battle.droppedEquipmentId,
               let equipment = equipmentList.first(where: { $0.id == droppedEquipmentId }) {
                equipment.purchase()
            }
        }

        // ログを制限
        while battleLog.count > Constants.Limits.maxBattleLogCount {
            battleLog.removeLast()
        }

        player.lastBattleTime = Date()
    }

    // MARK: - Equipment Management

    func purchaseEquipment(_ equipment: Equipment) -> Bool {
        guard player.spendGold(equipment.price) else {
            errorMessage = "ゴールドが足りません"
            return false
        }

        equipment.purchase()

        // ミッション進捗更新
        updateMissionProgress(missionType: .purchaseEquipment, value: 1)

        return true
    }

    func sellEquipment(_ equipment: Equipment) {
        guard equipment.isOwned, !equipment.isEquipped else {
            return
        }

        player.addGold(equipment.sellPrice)
        equipment.sell()
    }

    func equipItem(_ equipment: Equipment) {
        guard equipment.isOwned else { return }

        // 同じタイプの装備を外す
        switch equipment.type {
        case .weapon:
            if let currentWeapon = equippedWeapon {
                currentWeapon.unequip()
            }
            player.equippedWeaponId = equipment.id

        case .armor:
            if let currentArmor = equippedArmor {
                currentArmor.unequip()
            }
            player.equippedArmorId = equipment.id

        case .accessory:
            if let currentAccessory = equippedAccessory {
                currentAccessory.unequip()
            }
            player.equippedAccessoryId = equipment.id
        }

        equipment.equip()
    }

    func unequipItem(_ equipment: Equipment) {
        equipment.unequip()

        switch equipment.type {
        case .weapon:
            player.equippedWeaponId = nil
        case .armor:
            player.equippedArmorId = nil
        case .accessory:
            player.equippedAccessoryId = nil
        }
    }

    // MARK: - Skill Management

    func upgradeSkill(_ skillType: SkillType) -> Bool {
        let success = player.upgradeSkill(skillType)

        if success {
            // ミッション進捗更新
            updateMissionProgress(missionType: .upgradeSkill, value: 1)
        } else {
            errorMessage = "スキルポイントが足りません"
        }

        return success
    }

    // MARK: - Mission Management

    private func updateMissionProgress(missionType: MissionType, value: Int) {
        for mission in dailyMissions where mission.missionType == missionType && !mission.isCompleted {
            let wasCompleted = mission.isCompleted

            if missionType == .steps {
                mission.updateProgress(value)
            } else {
                mission.addProgress(1)
            }

            // 完了通知
            if !wasCompleted && mission.isCompleted {
                notificationService.scheduleMissionCompleteNotification(mission: mission)

                // 報酬を付与
                let reward = mission.claimRewards()
                player.addGold(reward.gold)
                player.addExp(reward.exp)
            }
        }
    }

    // MARK: - Level Up

    private func handleLevelUp(from oldLevel: Int, to newLevel: Int) {
        // 通知
        notificationService.scheduleLevelUpNotification(newLevel: newLevel)

        // ミッション進捗
        updateMissionProgress(missionType: .levelUp, value: 1)
    }

    // MARK: - Step Milestones

    private func checkStepMilestones() {
        for milestone in GameBalance.stepMilestones {
            if player.todaySteps >= milestone.steps {
                // マイルストーン達成（簡易実装）
                // 実際にはフラグを保存して1日1回のみ報酬を与える必要がある
            }
        }
    }

    // MARK: - Daily Reset

    private func checkDailyReset() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastUpdate = calendar.startOfDay(for: player.lastStepUpdate)

        if today > lastUpdate {
            // デイリーリセット
            player.resetDaily()

            // デイリーミッションを再生成
            dailyMissions = DailyMissionFactory.generateDailyMissions()
        }
    }

    // MARK: - Random Events

    func checkRandomEvents() {
        // 期限切れイベントを削除
        activeRandomEvents.removeAll { event in
            !event.checkExpiry()
        }

        // 新しいイベントを生成
        if let newEvent = RandomEventFactory.generateRandomEvent() {
            activeRandomEvents.append(newEvent)
            notificationService.scheduleRandomEventNotification(event: newEvent)
        }
    }

    // MARK: - Debug/Test Methods

    #if DEBUG
    func addTestSteps(_ steps: Int) {
        addStepsToPlayer(steps)
        todaySteps = player.todaySteps
    }

    func addTestGold(_ gold: Int) {
        player.addGold(gold)
    }

    func triggerTestBattle() {
        processSingleBattle()
    }
    #endif
}
