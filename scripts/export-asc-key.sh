#!/usr/bin/env bash
# 把 App Store Connect API Key（AuthKey_XXXXXX.p8）转为 base64（用于 ASC_API_KEY_P8 secret）。
# .p8 在 App Store Connect → Users and Access → Integrations → Keys 下载，只能下一次。
# 用法: bash scripts/export-asc-key.sh /path/to/AuthKey_ABCDE12345.p8
set -euo pipefail

P8="${1:?用法: export-asc-key.sh <path-to-AuthKey_xxx.p8>}"
[ -f "$P8" ] || { echo "找不到文件: $P8" >&2; exit 1; }

# macOS base64 默认不换行；-i 指定输入文件
base64 -i "$P8"
