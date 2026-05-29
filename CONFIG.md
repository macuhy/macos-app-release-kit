# 配置变量清单（先填这里）

> 这是整套工具的**唯一变量来源**。所有模板文件里的 `{{占位符}}` 都对应下表。
> AI 复用方式：读取本文件的「填写值」列，对 `templates/` 下所有文件做全局替换即可。

## 1. 项目变量（替换模板中的 `{{占位符}}`）

| 占位符 | 含义 | 示例 | 你的填写值 |
|--------|------|------|-----------|
| `{{APP_NAME}}` | App 名称（与 .app 产物、scheme 一致） | `MyCoolApp` | `Kown` |
| `{{XCODE_SCHEME}}` | Xcode scheme 名 | `MyCoolApp` | `Kown` |
| `{{PROJECT}}` | .xcodeproj 路径 | `MyCoolApp.xcodeproj` | `mac/Kown.xcodeproj` |
| `{{BUNDLE_ID}}` | App 的 Bundle Identifier | `com.acme.mycoolapp` | `com.xiaobo.kown` |
| `{{PRIVATE_REPO}}` | 私有源码仓库 `owner/repo` | `acme/mycoolapp` | `macuhy/kown` |
| `{{PUBLIC_REPO}}` | 公共分发仓库 `owner/repo` | `acme/mycoolapp-releases` | `macuhy/kown-mac` |
| `{{PUBLIC_OWNER}}` | 公共仓库所属用户/组织 | `acme` | `macuhy`（组织） |
| `{{SPARKLE_PUBLIC_KEY}}` | Sparkle EdDSA 公钥（generate_keys 打印） | `pfIShF...=` | `QxXWME0pGom6NLGkoNq6AdkK8h+i+ZttNeED2No5HT8=` |
| `{{APPCAST_URL}}` | App 拉取的更新源地址 | `https://raw.githubusercontent.com/acme/mycoolapp-releases/main/appcast.xml` | `https://raw.githubusercontent.com/macuhy/kown-mac/main/appcast.xml` |
| `{{DOWNLOAD_URL_PREFIX}}` | 产物（ZIP）下载直链前缀 | `https://github.com/acme/mycoolapp-releases/releases/download/` | `https://github.com/macuhy/kown-mac/releases/download/` |

## 2. GitHub Secrets（共 7 个，设置在【私有仓库】或【组织】，见 docs/02）

| Secret 名 | 含义 | 怎么拿 |
|-----------|------|--------|
| `DEVELOPER_ID_CERTIFICATE_P12` | Developer ID Application 证书 (.p12) 的 base64 | `scripts/export-cert.sh` |
| `DEVELOPER_ID_CERTIFICATE_PASSWORD` | 导出 .p12 时设的密码 | 你自己设 |
| `APPLE_ID` | Apple 开发者账号邮箱 | 你的账号 |
| `APPLE_TEAM_ID` | 10 位 Team ID | developer.apple.com → Membership |
| `APPLE_ID_PASSWORD` | App 专用密码（公证用） | appleid.apple.com → 登录与安全 → App 专用密码 |
| `SPARKLE_PRIVATE_KEY` | Sparkle EdDSA 私钥 | `scripts/export-sparkle-key.sh` |
| `RELEASE_REPO_PAT` | 对公共仓库有 contents:write 的细粒度 PAT | github.com/settings/tokens?type=beta |

> 钥匙串密码已不再需要 secret——workflow 用 `openssl rand` 临时随机生成。
> 共用性：前 5 个（Apple 身份）可跨 App 共用；`SPARKLE_PRIVATE_KEY` 本套配置**所有 App 共用同一把**（公钥见上表，私钥已设为 secret）；`RELEASE_REPO_PAT` 同 owner 公共仓库可共用。详见 docs/05。

## 3. 版本号策略

- App `Info.plist` 的 `CFBundleVersion`（build 号）**每次发布必须递增**，否则 Sparkle 检测不到更新。
- 本工具用 **git tag** 作为版本来源：推送 `v1.2.0` → `CFShortVersionString=1.2.0`，build 号用 `git rev-list --count HEAD` 自动生成。
