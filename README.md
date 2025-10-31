# WalkRPG - 歩数計放置RPGゲーム

歩数で強くなり、放置している間に敵と戦う、新感覚のハイブリッドRPG for iPhone

![iOS](https://img.shields.io/badge/iOS-16.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-3.0-green)

---

## 📖 概要

**WalkRPG**は、日常の歩数をゲームの成長要素に変換する、新しいタイプのRPGゲームです。

### 主な特徴
- 🚶 **歩数 = 経験値**: 歩くだけでキャラクターが強くなる
- 🎮 **放置システム**: アプリを閉じている間も自動で敵と戦闘
- ⚔️ **RPG要素**: レベルアップ、装備、スキルなどの本格的な成長システム
- 🎯 **デイリーミッション**: 毎日の目標で報酬獲得
- 🎲 **ランダムイベント**: レアショップや強敵が出現
- 🏆 **歩数マイルストーン**: 特定歩数到達で即座にボーナス

### プレイスタイル
- **手軽に放置**: 1日5分、戦闘ログ確認と装備購入だけでOK
- **やり込みも可能**: スキルビルド、装備最適化、タイミング戦略などの深い要素

---

## 📋 ドキュメント

- [ゲームコンセプト](GAME_CONCEPT.md) - ゲームデザインと仕様
- [技術設計](TECHNICAL_DESIGN.md) - アーキテクチャとデータモデル

---

## 🛠 技術スタック

- **言語**: Swift 5.9+
- **UIフレームワーク**: SwiftUI
- **最小サポート**: iOS 16.0+
- **データ永続化**: SwiftData / CoreData
- **歩数計測**: HealthKit
- **通知**: UserNotifications
- **バックグラウンド処理**: BackgroundTasks

---

## 🚀 セットアップ手順

### 前提条件
- macOS 13.0+ (Ventura以降)
- Xcode 15.0+
- iPhone実機（HealthKitはシミュレーターで動作しないため）

### 1. Xcodeプロジェクトの作成

1. Xcodeを起動
2. "Create a new Xcode project"を選択
3. **iOS** → **App**テンプレートを選択
4. プロジェクト設定:
   - **Product Name**: WalkRPG
   - **Team**: あなたのApple Developer Team
   - **Organization Identifier**: com.yourname（適宜変更）
   - **Interface**: SwiftUI
   - **Storage**: SwiftData（iOS 17+の場合）またはNone（iOS 16の場合はCoreData）
   - **Language**: Swift
5. このリポジトリのディレクトリを保存先として選択

### 2. プロジェクト設定

#### 2.1 Capabilityの追加

1. プロジェクトナビゲーターでプロジェクトファイルを選択
2. **Signing & Capabilities**タブを開く
3. **+ Capability**をクリックして以下を追加:
   - **HealthKit**
   - **Background Modes** → "Background fetch"と"Background processing"を有効化

#### 2.2 Info.plistの編集

プロジェクトの**Info**タブ（またはInfo.plist）に以下を追加:

```xml
<key>NSHealthShareUsageDescription</key>
<string>歩数データを使用してキャラクターを成長させます</string>

<key>NSHealthUpdateUsageDescription</key>
<string>ゲームの進行に歩数データを使用します</string>

<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>processing</string>
</array>
```

#### 2.3 ディレクトリ構造の作成

プロジェクトナビゲーターで以下のグループ（フォルダ）を作成:

```
WalkRPG/
├── App/
├── Models/
├── ViewModels/
├── Views/
│   └── Components/
├── Repositories/
├── Services/
├── Utils/
│   ├── Extensions/
│   └── Helpers/
├── Resources/
└── Data/
    └── Persistence/
```

### 3. ファイルの追加

このリポジトリ内の`Source/`ディレクトリにあるSwiftファイルを、Xcodeプロジェクトの対応するグループにドラッグ&ドロップして追加します。

### 4. ビルド設定

1. **Deployment Target**をiOS 16.0に設定
2. **Bundle Identifier**が一意であることを確認
3. 開発用のiPhoneを接続
4. **Signing**でチームを選択して、自動署名を有効化

### 5. 初回ビルドと実行

1. Xcodeで**Product** → **Build** (⌘B)
2. エラーがないことを確認
3. 接続したiPhoneを選択
4. **Product** → **Run** (⌘R)
5. アプリ起動時にHealthKitの権限許可を求められるので、許可する

---

## 📁 プロジェクト構造

```
WalkRPG/
├── Source/                    # Swiftソースコード（このREADME作成後に追加）
│   ├── Models/               # データモデル
│   ├── ViewModels/           # ビジネスロジック
│   ├── Views/                # SwiftUI画面
│   ├── Services/             # ゲームロジック、HealthKit連携など
│   ├── Repositories/         # データアクセス層
│   └── Utils/                # ユーティリティ
│
├── GAME_CONCEPT.md           # ゲームコンセプトドキュメント
├── TECHNICAL_DESIGN.md       # 技術設計ドキュメント
└── README.md                 # このファイル
```

---

## 🎮 開発フェーズ

### Phase 1: MVP（最小限の機能） - 進行中
- [ ] プロジェクトセットアップ
- [ ] データモデル実装
- [ ] HealthKit連携
- [ ] 基本的な戦闘システム
- [ ] シンプルなUI
- [ ] 装備システム
- [ ] デイリーミッション
- [ ] ランダムイベント

### Phase 2: 拡張機能
- [ ] スキルシステム
- [ ] 複数エリア
- [ ] ボス戦
- [ ] 実績システム

### Phase 3: エンゲージメント強化
- [ ] ウィークリーミッション
- [ ] 装備強化
- [ ] レアアイテム・ガチャ

### Phase 4: パーティーシステム（将来）
- [ ] 仲間キャラクター
- [ ] キャラメイク
- [ ] パーティー編成

---

## 🧪 テスト

### 単体テスト
```bash
# Xcodeでテストを実行
⌘U
```

### 実機テスト
HealthKitはシミュレーターで動作しないため、必ず実機でテストしてください。

### TestFlight配信
ベータ版のテストにはTestFlightを使用します。

---

## 🐛 既知の問題

現在、既知の問題はありません。

---

## 🤝 コントリビューション

このプロジェクトは現在、個人開発プロジェクトです。

---

## 📝 開発メモ

### ゲームバランス調整

ゲームバランスは`Utils/GameBalance.swift`で一元管理しています。
調整が必要な場合は、このファイルの値を変更してください。

主な調整ポイント:
- レベルアップに必要な経験値
- 戦闘間隔（放置時）
- ランダムイベントの発生確率
- 装備の価格とステータス
- 敵の強さと報酬

### データのリセット

開発中にゲームデータをリセットしたい場合:
1. アプリをアンインストール
2. Xcodeから再インストール

または、`PlayerRepository`に`resetAllData()`メソッドを追加して、デバッグメニューから呼び出せるようにします。

---

## 📄 ライセンス

このプロジェクトのライセンスは未定です。

---

## 📧 連絡先

質問や提案があれば、Issueを作成してください。

---

## 🙏 謝辞

このゲームは、歩数計アプリとRPGゲームを組み合わせた新しい試みです。
日々の歩行をゲーム体験に変えることで、健康的な生活とエンターテイメントの両立を目指しています。

---

**Let's walk and adventure! 🚶‍♂️⚔️**
