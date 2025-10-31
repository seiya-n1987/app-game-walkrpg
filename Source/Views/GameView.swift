//
//  GameView.swift
//  WalkRPG
//
//  メインゲーム画面
//

import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // プレイヤーステータスカード
                    PlayerStatusCard(viewModel: viewModel)

                    // 歩数とレベル進捗
                    StepProgressCard(viewModel: viewModel)

                    // クイックアクション
                    QuickActionsCard(viewModel: viewModel)

                    // デイリーミッション
                    DailyMissionsCard(viewModel: viewModel)

                    // 戦闘ログ
                    BattleLogCard(viewModel: viewModel)
                }
                .padding()
            }
            .navigationTitle("WalkRPG")
            .refreshable {
                await viewModel.updateSteps()
                await viewModel.processIdleBattles()
            }
        }
    }
}

// MARK: - Player Status Card

struct PlayerStatusCard: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("⚔️ \(viewModel.player.name)")
                .font(.title2)
                .fontWeight(.bold)

            HStack {
                Text("Lv.\(viewModel.player.level)")
                    .font(.title3)
                    .fontWeight(.semibold)

                Spacer()

                Text("💰 \(viewModel.player.gold)G")
                    .font(.headline)
            }

            // HPバー
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                    Text("HP: \(viewModel.player.currentHP)/\(viewModel.player.maxHP)")
                        .font(.subheadline)
                }

                ProgressView(value: viewModel.player.hpPercentage)
                    .tint(.red)
            }

            // ステータス
            HStack(spacing: 20) {
                StatView(icon: "bolt.fill", label: "攻撃", value: viewModel.totalAttack, color: .orange)
                StatView(icon: "shield.fill", label: "防御", value: viewModel.totalDefense, color: .blue)
            }

            // 装備
            if let weapon = viewModel.equippedWeapon {
                HStack {
                    Image(systemName: "figure.fencing")
                    Text(weapon.name)
                        .font(.caption)
                }
            }

            if let armor = viewModel.equippedArmor {
                HStack {
                    Image(systemName: "shield.fill")
                    Text(armor.name)
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct StatView: View {
    let icon: String
    let label: String
    let value: Int
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("\(value)")
                    .font(.headline)
            }
        }
    }
}

// MARK: - Step Progress Card

struct StepProgressCard: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "figure.walk")
                    .font(.title2)
                Text("今日の歩数")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.todaySteps)歩")
                    .font(.title3)
                    .fontWeight(.bold)
            }

            // レベル進捗
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("次のレベルまで")
                        .font(.caption)
                    Spacer()
                    Text("\(viewModel.player.expToNextLevel) EXP")
                        .font(.caption)
                        .fontWeight(.semibold)
                }

                ProgressView(value: viewModel.player.levelProgress)
                    .tint(.green)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Quick Actions Card

struct QuickActionsCard: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 12) {
            Text("クイックアクション")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                Button(action: {
                    viewModel.processSingleBattle()
                }) {
                    VStack {
                        Image(systemName: "crossed.swords")
                            .font(.title2)
                        Text("戦闘")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }

                Button(action: {
                    Task {
                        await viewModel.updateSteps()
                    }
                }) {
                    VStack {
                        Image(systemName: "arrow.clockwise")
                            .font(.title2)
                        Text("更新")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                }
            }

            #if DEBUG
            // デバッグボタン
            HStack(spacing: 12) {
                Button("歩数+1000") {
                    viewModel.addTestSteps(1000)
                }
                .buttonStyle(.bordered)

                Button("ゴールド+500") {
                    viewModel.addTestGold(500)
                }
                .buttonStyle(.bordered)
            }
            .font(.caption)
            #endif
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Daily Missions Card

struct DailyMissionsCard: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📋 デイリーミッション")
                .font(.headline)

            ForEach(viewModel.dailyMissions.prefix(3)) { mission in
                MissionRow(mission: mission)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct MissionRow: View {
    let mission: DailyMission

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: mission.iconName)
                    .foregroundColor(mission.isCompleted ? .green : .primary)

                Text(mission.title)
                    .font(.subheadline)
                    .strikethrough(mission.isCompleted)

                Spacer()

                if mission.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Text(mission.progressText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            if !mission.isCompleted {
                ProgressView(value: mission.progressPercentage)
                    .tint(.blue)
            }

            HStack {
                if mission.goldReward > 0 {
                    Text("💰 \(mission.goldReward)G")
                        .font(.caption2)
                }
                if mission.expReward > 0 {
                    Text("⭐️ \(mission.expReward) EXP")
                        .font(.caption2)
                }
            }
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Battle Log Card

struct BattleLogCard: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("⚔️ 戦闘ログ")
                .font(.headline)

            if viewModel.battleLog.isEmpty {
                Text("まだ戦闘がありません")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(viewModel.battleLog.prefix(5)) { battle in
                    BattleLogRow(battle: battle)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct BattleLogRow: View {
    let battle: Battle

    var body: some View {
        HStack {
            Text(battle.resultEmoji)
                .font(.title3)

            VStack(alignment: .leading, spacing: 2) {
                if let enemy = battle.enemy {
                    Text("\(enemy.name) Lv.\(enemy.level)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                HStack(spacing: 8) {
                    if battle.isVictory {
                        Text("💰 +\(battle.goldEarned)G")
                            .font(.caption)
                        Text("⭐️ +\(battle.expEarned) EXP")
                            .font(.caption)
                    } else {
                        Text("敗北")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }

            Spacer()

            Text(formatTimeAgo(battle.timestamp))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }

    private func formatTimeAgo(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let minutes = Int(interval / 60)

        if minutes < 1 {
            return "たった今"
        } else if minutes < 60 {
            return "\(minutes)分前"
        } else {
            let hours = minutes / 60
            return "\(hours)時間前"
        }
    }
}

// MARK: - Preview

#Preview {
    GameView(viewModel: GameViewModel())
}
