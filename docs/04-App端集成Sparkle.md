# 04 · App 端集成 Sparkle（自动弹窗）

## 1. 添加 Sparkle 依赖
Xcode → File → Add Package Dependencies → 输入：
```
https://github.com/sparkle-project/Sparkle
```
选择 2.x 最新版，添加到你的 App target。

## 2. 合并 Info.plist
把 `templates/Info.plist.snippet` 里的键加进你的 `Info.plist`（变量已替换）。关键项：
- `SUFeedURL` = `{{APPCAST_URL}}`
- `SUPublicEDKey` = `{{SPARKLE_PUBLIC_KEY}}`
- `SUEnableAutomaticChecks` = `true`
- `SUScheduledCheckInterval` = `86400`（每天检查一次）
- `SURequireSignedFeed` + `SUVerifyUpdateBeforeExtraction`（开启 feed 签名校验，更安全）

## 3. 加入更新管理器
把 `templates/UpdaterManager.swift` 拖进工程，并在 App 入口接入（文件内有完整示例）：

```swift
@main
struct {{APP_NAME}}App: App {
    @StateObject private var updater = UpdaterManager()
    var body: some Scene {
        WindowGroup { ContentView() }
        .commands {
            CommandGroup(after: .appInfo) {
                Button("检查更新…") { updater.checkForUpdates() }
            }
        }
    }
}
```

效果：
- App 启动后按 `SUScheduledCheckInterval` 自动后台检查
- 发现新版本 → Sparkle **自动弹出更新窗口**（含 release notes、下载进度、一键安装并重启）
- 菜单栏「检查更新…」可手动触发

## 4. 沙盒 App（如上架受限或用了 App Sandbox）
需在 entitlements 增加：
```xml
<key>com.apple.security.network.client</key><true/>
```
并按 Sparkle 文档配置 XPC 服务。非沙盒 App 无需此步。

## 5. 本地联调
1. 临时把 `SUScheduledCheckInterval` 设小（如 `60`）或调用 `checkForUpdates()`
2. 确保本地运行的 App `CFBundleVersion` **低于** 已发布版本
3. 启动后应弹出更新提示 → 走完下载安装流程即验证成功

## release notes 怎么来
workflow 用 git tag 的描述/Release body 生成 `.html`/`.md`，`generate_appcast` 自动关联为 `releaseNotesLink`，用户在更新弹窗里能看到。
