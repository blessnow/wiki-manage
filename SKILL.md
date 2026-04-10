# Wiki Auto Process Skill

自动扫描 `raw/` 目录，将新文件处理为结构化 wiki 页面。

## 快速开始

```bash
# 1. 复制项目级配置到你的 wiki 根目录
cp references/CLAUDE_PROJECT.md /your/wiki/root/CLAUDE.md

# 2. 复制模板（如果目标项目没有）
cp -r references/templates/ /your/wiki/root/templates/

# 3. 安装系统 crontab（持久化定时任务）
bash scripts/cron_check.sh  # 先手动测试
# 编辑 crontab：
# */5 * * * * /path/to/skills/wiki-auto-process/scripts/cron_check.sh
```

## 文件清单

```
skills/wiki-auto-process/
├── SKILL.md                              ← 本文件（技能定义）
├── README.md                             ← 使用说明
├── setup.sh                              ← 安装脚本
├── scripts/
│   └── cron_check.sh                     ← 系统 crontab 入口脚本
└── references/
    ├── WIKI_SCHEMA.md                    ← 完整 wiki 规范（目录结构、页面格式、维护规则）
    ├── CLAUDE_PROJECT.md                 ← 项目级 CLAUDE.md（复制到 wiki 根目录）
    └── templates/
        ├── source_template.md            ← source 页面模板
        ├── entity_template.md            ← entity 页面模板
        └── concept_template.md           ← concept 页面模板
```

## 触发方式

1. **CronCreate**（Claude Code 会话内，每5分钟，session-only）
2. **系统 crontab**（`scripts/cron_check.sh`，每5分钟，持久化）
3. **手动**：在 Claude Code 中说 "处理所有新文件"

## 执行流程

### 1. 检测新文件

```bash
comm -23 <(find raw/ -type f | grep -v '\.git/' | sort) <(sort .processed_files)
```

- 排除 `.git/` 目录、`.swp` 临时文件
- 如果无新文件 → 回复"无新文件"，结束

### 2. 读取新文件

逐个读取新文件内容，理解其主题和结构。

### 3. 分组策略

多个相关 raw 文件可合并为一个 wiki source 页面。判断依据：
- 主题相同（如同一人物的多个论坛帖子）
- 来源相同（如同一视频的多个片段）
- 内容互补（如AI摘要+完整转录）

### 4. 创建 Wiki 页面

按类型创建到对应目录：

#### source 页面 (`wiki/sources/`)
```yaml
---
type: source
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: [tag1, tag2]
original_path: raw/path/to/file
---
```
内容：元信息、核心观点、详细摘要、重要引用、提取的实体和概念（用 `[[]]` 链接）、与其他资料的关系。

参考完整模板：`references/templates/source_template.md`

#### entity 页面 (`wiki/entities/`)
```yaml
---
type: entity
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: [person|organization, ...]
sources: [source1, source2]
---
```
内容：基本信息、关键事实、重要事件时间线、相关实体和概念的双向链接。

参考完整模板：`references/templates/entity_template.md`

#### concept 页面 (`wiki/concepts/`)
```yaml
---
type: concept
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: [concept, domain]
sources: [source1, source2]
---
```
内容：定义、核心特征、不同观点、实际案例、相关概念。

参考完整模板：`references/templates/concept_template.md`

### 5. 链接规范

- 使用 Obsidian 兼容的 `[[wiki-links]]` 格式
- 双向链接：A 引用 B 时，B 页面也应有到 A 的链接

### 6. 更新索引（每次处理后必需）

1. **`.processed_files`** — 追加所有已处理的 raw 文件路径
2. **`wiki/index.md`** — 更新页面列表和统计数字（Sources/Entities/Concepts 计数）
3. **`wiki/log.md`** — 追加 Batch 日志，格式：

```markdown
## YYYY-MM-DD — Batch N: 标题 (X files)

**Ingested**: X source files
- `path/to/file1`（简要说明）
- `path/to/file2`（简要说明）

**Created/Updated**: Y pages
- page_name — 简要说明

**Notes**: 本次处理的亮点和注意事项。
```

## 维护规则

- 统一术语：同一概念使用相同名称
- 双向链接：A引用B时，B也应有到A的链接
- 不修改 `raw/` 中的任何文件
- 不创建空洞页面（每个页面都要有实质内容）
- 保持简单扁平的结构

## 完整规范

详见 `references/WIKI_SCHEMA.md`
