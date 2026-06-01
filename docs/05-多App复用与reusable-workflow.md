# 05 · 多 App 复用（reusable workflow）

把发布逻辑集中在**本公共仓库**，每个 App 私有仓库只写几行调用它。

## 共用 vs 每 App 独立

| 内容 | 共用一份 | 位置 |
|------|----------|------|
| 发布逻辑（签名/公证/打包/appcast/发布） | ✅ | 本仓库 `.github/workflows/release-reusable.yml` |
| 辅助脚本（含 `update_appcast.py`） | ✅ | 本仓库 `scripts/` |
| 签名证书 / Apple 凭据 / PAT | ✅ | Secret（个人账号=每仓库各设一次；组织=组织级设一次） |
| Sparkle 私钥 | ⚠️ 建议每 App 一对 | Secret |
| `app_name`/`scheme`/`project`/`public_repo`/`download_url_prefix` | ❌ 每 App 不同 | 调用方 `with:` |
| 调用方 workflow + `ExportOptions.plist` | ❌ 每 App 一份 | App 私有仓库 |

> 公共仓库里的 reusable workflow 只含**逻辑**，密钥永远在**调用方**环境解析，公开无泄露风险。

## 接入一个新 App（3 步）

**1. 在 App 私有仓库放调用方 workflow + ExportOptions**
- 复制 `templates/caller-workflow.yml` → `.github/workflows/release.yml`，替换 `{{APP_NAME}}`/`{{XCODE_SCHEME}}`/`{{PROJECT}}`/`{{PUBLIC_REPO}}`/`{{DOWNLOAD_URL_PREFIX}}`
- 复制 `templates/ExportOptions.plist` → 仓库根目录，填 `{{APPLE_TEAM_ID}}`
- 确认 `uses:` 指向 `macuhy/macos-app-release-kit/.github/workflows/release-reusable.yml@main`

**2. 配置密钥**
- **个人账号**：在该 App 私有仓库跑一次 `scripts/setup-secrets.sh`（共用值直接复用，Sparkle 私钥按需换）。
- **组织**：若已在组织级设过 `--visibility all`，本步骤跳过，`secrets: inherit` 自动继承。

**3. App 端集成 Sparkle**（见 `docs/04`）+ 建好对应公共分发仓库（见 `docs/01`）。

完成后：`git tag v1.0.0 && git push origin v1.0.0` 即触发。

## 版本锁定建议
生产环境把 `@main` 换成锁定的 tag 或 commit SHA，避免 kit 仓库改动影响线上发布：
```yaml
uses: macuhy/macos-app-release-kit/.github/workflows/release-reusable.yml@v1
```
（给本 kit 仓库打个 `v1` tag 即可。）

## 组织级密钥（真正"配一次到处用"）
```bash
gh secret set DEVELOPER_ID_CERTIFICATE_P12       --org <组织> --visibility all
gh secret set DEVELOPER_ID_CERTIFICATE_PASSWORD  --org <组织> --visibility all
gh secret set APPLE_TEAM_ID                      --org <组织> --visibility all
gh secret set ASC_KEY_ID                         --org <组织> --visibility all
gh secret set ASC_ISSUER_ID                      --org <组织> --visibility all
gh secret set ASC_API_KEY_P8                     --org <组织> --visibility all
gh secret set RELEASE_REPO_PAT                   --org <组织> --visibility all
# 以上 macOS + iOS 两条管线共用；iOS 另需 IOS_DIST_CERT_P12/_PASSWORD（也可组织级）
# SPARKLE_PRIVATE_KEY 建议放到各 App 仓库级（每 App 一对密钥）
```
