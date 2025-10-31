# WalkRPG - 技術設計ドキュメント

## 📋 目次
1. [技術スタック](#技術スタック)
2. [アーキテクチャ](#アーキテクチャ)
3. [データモデル](#データモデル)
4. [ディレクトリ構造](#ディレクトリ構造)
5. [主要機能の実装方針](#主要機能の実装方針)
6. [開発フェーズ](#開発フェーズ)

---

## 🛠 技術スタック

### 開発環境
- **Xcode**: 15.0+
- **Swift**: 5.9+
- **iOS Target**: 16.0+
- **開発言語**: Swift
- **UIフレームワーク**: SwiftUI

### 使用フレームワーク
- **HealthKit**: 歩数データ取得
- **SwiftData**: データ永続化（iOS 17+の場合）、またはCoreData（iOS 16対応の場合）
- **Combine**: リアクティブプログラミング
- **UserNotifications**: プッシュ通知
- **BackgroundTasks**: バックグラウンド処理

### サードパーティライブラリ（最小限）
- 必要に応じて検討（現時点では標準ライブラリのみで実装予定）

---

## 🏗 アーキテクチャ

### MVVM + Repository パターン

```
View (SwiftUI)
    ↓
ViewModel (ObservableObject)
    ↓
Repository / Service
    ↓
Data Layer (SwiftData/CoreData, HealthKit)
```

### レイヤー構造

#### 1. **View Layer** (SwiftUI)
- ユーザーインターフェース
- ViewModelのデータをバインディング
- ユーザーアクションをViewModelに通知

#### 2. **ViewModel Layer**
- ビジネスロジック
- Viewの状態管理
- RepositoryやServiceの呼び出し

#### 3. **Repository Layer**
- データソースの抽象化
- データの取得・保存・更新・削除

#### 4. **Service Layer**
- ゲームロジック（戦闘計算、レベルアップなど）
- HealthKitとの連携
- バックグラウンドタスク管理

#### 5. **Data Layer**
- データモデル定義
- データベース（SwiftData/CoreData）
- HealthKit

---

## 📊 データモデル

### 1. Player（プレイヤー）
```swift
@Model
class Player {
    var id: UUID
    var name: String
    var level: Int
    var currentExp: Int
    var maxHP: Int
    var currentHP: Int
    var baseAttack: Int
    var baseDefense: Int
    var gold: Int
    var totalSteps: Int
    var todaySteps: Int
    var lastStepUpdate: Date

    // 装備（リレーション）
    var equippedWeapon: Equipment?
    var equippedArmor: Equipment?
    var equippedAccessory: Equipment?

    // スキルポイント
    var skillPoints: Int
    var skills: [PlayerSkill]

    // 統計情報
    var totalBattles: Int
    var totalWins: Int
    var totalLosses: Int
    var consecutiveWins: Int

    // 計算プロパティ
    var totalAttack: Int {
        baseAttack + (equippedWeapon?.attackBonus ?? 0)
    }

    var totalDefense: Int {
        baseDefense + (equippedArmor?.defenseBonus ?? 0)
    }

    var expToNextLevel: Int {
        calculateExpForLevel(level + 1)
    }
}
```

### 2. Equipment（装備）
```swift
@Model
class Equipment {
    var id: UUID
    var name: String
    var type: EquipmentType // weapon, armor, accessory
    var rarity: Rarity // common, rare, epic, legendary
    var attackBonus: Int
    var defenseBonus: Int
    var price: Int
    var description: String
    var specialEffect: String? // "goldBonus20", "expBonus20", etc.
    var iconName: String
    var isOwned: Bool
    var isEquipped: Bool
}

enum EquipmentType: String, Codable {
    case weapon
    case armor
    case accessory
}

enum Rarity: String, Codable {
    case common
    case rare
    case epic
    case legendary
}
```

### 3. Enemy（敵）
```swift
struct Enemy: Identifiable, Codable {
    var id: UUID
    var name: String
    var level: Int
    var hp: Int
    var attack: Int
    var defense: Int
    var goldReward: Int
    var expReward: Int
    var type: EnemyType
    var dropTable: [EquipmentDrop]
    var iconName: String
}

enum EnemyType: String, Codable {
    case normal
    case elite
    case boss
}

struct EquipmentDrop: Codable {
    var equipmentId: UUID
    var dropRate: Double // 0.0 - 1.0
}
```

### 4. Battle（戦闘）
```swift
@Model
class Battle {
    var id: UUID
    var timestamp: Date
    var enemy: Enemy
    var playerLevel: Int
    var playerHP: Int
    var playerAttack: Int
    var playerDefense: Int
    var result: BattleResult
    var goldEarned: Int
    var expEarned: Int
    var droppedEquipment: Equipment?
    var turnLog: [BattleTurn]
}

enum BattleResult: String, Codable {
    case victory
    case defeat
}

struct BattleTurn: Codable {
    var turnNumber: Int
    var playerDamage: Int
    var enemyDamage: Int
    var playerHP: Int
    var enemyHP: Int
}
```

### 5. DailyMission（デイリーミッション）
```swift
@Model
class DailyMission {
    var id: UUID
    var date: Date
    var missionType: MissionType
    var targetValue: Int
    var currentProgress: Int
    var goldReward: Int
    var expReward: Int
    var isCompleted: Bool
    var title: String
    var description: String
}

enum MissionType: String, Codable {
    case steps
    case battles
    case wins
    case consecutiveWins
    case levelUp
    case purchaseEquipment
    case upgradeSkill
}
```

### 6. PlayerSkill（スキル）
```swift
struct PlayerSkill: Codable {
    var id: UUID
    var skillType: SkillType
    var level: Int
    var maxLevel: Int
}

enum SkillType: String, Codable {
    case powerAttack  // 攻撃力ボーナス
    case ironDefense  // 防御力ボーナス
    case recovery     // HP回復量ボーナス
    case lucky        // ドロップ率ボーナス
}
```

### 7. RandomEvent（ランダムイベント）
```swift
@Model
class RandomEvent {
    var id: UUID
    var eventType: RandomEventType
    var timestamp: Date
    var expiryTime: Date
    var isActive: Bool
    var data: String? // JSON形式で追加データを保存
}

enum RandomEventType: String, Codable {
    case rareShop
    case eliteEnemy
    case treasureBox
    case merchant
}
```

### 8. StepMilestone（歩数マイルストーン）
```swift
struct StepMilestone {
    var steps: Int
    var goldReward: Int
    var expReward: Int
    var specialReward: String? // "gachaTicket", "rareItemBox", etc.
    var isAchieved: Bool
}
```

---

## 📁 ディレクトリ構造

```
WalkRPG/
├── App/
│   ├── WalkRPGApp.swift          # アプリのエントリーポイント
│   └── AppDelegate.swift          # AppDelegate（必要な場合）
│
├── Models/
│   ├── Player.swift
│   ├── Equipment.swift
│   ├── Enemy.swift
│   ├── Battle.swift
│   ├── DailyMission.swift
│   ├── PlayerSkill.swift
│   ├── RandomEvent.swift
│   └── StepMilestone.swift
│
├── ViewModels/
│   ├── GameViewModel.swift        # メインゲーム画面
│   ├── ShopViewModel.swift        # ショップ画面
│   ├── SkillViewModel.swift       # スキル画面
│   ├── BattleLogViewModel.swift   # 戦闘ログ画面
│   └── MissionViewModel.swift     # ミッション画面
│
├── Views/
│   ├── MainView.swift             # メインタブビュー
│   ├── GameView.swift             # ゲームメイン画面
│   ├── ShopView.swift             # ショップ画面
│   ├── SkillView.swift            # スキル画面
│   ├── BattleLogView.swift        # 戦闘ログ画面
│   ├── MissionView.swift          # ミッション画面
│   └── Components/                # 再利用可能なコンポーネント
│       ├── PlayerStatusCard.swift
│       ├── StepProgressBar.swift
│       ├── BattleResultRow.swift
│       ├── EquipmentCard.swift
│       └── MissionRow.swift
│
├── Repositories/
│   ├── PlayerRepository.swift
│   ├── EquipmentRepository.swift
│   ├── BattleRepository.swift
│   ├── MissionRepository.swift
│   └── RandomEventRepository.swift
│
├── Services/
│   ├── HealthKitService.swift     # 歩数データ取得
│   ├── BattleService.swift        # 戦闘ロジック
│   ├── LevelUpService.swift       # レベルアップ計算
│   ├── EquipmentService.swift     # 装備管理
│   ├── MissionService.swift       # ミッション管理
│   ├── RandomEventService.swift   # ランダムイベント生成
│   ├── NotificationService.swift  # 通知管理
│   └── BackgroundTaskService.swift # バックグラウンド処理
│
├── Utils/
│   ├── Constants.swift            # 定数定義
│   ├── GameBalance.swift          # ゲームバランス設定
│   ├── Extensions/
│   │   ├── Date+Extensions.swift
│   │   └── Int+Extensions.swift
│   └── Helpers/
│       ├── RandomGenerator.swift
│       └── DateHelper.swift
│
├── Resources/
│   ├── Assets.xcassets           # 画像、アイコン
│   ├── Colors.xcassets           # カラーセット
│   └── Localizable.strings       # 多言語対応（将来）
│
└── Data/
    ├── GameData.json             # 初期データ（敵、装備など）
    └── Persistence/
        └── PersistenceController.swift # データベース管理
```

---

## 🔧 主要機能の実装方針

### 1. HealthKit連携（歩数取得）

#### 実装ステップ
1. **Info.plistに権限追加**
```xml
<key>NSHealthShareUsageDescription</key>
<string>歩数データを使用してキャラクターを成長させます</string>
<key>NSHealthUpdateUsageDescription</key>
<string>ゲームの進行に歩数データを使用します</string>
```

2. **HealthKitServiceの実装**
```swift
class HealthKitService {
    private let healthStore = HKHealthStore()

    func requestAuthorization() async throws {
        // 歩数データへのアクセス許可をリクエスト
    }

    func getTodaySteps() async throws -> Int {
        // 今日の歩数を取得
    }

    func getTotalSteps() async throws -> Int {
        // 累計歩数を取得（アプリインストール以降）
    }

    func observeStepUpdates(handler: @escaping (Int) -> Void) {
        // リアルタイムで歩数更新を監視
    }
}
```

#### バックグラウンド更新
- `HKObserverQuery`を使用して歩数の変化を監視
- アプリがバックグラウンドでも歩数を取得できるようにする

### 2. 自動戦闘システム

#### 実装ロジック
```swift
class BattleService {
    func simulateBattle(player: Player, enemy: Enemy) -> Battle {
        var turnLog: [BattleTurn] = []
        var playerHP = player.maxHP
        var enemyHP = enemy.hp
        var turnNumber = 1

        while playerHP > 0 && enemyHP > 0 {
            // プレイヤーの攻撃
            let playerDamage = max(1, player.totalAttack - enemy.defense)
            enemyHP -= playerDamage

            if enemyHP <= 0 {
                break
            }

            // 敵の攻撃
            let enemyDamage = max(1, enemy.attack - player.totalDefense)
            playerHP -= enemyDamage

            turnLog.append(BattleTurn(
                turnNumber: turnNumber,
                playerDamage: playerDamage,
                enemyDamage: enemyDamage,
                playerHP: playerHP,
                enemyHP: enemyHP
            ))

            turnNumber += 1
        }

        let result: BattleResult = playerHP > 0 ? .victory : .defeat
        return createBattleRecord(result: result, turnLog: turnLog)
    }

    func processIdleBattles(since lastCheck: Date) -> [Battle] {
        // 前回チェック以降の放置戦闘をシミュレート
        let timeElapsed = Date().timeIntervalSince(lastCheck)
        let battleCount = min(Int(timeElapsed / 600), 48) // 10分ごと、最大8時間

        var battles: [Battle] = []
        for _ in 0..<battleCount {
            let enemy = generateRandomEnemy()
            let battle = simulateBattle(player: currentPlayer, enemy: enemy)
            battles.append(battle)
        }

        return battles
    }
}
```

### 3. レベルアップシステム

#### 経験値計算式
```swift
class LevelUpService {
    // レベルnに到達するために必要な累計経験値
    func expForLevel(_ level: Int) -> Int {
        if level <= 1 {
            return 0
        }
        // 指数関数的な成長: 100 * (level - 1) ^ 1.5
        return Int(100 * pow(Double(level - 1), 1.5))
    }

    // 経験値からレベルを計算
    func calculateLevel(exp: Int) -> Int {
        var level = 1
        while exp >= expForLevel(level + 1) {
            level += 1
        }
        return level
    }

    // レベルアップ処理
    func levelUp(player: inout Player) {
        player.level += 1
        player.maxHP += 10
        player.baseAttack += 2
        player.baseDefense += 1
        player.skillPoints += 1
        player.currentHP = player.maxHP // 全回復
    }
}
```

### 4. ランダムイベント生成

```swift
class RandomEventService {
    func generateRandomEvent() -> RandomEvent? {
        let roll = Double.random(in: 0...1)

        if roll < 0.03 { // 3%
            return createMerchantEvent()
        } else if roll < 0.08 { // 5%
            return createRareShopEvent()
        } else if roll < 0.16 { // 8%
            return createTreasureBoxEvent()
        } else if roll < 0.26 { // 10%
            return createEliteEnemyEvent()
        }

        return nil
    }

    private func createRareShopEvent() -> RandomEvent {
        RandomEvent(
            eventType: .rareShop,
            timestamp: Date(),
            expiryTime: Date().addingTimeInterval(1800), // 30分後
            isActive: true
        )
    }
}
```

### 5. デイリーミッション管理

```swift
class MissionService {
    func generateDailyMissions() -> [DailyMission] {
        let today = Date()
        return [
            DailyMission(
                date: today,
                missionType: .steps,
                targetValue: 5000,
                title: "5,000歩達成",
                goldReward: 500
            ),
            DailyMission(
                date: today,
                missionType: .battles,
                targetValue: 10,
                title: "敵を10体倒す",
                goldReward: 300
            ),
            // ... more missions
        ]
    }

    func updateMissionProgress(mission: inout DailyMission, progress: Int) {
        mission.currentProgress = min(progress, mission.targetValue)
        if mission.currentProgress >= mission.targetValue && !mission.isCompleted {
            mission.isCompleted = true
            // 報酬を付与
        }
    }
}
```

### 6. バックグラウンドタスク

```swift
class BackgroundTaskService {
    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.walkrpg.battle",
            using: nil
        ) { task in
            self.handleBattleTask(task: task as! BGAppRefreshTask)
        }
    }

    private func handleBattleTask(task: BGAppRefreshTask) {
        // バックグラウンドで戦闘処理
        let battles = BattleService.shared.processIdleBattles(since: lastBattleTime)
        // データを保存

        task.setTaskCompleted(success: true)
        scheduleNextBackgroundTask()
    }

    private func scheduleNextBackgroundTask() {
        let request = BGAppRefreshTaskRequest(identifier: "com.walkrpg.battle")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 600) // 10分後
        try? BGTaskScheduler.shared.submit(request)
    }
}
```

---

## 🚦 開発フェーズ

### Phase 1: 基礎実装（1-2週間）

#### Week 1: プロジェクトセットアップとデータ層
- [ ] Xcodeプロジェクト作成
- [ ] ディレクトリ構造の構築
- [ ] データモデルの実装
- [ ] SwiftData/CoreDataのセットアップ
- [ ] Repositoryパターンの実装
- [ ] 基本的なダミーデータの準備

#### Week 2: HealthKitとゲームロジック
- [ ] HealthKitServiceの実装
- [ ] 歩数取得とリアルタイム更新
- [ ] BattleServiceの基本実装
- [ ] LevelUpServiceの実装
- [ ] 基本的な戦闘シミュレーション

### Phase 2: UI実装（1-2週間）

#### Week 3: メイン画面とコンポーネント
- [ ] MainViewの実装（タブビュー）
- [ ] GameViewの実装
- [ ] PlayerStatusCardコンポーネント
- [ ] StepProgressBarコンポーネント
- [ ] ViewModelの実装とバインディング

#### Week 4: ショップと戦闘ログ
- [ ] ShopViewの実装
- [ ] EquipmentCardコンポーネント
- [ ] BattleLogViewの実装
- [ ] 装備購入と装備変更の実装

### Phase 3: エンゲージメント機能（1週間）

#### Week 5: ミッションとイベント
- [ ] DailyMissionの実装
- [ ] MissionViewとMissionRowコンポーネント
- [ ] RandomEventServiceの実装
- [ ] イベント通知の実装

### Phase 4: バックグラウンドと通知（1週間）

#### Week 6: バックグラウンド処理
- [ ] BackgroundTaskServiceの実装
- [ ] NotificationServiceの実装
- [ ] 放置戦闘の処理
- [ ] ローカル通知の設定

### Phase 5: 調整とテスト（1-2週間）

#### Week 7-8: バランス調整とバグ修正
- [ ] ゲームバランスの調整
- [ ] UI/UXの改善
- [ ] バグ修正
- [ ] パフォーマンス最適化
- [ ] TestFlightでのベータテスト

---

## ⚙️ ゲームバランス設定

### Constants.swift の例
```swift
struct GameBalance {
    // レベルアップ
    static let baseExpForLevel = 100.0
    static let expGrowthRate = 1.5

    // ステータス成長
    static let hpPerLevel = 10
    static let attackPerLevel = 2
    static let defensePerLevel = 1

    // 戦闘
    static let battleIntervalMin = 600.0  // 10分
    static let battleIntervalMax = 900.0  // 15分
    static let maxIdleBattles = 48        // 8時間分

    // ランダムイベント確率
    static let rareShopChance = 0.05      // 5%
    static let eliteEnemyChance = 0.10    // 10%
    static let treasureBoxChance = 0.08   // 8%
    static let merchantChance = 0.03      // 3%

    // 歩数マイルストーン
    static let stepMilestones = [
        1000: (gold: 100, exp: 0),
        3000: (gold: 300, exp: 500),
        5000: (gold: 500, exp: 0),
        8000: (gold: 1000, exp: 0),
        10000: (gold: 0, exp: 0)
    ]
}
```

---

## 🔐 セキュリティとプライバシー

### データプライバシー
- HealthKitデータはローカルでのみ使用
- ユーザーデータはデバイス内に保存（将来的にiCloud同期も検討）
- アナリティクスは最小限（個人を特定できない情報のみ）

### チート対策
- 歩数の急激な増加を検知（1時間で10,000歩以上など）
- サーバーレスなので完全な対策は難しいが、異常値を制限

---

## 📝 今後の検討事項

1. **データ永続化**: SwiftData vs CoreData
   - iOS 17+ならSwiftData推奨
   - iOS 16サポートならCoreData

2. **iCloud同期**: 将来的に実装
   - CloudKitを使用してデバイス間でデータ同期

3. **マネタイゼーション**:
   - 広告の配置場所
   - IAP（アプリ内課金）の設計

4. **ローカライゼーション**:
   - 将来的に英語対応も検討

---

このドキュメントは開発の進行に合わせて更新していきます。
