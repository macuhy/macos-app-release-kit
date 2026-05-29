#!/usr/bin/env bash
# 一键把所有 Secrets 写入【私有仓库】。
# 先 export 下列环境变量（见 docs/02），再运行本脚本。
#   PRIVATE_REPO, BUILD_CERTIFICATE_BASE64, P12_PASSWORD, KEYCHAIN_PASSWORD,
#   APPLE_ID, APPLE_TEAM_ID, APPLE_APP_PASSWORD, SPARKLE_PRIVATE_KEY, RELEASE_REPO_PAT
set -euo pipefail

: "${PRIVATE_REPO:?需要 export PRIVATE_REPO=owner/repo}"

required=(
  BUILD_CERTIFICATE_BASE64 P12_PASSWORD KEYCHAIN_PASSWORD
  APPLE_ID APPLE_TEAM_ID APPLE_APP_PASSWORD
  SPARKLE_PRIVATE_KEY RELEASE_REPO_PAT
)

command -v gh >/dev/null || { echo "请先安装 gh CLI 并 gh auth login" >&2; exit 1; }

for name in "${required[@]}"; do
  value="${!name:-}"
  if [ -z "$value" ]; then
    echo "✗ 缺少环境变量: $name" >&2
    exit 1
  fi
  printf '%s' "$value" | gh secret set "$name" --repo "$PRIVATE_REPO"
  echo "✓ 已设置 $name"
done

echo
echo "完成。核对："
gh secret list --repo "$PRIVATE_REPO"
