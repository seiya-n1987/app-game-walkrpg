//
//  HealthKitService.swift
//  WalkRPG
//
//  HealthKitと連携して歩数データを取得
//

import Foundation
import HealthKit

class HealthKitService: ObservableObject {
    static let shared = HealthKitService()

    private let healthStore = HKHealthStore()
    private let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!

    @Published var isAuthorized = false
    @Published var todaySteps = 0
    @Published var lastError: Error?

    private var observerQuery: HKObserverQuery?

    private init() {
        checkAuthorizationStatus()
    }

    // MARK: - Authorization

    /// HealthKitの認証状態を確認
    func checkAuthorizationStatus() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device")
            return
        }

        let status = healthStore.authorizationStatus(for: stepCountType)
        isAuthorized = (status == .sharingAuthorized)
    }

    /// HealthKitへのアクセス許可をリクエスト
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }

        let typesToRead: Set<HKObjectType> = [stepCountType]

        try await healthStore.requestAuthorization(toShare: [], read: typesToRead)

        await MainActor.run {
            self.isAuthorized = true
        }
    }

    // MARK: - Step Count Queries

    /// 今日の歩数を取得
    func getTodaySteps() async throws -> Int {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)

        return try await getSteps(from: startOfDay, to: now)
    }

    /// 指定期間の歩数を取得
    func getSteps(from startDate: Date, to endDate: Date) async throws -> Int {
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )

        let query = HKStatisticsQuery(
            quantityType: stepCountType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            // クエリのコールバック（非同期処理のため空実装）
        }

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepCountType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let result = result,
                      let sum = result.sumQuantity() else {
                    continuation.resume(returning: 0)
                    return
                }

                let steps = Int(sum.doubleValue(for: HKUnit.count()))
                continuation.resume(returning: steps)
            }

            healthStore.execute(query)
        }
    }

    /// 過去N日間の歩数を取得
    func getStepsForPastDays(_ days: Int) async throws -> [Date: Int] {
        let calendar = Calendar.current
        let now = Date()
        var stepsData: [Date: Int] = [:]

        for dayOffset in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: now) else {
                continue
            }

            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date

            let steps = try await getSteps(from: startOfDay, to: endOfDay)
            stepsData[startOfDay] = steps
        }

        return stepsData
    }

    /// 総歩数を取得（アプリインストール以降）
    func getTotalSteps(since startDate: Date) async throws -> Int {
        return try await getSteps(from: startDate, to: Date())
    }

    // MARK: - Real-time Updates

    /// 歩数の変更を監視
    func startObservingSteps(updateHandler: @escaping (Int) -> Void) {
        guard isAuthorized else {
            print("HealthKit not authorized")
            return
        }

        // 既存のクエリを停止
        stopObservingSteps()

        // オブザーバークエリを作成
        observerQuery = HKObserverQuery(
            sampleType: stepCountType,
            predicate: nil
        ) { [weak self] _, completionHandler, error in
            if let error = error {
                print("Observer query error: \(error.localizedDescription)")
                completionHandler()
                return
            }

            // 歩数が更新されたら最新の歩数を取得
            Task {
                do {
                    let steps = try await self?.getTodaySteps() ?? 0
                    await MainActor.run {
                        self?.todaySteps = steps
                        updateHandler(steps)
                    }
                } catch {
                    print("Failed to fetch steps: \(error.localizedDescription)")
                }

                completionHandler()
            }
        }

        if let query = observerQuery {
            healthStore.execute(query)

            // バックグラウンド配信を有効化
            healthStore.enableBackgroundDelivery(
                for: stepCountType,
                frequency: .immediate
            ) { success, error in
                if let error = error {
                    print("Failed to enable background delivery: \(error.localizedDescription)")
                } else if success {
                    print("Background delivery enabled for step count")
                }
            }
        }
    }

    /// 歩数の監視を停止
    func stopObservingSteps() {
        if let query = observerQuery {
            healthStore.stop(query)
            observerQuery = nil
        }

        // バックグラウンド配信を無効化
        healthStore.disableBackgroundDelivery(for: stepCountType) { success, error in
            if let error = error {
                print("Failed to disable background delivery: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Helper Methods

    /// 今日の歩数を定期的に更新
    func updateTodaySteps() async {
        do {
            let steps = try await getTodaySteps()
            await MainActor.run {
                self.todaySteps = steps
            }
        } catch {
            await MainActor.run {
                self.lastError = error
            }
            print("Failed to update today's steps: \(error.localizedDescription)")
        }
    }

    /// 歩数データを手動でリフレッシュ
    func refreshSteps() async throws {
        await updateTodaySteps()
    }
}

// MARK: - Errors

enum HealthKitError: Error, LocalizedError {
    case notAvailable
    case notAuthorized
    case queryFailed

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKitはこのデバイスで利用できません"
        case .notAuthorized:
            return "HealthKitへのアクセスが許可されていません"
        case .queryFailed:
            return "歩数データの取得に失敗しました"
        }
    }
}

// MARK: - Mock Service (for Simulator/Testing)

#if targetEnvironment(simulator)
extension HealthKitService {
    /// シミュレーター用のモック歩数を生成
    func generateMockSteps() -> Int {
        // ランダムな歩数を生成（0〜15000歩）
        return Int.random(in: 0...15000)
    }

    /// シミュレーター用に今日の歩数を設定
    func setMockTodaySteps(_ steps: Int) {
        todaySteps = steps
    }
}
#endif
