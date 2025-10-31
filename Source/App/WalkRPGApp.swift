//
//  WalkRPGApp.swift
//  WalkRPG
//
//  アプリのエントリーポイント
//

import SwiftUI
import SwiftData

@main
struct WalkRPGApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .modelContainer(for: [
                    Player.self,
                    Equipment.self,
                    Battle.self,
                    DailyMission.self,
                    RandomEvent.self
                ])
        }
    }
}
