#!/bin/bash
# Wiki Auto Process Skill - 安装脚本
# 将 skill 配置到目标 wiki 项目
#
# 用法: bash setup.sh /path/to/your/wiki/root
#
# 如果不传参数，默认安装到当前 wiki 项目

set -e

# 确定路径
SKILL_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ -n "$1" ]; then
  WIKI_ROOT="$1"
else
  WIKI_ROOT="$(cd "$SKILL_DIR/../.." && pwd)"
fi

echo "=== Wiki Auto Process Skill 安装 ==="
echo "Skill 目录: $SKILL_DIR"
echo "目标 Wiki:  $WIKI_ROOT"
echo ""

# 1. 复制 CLAUDE.md 到项目根目录
if [ ! -f "$WIKI_ROOT/CLAUDE.md" ]; then
  cp "$SKILL_DIR/references/CLAUDE_PROJECT.md" "$WIKI_ROOT/CLAUDE.md"
  echo "[OK] 已创建 $WIKI_ROOT/CLAUDE.md"
else
  echo "[跳过] $WIKI_ROOT/CLAUDE.md 已存在"
fi

# 2. 复制模板（如果目标没有）
if [ ! -d "$WIKI_ROOT/templates" ]; then
  cp -r "$SKILL_DIR/references/templates" "$WIKI_ROOT/templates"
  echo "[OK] 已复制 templates/"
else
  echo "[跳过] templates/ 已存在"
fi

# 3. 复制 cron 脚本
if [ ! -d "$WIKI_ROOT/scripts" ]; then
  mkdir -p "$WIKI_ROOT/scripts"
fi

# 更新 cron_check.sh 中的 WIKI_ROOT 路径
sed "s|WIKI_ROOT=.*|WIKI_ROOT=\"$WIKI_ROOT\"|" \
  "$SKILL_DIR/scripts/cron_check.sh" > "$WIKI_ROOT/scripts/cron_check.sh"
chmod +x "$WIKI_ROOT/scripts/cron_check.sh"
echo "[OK] 已安装 scripts/cron_check.sh（WIKI_ROOT=$WIKI_ROOT）"

# 4. 初始化必要文件
touch "$WIKI_ROOT/.processed_files"
echo "[OK] 确保 .processed_files 存在"

# 5. 提示添加 crontab
echo ""
echo "=== 下一步 ==="
echo "添加系统 crontab 实现持久化定时处理："
echo ""
echo "  crontab -e"
echo "  # 添加以下行："
echo "  */5 * * * * $WIKI_ROOT/scripts/cron_check.sh"
echo ""
echo "或运行以下命令自动添加："
echo "  (echo '*/5 * * * * $WIKI_ROOT/scripts/cron_check.sh' | crontab -)"
echo ""
echo "安装完成！"
