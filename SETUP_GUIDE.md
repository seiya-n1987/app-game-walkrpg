# WalkRPG セットアップガイド

このガイドでは、WalkRPGをXcodeで実行するまでの手順を説明します。

---

## 📋 前提条件

- **macOS**: 13.0 (Ventura) 以降
- **Xcode**: 15.0以降
- **iOS実機**: iPhone（iOS 16.0以降）
  - ⚠️ HealthKitはシミュレーターでは動作しないため、実機が必要です

---

## 🚀 セットアップ手順

### Step 1: Xcodeプロジェクトの作成

1. **Xcodeを起動**

2. **新しいプロジェクトを作成**
   - "Create a new Xcode project" を選択
   - **iOS** → **App** テンプレートを選択
   - "Next" をクリック

3. **プロジェクト設定**
   - **Product Name**: `WalkRPG`
   - **Team**: あなたのApple Developer Team（または個人用）
   - **Organization Identifier**: `com.yourname` （適宜変更してください）
   - **Interface**: `SwiftUI`
   - **Storage**: `SwiftData`（iOS 17+の場合）
   - **Language**: `Swift`
   - **Include Tests**: お好みで（チェックを外しても構いません）

4. **保存場所**
   - **このリポジトリのディレクトリを選択**してください
   - "Create" をクリック

### Step 2: ソースファイルの追加

1. **Xcodeプロジェクトナビゲーターで、デフォルトで作成されたファイルを削除**
   - `ContentView.swift` を削除（右クリック → Delete → Move to Trash）
   - その他の不要なファイルも削除

2. **このリポジトリの `Source/` ディレクトリをXcodeにドラッグ&ドロップ**
   - Finderで `Source/` フォルダを開く
   - `Source/` フォルダ全体をXcodeのプロジェクトナビゲーターにドラッグ
   - 表示されるダイアログで以下を選択:
     - ✅ **Copy items if needed**
     - ✅ **Create groups**
     - ✅ ターゲット（WalkRPG）にチェック
   - "Finish" をクリック

### Step 3: Capabilityの追加

1. **プロジェクト設定を開く**
   - プロジェクトナビゲーターでプロジェクト名（WalkRPG）をクリック
   - **TARGETS** → **WalkRPG** を選択

2. **HealthKitを追加**
   - "Signing & Capabilities" タブを開く
   - "+ Capability" をクリック
   - "HealthKit" を検索して追加

3. **Background Modesを追加**
   - "+ Capability" をクリック
   - "Background Modes" を検索して追加
   - 以下にチェックを入れる:
     - ✅ Background fetch
     - ✅ Background processing

### Step 4: Info.plist の設定

1. **Info.plist を開く**
   - プロジェクトナビゲーターで "Info" タブを選択
   - または `Info.plist` ファイルを開く

2. **HealthKit の権限説明を追加**
   - "+" ボタンをクリックして以下を追加:

   ```
   Privacy - Health Share Usage Description
   値: 歩数データを使用してキャラクターを成長させます
   ```

   ```
   Privacy - Health Update Usage Description
   値: ゲームの進行に歩数データを使用します
   ```

3. **（オプション）通知の権限説明を追加**
   ```
   Privacy - User Notifications Usage Description
   値: レベルアップやイベント発生時に通知します
   ```

### Step 5: ビルド設定

1. **Deployment Target を設定**
   - プロジェクト設定 → "Build Settings" タブ
   - "iOS Deployment Target" を **iOS 16.0** に設定

2. **Bundle Identifier を確認**
   - "Signing & Capabilities" タブ
   - Bundle Identifier が一意であることを確認
   - 例: `com.yourname.WalkRPG`

3. **Signing (署名) を設定**
   - "Automatically manage signing" にチェック
   - Team を選択（Apple IDでサインイン済みの場合）

### Step 6: ビルドとデバッグ

1. **ビルド**
   - メニューバー: **Product** → **Build** (⌘B)
   - エラーがないことを確認

2. **iPhone実機を接続**
   - USBケーブルでiPhoneをMacに接続
   - iPhoneで "このコンピュータを信頼" を選択

3. **実行**
   - Xcodeの上部で接続したiPhoneを選択
   - **Product** → **Run** (⌘R)

4. **初回実行時の設定（iPhoneで）**
   - 設定 → 一般 → VPNとデバイス管理
   - あなたのApple IDの下のプロファイルを選択
   - "信頼" をタップ

5. **アプリを起動**
   - WalkRPGアプリを起動
   - HealthKitの権限許可ダイアログで "許可" を選択

