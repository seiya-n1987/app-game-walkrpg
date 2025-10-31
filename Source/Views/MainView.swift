//
//  MainView.swift
//  WalkRPG
//
//  メインのタブビュー
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = GameViewModel()

    var body: some View {
        TabView {
            GameView(viewModel: viewModel)
                .tabItem {
                    Label("ゲーム", systemImage: "gamecontroller.fill")
                }

            ShopView(viewModel: viewModel)
                .tabItem {
                    Label("ショップ", systemImage: "cart.fill")
                }

            SkillView(viewModel: viewModel)
                .tabItem {
                    Label("スキル", systemImage: "star.circle.fill")
                }
        }
    }
}

// MARK: - Skill View (Simplified)

struct SkillView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // スキルポイント表示
                    HStack {
                        Text("スキルポイント:")
                            .font(.headline)
                        Text("\(viewModel.player.skillPoints)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    // スキルリスト
                    ForEach(SkillType.allCases, id: \.self) { skillType in
                        SkillCard(
                            viewModel: viewModel,
                            skillType: skillType
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("🌟 スキル")
        }
    }
}

struct SkillCard: View {
    @ObservedObject var viewModel: GameViewModel
    let skillType: SkillType

    private var skill: PlayerSkill {
        viewModel.player.skills.first { $0.skillType == skillType } ?? PlayerSkill(skillType: skillType, level: 0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(skillType.displayName)
                        .font(.headline)

                    Text(skillType.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text(skill.levelText)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            // 進捗バー
            ProgressView(value: skill.progressPercentage)
                .tint(.purple)

            HStack {
                Text(skill.bonusText)
                    .font(.subheadline)
                    .foregroundColor(.purple)

                Spacer()

                if !skill.isMaxLevel {
                    Button(action: {
                        _ = viewModel.upgradeSkill(skillType)
                    }) {
                        Text("強化")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(viewModel.player.skillPoints > 0 ? Color.purple : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(6)
                    }
                    .disabled(viewModel.player.skillPoints == 0)
                } else {
                    Text("MAX")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Preview

#Preview {
    MainView()
}
