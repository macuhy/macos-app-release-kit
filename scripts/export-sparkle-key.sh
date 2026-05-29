#!/usr/bin/env bash
# 生成 / 导出 Sparkle EdDSA 密钥。
# 用法: bash scripts/export-sparkle-key.sh /path/to/Sparkle/bin
#   - 首次运行 generate_keys 会创建密钥并把私钥存入登录钥匙串，打印公钥。
#   - 再以 -x 导出私钥到文件，内容用于 SPARKLE_PRIVATE_KEY secret。
set -euo pipefail

BIN="${1:?用法: export-sparkle-key.sh <Sparkle/bin 目录>}"
GEN="$BIN/generate_keys"
[ -x "$GEN" ] || { echo "找不到 generate_keys: $GEN" >&2; exit 1; }

echo "== 公钥 (填进 Info.plist 的 SUPublicEDKey / CONFIG.md) =="
"$GEN" -p     # 仅打印公钥（若尚未生成会先生成）

OUT="sparkle_private_key.txt"
"$GEN" -x "$OUT"
echo
echo "== 私钥已导出到 $OUT (填进 SPARKLE_PRIVATE_KEY secret) =="
echo "!! 写入 secret 后请删除: rm $OUT"
