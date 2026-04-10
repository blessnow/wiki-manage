# LLM Wiki 项目指南

## 项目概述
个人知识库系统。文件放入 `raw/`，自动处理为结构化 wiki 页面。

## 三层架构
- **Raw层**: `raw/` 目录，原始资料，永不修改
- **Wiki层**: `wiki/` 目录，AI 维护的结构化知识库
- **Schema层**: `WIKI_SCHEMA.md` 等配置文件

## 自动化处理流程

### 触发方式
- CronCreate（会话内，每5分钟）
- 系统 crontab（`scripts/cron_check.sh`，每5分钟，先检测新文件再调用 claude CLI）

### 处理步骤
1. 用 `comm -23` 对比 `raw/` 所有文件 vs `.processed_files` 已处理列表
2. 排除 `.git/` 目录和 `.swp` 临时文件
3. 如果没有新文件 → 回复"无新文件"
4. 如果有新文件 → 读取内容 → 生成 wiki 页面 → 更新索引

### 文件分组策略
多个相关的 raw 文件可以合并为一个 wiki source 页面（如6个淘股吧帖子 → 1个 wiki 页面）。
判断依据：主题相同、来源相同、内容互补。

## 页面格式规范

### Frontmatter（必需）
```yaml
---
type: source|entity|concept
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: [tag1, tag2]
original_path: raw/path/to/file   # source类型专用
sources: [source1, source2]         # entity/concept类型专用
---
```

### 内部链接
使用 Obsidian 兼容的 `[[wiki-links]]` 格式，如 `[[陈小群]]`、`[[龙头战法]]`。

### 页面类型

**source** (`wiki/sources/`) — 原始资料的摘要和分析
- 含元信息、核心观点、详细摘要、重要引用
- 提取的实体和概念用 `[[]]` 链接
- 与其他资料的关系（支持/矛盾/补充）

**entity** (`wiki/entities/`) — 人物、组织等实体
- 基本信息、关键事实、重要事件时间线
- 相关实体和概念的双向链接

**concept** (`wiki/concepts/`) — 核心概念
- 定义、核心特征、不同观点
- 实际案例、应用场景、局限性

## 处理后必须更新
1. `.processed_files` — 追加已处理文件路径
2. `wiki/index.md` — 更新页面列表和统计数字
3. `wiki/log.md` — 追加 Batch 日志（格式：`## YYYY-MM-DD — Batch N: 标题`）

## 维护规则
- 统一术语：同一概念使用相同名称
- 双向链接：A引用B时，B也应有到A的链接
- 不修改 `raw/` 中的任何文件
- 不创建空洞页面（每个页面都要有实质内容）
- 过度分类：保持简单扁平的结构

## 模板参考
- `templates/source_template.md`
- `templates/entity_template.md`
- `templates/concept_template.md`

## 完整规范
详见 `WIKI_SCHEMA.md`
