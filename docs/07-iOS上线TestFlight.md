# 07 · iOS 自动上线 TestFlight（内部测试）

与 macOS 管线（docs/01–05）**互相独立**：iOS 这条不公证、不发公共仓库、不用 Sparkle，
而是用 **App Store Connect API Key** 把 `.ipa` 自动上传到 TestFlight。处理完**内部测试员自动可见，无需 Beta 审核**。

> **自动签名**：用了 iCloud 等受限 entitlement 也无需手动建 provisioning profile——
> workflow 用 `-allowProvisioningUpdates` + API Key 让 Xcode 现签/续期 profile，**省掉每年维护 profile 的麻烦**。

---

## 一次性准备（4 样东西，全部所有 iOS App 公用）

### A. App Store Connect API Key → `ASC_KEY_ID` / `ASC_ISSUER_ID` / `ASC_API_KEY_P8`
既用于上传 TestFlight，也用于现签 profile。
1. [App Store Connect](https://appstoreconnect.apple.com) → **Users and Access → Integrations → App Store Connect API** → Keys → **+**。
2. 角色选 **App Manager**（或 Admin）→ 生成。
3. 记下 **Key ID**（= `ASC_KEY_ID`）和页面上方的 **Issuer ID**（= `ASC_ISSUER_ID`）。
4. **下载 `.p8`（只能下一次！）**，转 base64：
```bash
bash scripts/export-asc-key.sh ~/Downloads/AuthKey_ABCDE12345.p8   # → ASC_API_KEY_P8
```

### B. Apple Distribution 证书 → `IOS_DIST_CERT_P12` / `IOS_DIST_CERT_PASSWORD`
⚠️ 是 **Apple Distribution**，不是 macOS 用的 Developer ID Application。
1. developer.apple.com → Certificates → **+** → **Apple Distribution** → 创建并下载，导入钥匙串。
2. 钥匙串里导出为 `.p12`（设个密码 = `IOS_DIST_CERT_PASSWORD`）。
3. 转 base64：
```bash
bash scripts/export-cert.sh ~/Downloads/Distribution.p12   # → IOS_DIST_CERT_P12
```

### C. Team ID → `APPLE_TEAM_ID`
developer.apple.com → Membership 的 10 位 Team ID（与 macOS 管线共用同一个 secret）。

### D. 先在 App Store Connect 建好 App 记录
首次上传前，App Store Connect → **My Apps → + → New App**，bundle id 选你的 App ID。
**没有这条记录，altool 上传会失败。**
> 也确认 developer.apple.com → Identifiers 里该 App ID 已开启 **iCloud** capability（自动签名据此现签 profile）。

---

## 写入 6 个 Secrets（设在私有仓库或组织级，全部 iOS App 公用）
```bash
gh secret set ASC_KEY_ID                        --repo {{PRIVATE_REPO}} --body "你的KeyID"
gh secret set ASC_ISSUER_ID                     --repo {{PRIVATE_REPO}} --body "你的IssuerID"
gh secret set ASC_API_KEY_P8                    --repo {{PRIVATE_REPO}} --body "$(bash scripts/export-asc-key.sh ~/Downloads/AuthKey_XXX.p8)"
gh secret set IOS_DIST_CERT_P12                 --repo {{PRIVATE_REPO}} --body "$(bash scripts/export-cert.sh ~/Downloads/Distribution.p12)"
gh secret set IOS_DIST_CERT_PASSWORD            --repo {{PRIVATE_REPO}} --body "导出p12时设的密码"
gh secret set APPLE_TEAM_ID                     --repo {{PRIVATE_REPO}} --body "你的TeamID"   # macOS 已设过则跳过
```
> 多 App 复用：把这 6 个设成**组织级**（`gh secret set X --org 组织 --visibility all`），新 App 无需重设。
> 即便组织级，`caller-ios.yml` 仍要逐个显式传（reusable workflow 跨仓库不继承组织 secret）——模板已写好。

---

## 放置文件
1. `templates/ExportOptions-iOS.plist` → App 仓库根目录，替换 `{{APPLE_TEAM_ID}}`。
2. `templates/caller-ios.yml` → App 仓库 `.github/workflows/testflight.yml`，替换 `{{APP_NAME}}` / `{{IOS_SCHEME}}` / `{{IOS_PROJECT}}`。

## 触发
```bash
git tag v1.0.0 && git push origin v1.0.0
```
或 Actions 页手动 Run（填版本号，会自动打 tag）。
跑通后 → App Store Connect → TestFlight，等几分钟处理 → 新 build 出现 → 内部测试员收到。

---

## 踩坑提示
- **build 号必须递增**：本工作流用 `git rev-list --count HEAD` 自动生成，单调递增；同一 `MARKETING_VERSION` 下 build 号重复，TestFlight 会拒。
- **首次上传前 App 记录必须存在**（上面 D 步），否则 altool 报找不到 App。
- **内部测试无需 Beta App Review**：上传处理完，已加入 App Store Connect 的内部测试员自动可见。外部测试组才需要审核（本套不涉及）。
- **自动签名首次会现签 "Xcode Managed" profile**：确保 App ID 已开 iCloud capability，否则现签的 profile 不含该 entitlement。
- 与 macOS 管线 secret 完全兼容：`ASC_*`、`APPLE_TEAM_ID` 两边共用；证书各用各的（Distribution vs Developer ID）。
