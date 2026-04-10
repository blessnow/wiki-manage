# Wiki Auto Process Skill

Claude Code 技能：自动将 `raw/` 目录中的文件处理为结构化 wiki 页面。

## 功能

- 自动检测 `raw/` 目录中的新文件
- 读取并理解文件内容
- 按 wiki 规范创建 source、entity、concept 页面
- 自动更新索引和日志
- 支持定时自动运行（CronCreate / 系统 crontab）

## 使用方式

### 方式一：Claude Code 会话内

在 Claude Code 中直接说：
```
处理所有新文件
```

或设置 CronCreate 每5分钟自动触发（session-only，7天过期）。

### 方式二：系统 crontab（持久化）

```bash
# 安装
bash setup.sh /path/to/your/wiki/root

# 或手动编辑 crontab
crontab -e
# 添加：
# */5 * * * * /path/to/scripts/cron_check.sh
```

## 文件结构

```
skills/wiki-auto-process/
├── SKILL.md                  ← 技能完整定义（处理流程+页面规范）
├── README.md                 ← 本文件
├── setup.sh                  ← 安装脚本
├── scripts/
│   └── cron_check.sh         ← 系统 crontab 入口（先检测再调用claude CLI）
└── references/
    ├── WIKI_SCHEMA.md        ← 完整 wiki 规范
    ├── CLAUDE_PROJECT.md     ← 项目级 CLAUDE.md（需复制到wiki根目录）
    └── templates/
        ├── source_template.md
        ├── entity_template.md
        └── concept_template.md
```

## 灵感来源

本项目的设计理念受到 Andrej Karpathy 的 **LLM Knowledge Base** 模式启发：

- 数据摄入：原始文档放入 `raw/` → LLM 增量"编译"为结构化 wiki
- 前端展示：使用 Obsidian 浏览和检索
- 问答交互：LLM agent 基于编译后的 wiki 回答问题
- 核心理念：*"You rarely ever write or edit the wiki manually, it's the domain of the LLM"*

参考链接：
- Karpathy 推文：https://x.com/karpathy/status/2039805659525644595
- Karpathy Gist：https://gist.github.com/karpathy/442a6

## 依赖

- Claude Code CLI (`claude`) 已安装并登录
- 目标 wiki 项目根目录有 `CLAUDE.md`（从 `references/CLAUDE_PROJECT.md` 复制）

## Wiki 目录结构

目标项目应具有以下结构：

```
wiki-project/
├── CLAUDE.md              ← 从 references/CLAUDE_PROJECT.md 复制
├── raw/                   ← 你放原始资料的地方
├── wiki/
│   ├── sources/           ← 自动生成的资料摘要
│   ├── entities/          ← 自动生成的实体页面
│   ├── concepts/          ← 自动生成的概念页面
│   └── index.md           ← 总目录索引
├── .processed_files       ← 已处理文件列表（自动维护）
└── templates/             ← 页面模板
```