---

## 🎮 アプリの使い方（MVP版）

### メイン画面
- **プレイヤーステータス**: レベル、HP、攻撃力、防御力を表示
- **歩数進捗**: 今日の歩数とレベルアップまでの進捗
- **クイックアクション**:
  - "戦闘" ボタン: 手動で敵と戦闘
  - "更新" ボタン: 歩数データを更新
  - （デバッグビルドのみ）歩数+1000、ゴールド+500 ボタン
- **デイリーミッション**: 進行中のミッション表示
- **戦闘ログ**: 最近の戦闘結果

### ショップ画面
- **ショップタブ**: 購入可能な装備を表示
  - タップして購入
- **所持装備タブ**: 所有している装備を表示
  - "装備" ボタンで装備/解除
  - "売却" ボタンで売却（装備中は不可）

### スキル画面
- **スキルポイント**: レベルアップで獲得
- **スキル強化**: "強化" ボタンでスキルレベルアップ
- 4種類のスキル:
  - パワーアタック（攻撃力UP）
  - 鉄壁（防御力UP）
  - 回復（HP回復量UP）
  - ラッキー（ドロップ率UP）

---

## 🐛 トラブルシューティング

### ビルドエラーが出る

**エラー: "Cannot find 'Player' in scope"**
- `Source/Models/Player.swift` が正しく追加されているか確認
- プロジェクトナビゲーターでファイルがターゲットに含まれているか確認

**エラー: "Missing required module 'SwiftData'"**
- iOS Deployment Target が 17.0 以上であることを確認
- または、SwiftData を CoreData に変更（高度な変更が必要）

### HealthKitが動作しない

**歩数が0のまま**
1. iPhoneの設定 → ヘルスケア → データアクセスとデバイス → WalkRPG
2. "歩数" が許可されているか確認
3. 実機で実際に歩いてみる（シミュレーターでは動作しません）

**シミュレーターでテストしたい場合**
- デバッグボタン（"歩数+1000"）を使用してテスト

### アプリが起動しない

**クラッシュする**
- Xcodeのコンソールでエラーメッセージを確認
- SwiftData の初期化エラーの可能性
  - アプリを削除して再インストール

---

## 📱 実機でのテスト方法

### 歩数連携のテスト
1. iPhoneを持って実際に歩く（100歩程度）
2. アプリを開く
3. 下にスワイプして更新（Pull to Refresh）
4. 歩数が反映されることを確認
5. 経験値が増加してレベルアップすることを確認

### 戦闘システムのテスト
1. "戦闘" ボタンをタップ
2. 戦闘ログに結果が表示されることを確認
3. ゴールドや経験値が増加することを確認

### 装備システムのテスト
1. ショップタブを開く
2. 装備を購入
3. "所持装備" タブに移動
4. "装備" ボタンで装備
5. メイン画面でステータスが変化することを確認

---

## 🔧 デバッグ機能

DEBUG ビルドでは以下のデバッグボタンが利用可能です:

- **歩数+1000**: 歩数を1000歩追加（レベルアップテスト用）
- **ゴールド+500**: ゴールドを500追加（装備購入テスト用）

これらはメイン画面の「クイックアクション」セクションに表示されます。

---

## 🎯 次のステップ（MVP以降）

このMVP版は基本機能のみを実装しています。以下の機能は未実装です:

### 実装済み ✅
- プレイヤーステータス管理
- 歩数計測とレベルアップ
- 戦闘システム（手動・放置）
- 装備購入・装備変更
- スキルシステム
- デイリーミッション（表示のみ）

### 未実装（将来の拡張）
- データ永続化（アプリ再起動でリセットされます）
- 放置戦闘の自動実行（バックグラウンド）
- ランダムイベント（レアショップなど）
- 通知システム
- ミッション報酬の自動付与
- iCloud同期

### データ永続化を追加するには
現在、プレイヤーデータはアプリ再起動で失われます。
永続化するには:
1. `GameViewModel` でSwiftDataの `@Query` を使用
2. プレイヤーデータを保存・読み込む処理を追加
3. UserDefaultsで最後のセッション情報を保存

詳細は `TECHNICAL_DESIGN.md` を参照してください。

---

## 📞 サポート

問題が発生した場合:
1. このREADME.mdとSETUP_GUIDE.mdを再度確認
2. Xcodeのコンソールログを確認
3. GitHubのIssueで報告

---

**楽しいゲーム開発を！ 🎮⚔️**
