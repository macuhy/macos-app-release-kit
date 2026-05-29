# macOS App 自动打包 & 发布工具套件

把**私有仓库的源码**自动编译、签名、公证，并发布到**公共仓库**供用户下载；
App 内嵌 Sparkle，自动弹窗提示最新版本。仅适配 macOS。

## 技术选型
- **Sparkle 2.x** — macOS 自动更新（弹窗 UI + EdDSA 签名校验）
- **GitHub Actions** — 私有仓库打 tag → 自动编译 → 公证 → 发布到公共仓库
- **EdDSA + codesign/notarize** — 双重防伪 + 通过 Gatekeeper

## 目录
```
macos-app-release-kit/
├── CONFIG.md                  ← 先填这里（唯一变量来源）
├── docs/
│   ├── 01-初始化仓库.md        ← 创建私有/公共两个仓库
│   ├── 02-环境变量与密钥.md     ← 生成证书、密钥、PAT，设置 Secrets
│   ├── 03-配置发布流程.md       ← 放置 workflow，触发发布
│   └── 04-App端集成Sparkle.md  ← App 内加自动更新弹窗
├── templates/
│   ├── release.yml            ← GitHub Actions 工作流
│   ├── UpdaterManager.swift   ← App 端更新管理器
│   ├── Info.plist.snippet     ← Info.plist 需追加的键
│   └── appcast-initial.xml    ← 公共仓库初始 appcast
└── scripts/
    ├── export-cert.sh         ← 把 .p12 证书转 base64
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
