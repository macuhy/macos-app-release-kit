//  UpdaterManager.swift
//  通用 Sparkle 自动更新管理器（拷进任意 SwiftUI macOS App 即可复用）
//
//  依赖: Sparkle 2.x  (SPM: https://github.com/sparkle-project/Sparkle)
//  配套: Info.plist 中需配置 SUFeedURL / SUPublicEDKey 等（见 Info.plist.snippet）

import SwiftUI
import Sparkle

/// 包装 Sparkle 的标准更新控制器。
/// - `startingUpdater: true` → App 启动后即按 Info.plist 的 SUScheduledCheckInterval 自动检查并弹窗。
/// - 暴露 `checkForUpdates()` 供菜单/按钮手动触发。
/// - 通过 `canCheckForUpdates` 可绑定按钮可用状态。
final class UpdaterManager: ObservableObject {
    private let updaterController: SPUStandardUpdaterController

    /// 手动「检查更新」按钮是否可点（Sparkle 正在检查时自动置灰）。
    @Published var canCheckForUpdates = false

    init() {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
        updaterController.updater
            .publisher(for: \.canCheckForUpdates)
            .assign(to: &$canCheckForUpdates)
    }

    /// 手动触发一次更新检查（会弹出 Sparkle 标准 UI）。
    func checkForUpdates() {
        updaterController.updater.checkForUpdates()
    }

    /// 暴露底层 updater，按需做高级配置（如开关自动下载）。
    var updater: SPUUpdater { updaterController.updater }
}

/// 可直接放进菜单的「检查更新…」按钮。
struct CheckForUpdatesMenuItem: View {
    @ObservedObject var updater: UpdaterManager
    var body: some View {
        Button("检查更新…") { updater.checkForUpdates() }
            .disabled(!updater.canCheckForUpdates)
    }
}

// ───────────────────────────────────────────────────────────────
// 在 App 入口这样接入（示例，按需替换 {{APP_NAME}} 与 ContentView）：
//
// @main
// struct {{APP_NAME}}App: App {
//     @StateObject private var updater = UpdaterManager()
//     var body: some Scene {
//         WindowGroup { ContentView() }
//             .commands {
//                 CommandGroup(after: .appInfo) {
//                     CheckForUpdatesMenuItem(updater: updater)
//                 }
//             }
//     }
// }
// ───────────────────────────────────────────────────────────────
