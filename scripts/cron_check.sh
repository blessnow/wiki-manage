#!/bin/bash
# Wiki自动处理 - 系统crontab入口
# 先检测新文件，有则调用claude CLI处理，无则跳过
#
# 安装：将此脚本加入系统 crontab
#   */5 * * * * /path/to/skills/wiki-auto-process/scripts/cron_check.sh
#
# 前置条件：
#   - claude CLI 已安装并登录
#   - WIKI_ROOT 目录下有 CLAUDE.md（项目级指南）

# ===== 配置区（根据你的环境修改） =====
WIKI_ROOT="/Users/yanghaijuan/Documents/projects/wiki"
CLAUDE_BIN="$HOME/.nvm/versions/node/v22.22.0/bin/claude"
# =========================================

PROCESSED_LOG="$WIKI_ROOT/.processed_files"
LOG_FILE="$WIKI_ROOT/scripts/cron_check.log"

# 确保文件存在
touch "$PROCESSED_LOG" "$LOG_FILE"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# 检测新文件
new_files=$(comm -23 \
  <(find "$WIKI_ROOT/raw" -type f | grep -v '\.git/' | sort) \
  <(sort "$PROCESSED_LOG"))

if [ -z "$new_files" ]; then
  log "无新文件，跳过"
  exit 0
fi

new_count=$(echo "$new_files" | wc -l | tr -d ' ')
log "发现 $new_count 个新文件，启动处理..."

# 调用claude CLI处理（在WIKI_ROOT下运行以加载CLAUDE.md）
cd "$WIKI_ROOT"
"$CLAUDE_BIN" \
  --prompt "按照 CLAUDE.md 中的规范处理新文件。检查 .processed_files 中已处理的文件列表，然后扫描 raw/ 目录下所有文件。找出不在已处理列表中的新文件。如果有新文件，读取每个新文件的内容，然后按照 wiki 规范（YAML frontmatter + wiki-links）在 wiki/ 目录下创建对应的 source、entity、concept 页面，最后更新 .processed_files、wiki/index.md 和 wiki/log.md。如果没有新文件，直接回复'无新文件'即可。" \
  --allowedTools "Read,Write,Edit,Bash,Glob,Grep" \
  >> "$LOG_FILE" 2>&1

log "处理完成"
