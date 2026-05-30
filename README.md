# macOS / iOS App 自动打包 & 发布工具套件

两条独立管线，私有仓库源码自动编译签名：
- **macOS**：编译 → 签名 → 公证 → 发布到**公共仓库**供下载，App 内嵌 Sparkle 自动弹窗提示更新。
- **iOS**：编译 → 签名 → 用 App Store Connect API Key 自动上传 **TestFlight 内部测试**（见 [`docs/07`](docs/07-iOS上线TestFlight.md)）。

> 🔥 **接入前必读**：[`经验总结.md`](经验总结.md) —— 实战 5 个必踩坑 + 新 App 接入清单；
> 真实实例配置见 [`docs/06-本实例配置与踩坑.md`](docs/06-本实例配置与踩坑.md)。

## 技术选型
- **Sparkle 2.x** — macOS 自动更新（弹窗 UI + EdDSA 签名校验）
- **GitHub Actions** — 私有仓库打 tag → 自动编译 → 公证 → 发布到公共仓库
- **EdDSA + codesign/notarize** — 双重防伪 + 通过 Gatekeeper

## 目录
```
macos-app-release-kit/
├── CONFIG.md                  ← 先填这里（唯一变量来源）
├── .github/workflows/
│   └── release-reusable.yml   ← 可复用工作流（多 App 共用一份逻辑）
├── docs/
│   ├── 01-初始化仓库.md        ← 创建私有/公共两个仓库
│   ├── 02-环境变量与密钥.md     ← 生成证书、密钥、PAT，设置 Secrets
│   ├── 03-配置发布流程.md       ← 放置 workflow，触发发布
│   ├── 04-App端集成Sparkle.md  ← App 内加自动更新弹窗
│   ├── 05-多App复用与reusable-workflow.md  ← 方案C：一份逻辑、多 App 调用
│   └── 07-iOS上线TestFlight.md ← iOS 管线：自动传 TestFlight 内部测试
├── .github/workflows/
│   ├── release-reusable.yml        ← macOS 可复用工作流
│   └── ios-testflight-reusable.yml ← iOS 可复用工作流
├── templates/
│   ├── caller-workflow.yml    ← 【macOS】调用方（每个 App 仓库放这个，几行）
│   ├── caller-ios.yml         ← 【iOS】调用方
│   ├── release.yml            ← 自包含版工作流（不依赖 kit 仓库时用）
│   ├── ExportOptions.plist    ← macOS archive 导出配置（放 App 仓库根目录）
│   ├── ExportOptions-iOS.plist ← iOS App Store 导出配置
│   ├── UpdaterManager.swift   ← App 端更新管理器
│   ├── Info.plist.snippet     ← Info.plist 需追加的键
│   └── appcast-initial.xml    ← 公共仓库初始 appcast
└── scripts/
    ├── update_appcast.py      ← 增量写入 appcast.xml 的一条 item
    ├── export-cert.sh         ← 把 .p12 证书转 base64
    ├── export-asc-key.sh      ← 把 App Store Connect API .p8 转 base64
    ├── export-sparkle-key.sh  ← 导出 Sparkle 私钥
    └── setup-secrets.sh       ← 用 gh CLI 一键设置所有 Secrets
```

## AI 复用流程（给自动化代理的指令）
1. 读 `CONFIG.md`，向用户索取「填写值」列的所有变量。
2. 对 `templates/` 下所有文件做全局 `{{占位符}}` → 实际值 替换。
3. 按 `docs/01 → 02 → 03 → 04` 顺序执行其中的命令。
4. 把 `templates/release.yml` 放到私有仓库 `.github/workflows/release.yml`。
5. 把 `UpdaterManager.swift` 加进 App，`Info.plist.snippet` 合并进 `Info.plist`。

## 人类快速上手
按 `docs/01 → 04` 顺序操作即可，每篇都有可直接粘贴的命令。
