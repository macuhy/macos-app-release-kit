#!/usr/bin/env bash
# 把 Developer ID .p12 证书转为 base64（用于 BUILD_CERTIFICATE_BASE64 secret）。
# 用法: bash scripts/export-cert.sh /path/to/DeveloperID.p12
set -euo pipefail

P12="${1:?用法: export-cert.sh <path-to.p12>}"
[ -f "$P12" ] || { echo "找不到文件: $P12" >&2; exit 1; }

# macOS base64 默认不换行；-i 指定输入文件
base64 -i "$P12"
