//
//  ShopView.swift
//  WalkRPG
//
//  ショップ画面（簡易版）
//

import SwiftUI

struct ShopView: View {
    @ObservedObject var viewModel: GameViewModel
    @State private var selectedTab = 0

    var body: some View {
        NavigationView {
            VStack {
                // プレイヤーのゴールド表示
                HStack {
                    Text("所持金:")
                        .font(.headline)
                    Text("\(viewModel.player.gold) G")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))

                // タブ選択
                Picker("", selection: $selectedTab) {
                    Text("ショップ").tag(0)
                    Text("所持装備").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                if selectedTab == 0 {
                    // ショップ
                    ShopList(viewModel: viewModel)
                } else {
                    // 所持装備
                    InventoryList(viewModel: viewModel)
                }
            }
            .navigationTitle("🛒 ショップ")
        }
    }
}

// MARK: - Shop List

struct ShopList: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.shopEquipment) { equipment in
                    EquipmentShopCard(
                        equipment: equipment,
                        onPurchase: {
                            _ = viewModel.purchaseEquipment(equipment)
                        }
                    )
                }
            }
            .padding()
        }
    }
}

struct EquipmentShopCard: View {
    let equipment: Equipment
    let onPurchase: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // アイコン
            Image(systemName: equipment.iconName)
                .font(.title)
                .foregroundColor(rarityColor(equipment.rarity))
                .frame(width: 50, height: 50)
                .background(rarityColor(equipment.rarity).opacity(0.1))
                .cornerRadius(8)

            // 情報
            VStack(alignment: .leading, spacing: 4) {
                Text(equipment.name)
                    .font(.headline)
                    .foregroundColor(rarityColor(equipment.rarity))

                Text(equipment.type.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 8) {
                    if equipment.attackBonus > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "bolt.fill")
                                .font(.caption2)
                            Text("+\(equipment.attackBonus)")
                                .font(.caption)
                        }
                        .foregroundColor(.orange)
                    }

                    if equipment.defenseBonus > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "shield.fill")
                                .font(.caption2)
                            Text("+\(equipment.defenseBonus)")
                                .font(.caption)
                        }
                        .foregroundColor(.blue)
                    }
                }
            }

            Spacer()

            // 購入ボタン
            VStack(spacing: 4) {
                Text("\(equipment.price)G")
                    .font(.headline)
                    .fontWeight(.bold)

                Button(action: onPurchase) {
                    Text("購入")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private func rarityColor(_ rarity: Rarity) -> Color {
        switch rarity {
        case .common: return .gray
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }
}

// MARK: - Inventory List

struct InventoryList: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if viewModel.ownedEquipment.isEmpty {
                    Text("装備がありません")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(viewModel.ownedEquipment) { equipment in
                        EquipmentInventoryCard(
                            equipment: equipment,
                            isEquipped: isEquipped(equipment),
                            onEquip: {
                                if isEquipped(equipment) {
                                    viewModel.unequipItem(equipment)
                                } else {
                                    viewModel.equipItem(equipment)
                                }
                            },
                            onSell: {
                                viewModel.sellEquipment(equipment)
                            }
                        )
                    }
                }
            }
            .padding()
        }
    }

    private func isEquipped(_ equipment: Equipment) -> Bool {
        equipment.id == viewModel.player.equippedWeaponId ||
        equipment.id == viewModel.player.equippedArmorId ||
        equipment.id == viewModel.player.equippedAccessoryId
    }
}

struct EquipmentInventoryCard: View {
    let equipment: Equipment
    let isEquipped: Bool
    let onEquip: () -> Void
    let onSell: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // アイコン
            Image(systemName: equipment.iconName)
                .font(.title)
                .foregroundColor(rarityColor(equipment.rarity))
                .frame(width: 50, height: 50)
                .background(rarityColor(equipment.rarity).opacity(0.1))
                .cornerRadius(8)
                .overlay(
                    Group {
                        if isEquipped {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .background(Circle().fill(Color.white))
                                .offset(x: 20, y: -20)
                        }
                    }
                )

            // 情報
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(equipment.name)
                        .font(.headline)
                        .foregroundColor(rarityColor(equipment.rarity))

                    if isEquipped {
                        Text("装備中")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(4)
                    }
                }

                Text(equipment.type.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 8) {
                    if equipment.attackBonus > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "bolt.fill")
                                .font(.caption2)
                            Text("+\(equipment.attackBonus)")
                                .font(.caption)
                        }
                        .foregroundColor(.orange)
                    }

                    if equipment.defenseBonus > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "shield.fill")
                                .font(.caption2)
                            Text("+\(equipment.defenseBonus)")
                                .font(.caption)
                        }
                        .foregroundColor(.blue)
                    }
                }
            }

            Spacer()

            // アクションボタン
            VStack(spacing: 8) {
                Button(action: onEquip) {
                    Text(isEquipped ? "外す" : "装備")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(width: 60)
                        .padding(.vertical, 6)
                        .background(isEquipped ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }

                if !isEquipped {
                    Button(action: onSell) {
                        Text("売却")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(width: 60)
                            .padding(.vertical, 6)
                            .background(Color.red.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(6)
                    }

                    Text("\(equipment.sellPrice)G")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private func rarityColor(_ rarity: Rarity) -> Color {
        switch rarity {
        case .common: return .gray
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }
}

// MARK: - Preview

#Preview {
    ShopView(viewModel: GameViewModel())
}
