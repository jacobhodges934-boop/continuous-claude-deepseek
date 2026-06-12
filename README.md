# continuous-claude-deepseek

> [continuous-claude](https://github.com/AnandChowdhary/continuous-claude) 的 DeepSeek 兼容版本。

## 这是什么

[continuous-claude](https://github.com/AnandChowdhary/continuous-claude) 是一个自动化开发工具：读取任务描述，循环调用 Claude Code CLI 执行代码修改，每轮自动创建分支 → commit → PR → 等 CI → 合并，实现 **GitHub PR 永动机**。

**问题**：当 `claude` 通过 Router 走 DeepSeek 模型时，`-p` 模式下 DeepSeek 不执行工具调用。它只返回文本分析，不会用 Edit/Write 修改文件。

**解决**：`claude -p` → stdin pipe。DeepSeek 在 stdin 模式下能正常调用所有工具。

## 与原始 continuous-claude 的区别

| 特性 | 原始 | continuous-claude-deepseek |
|------|------|---------------------------|
| Claude 调用方式 | `claude -p "prompt"` | stdin pipe |
| DeepSeek 兼容 | ❌ | ✅ |
| 中文 PR 标题 | ❌ 乱码 | ✅ `gh api` UTF-8 安全 |
| DeepSeek CNY 花费 | ❌ | ✅ 官方 token 计价 |
| `invalid_json` 容错 | ❌ 直接失败 | ✅ 检测文件变更兜底 |
| stdout/stderr | 混合写入 | ✅ 分离日志 |
| PR 合并冲突 | 卡住 | ✅ `--admin` 强制 squash |
| cost-tracking.jsonl | ❌ | ✅ 每轮 + 汇总 |

## 安装

```powershell
irm https://raw.githubusercontent.com/jacobhodges934-boop/continuous-claude-deepseek/main/install.ps1 | iex
```

## 用法

```powershell
# 基本用法
continuous-claude-deepseek.ps1 --prompt "你的任务" --max-runs 5 --merge-strategy squash

# 不限轮数（直到 3 次连续错误退出）
continuous-claude-deepseek.ps1 --prompt "你的任务" --max-runs 0

# Dry-run（模拟，不实际提交）
continuous-claude-deepseek.ps1 --prompt "测试" --max-runs 1 --dry-run
```

### 模型选择

通过 `CLAUDE_CODE_MODEL` 环境变量控制：

```powershell
$env:CLAUDE_CODE_MODEL = "deepseek-v4-flash"  # 便宜（¥0.02-2/百万token）
$env:CLAUDE_CODE_MODEL = "deepseek-v4-pro"    # 强力（¥0.025-6/百万token）
# 不设 = 自动选择
```

## 前置条件

- **PowerShell 7** (`pwsh`): `winget install Microsoft.PowerShell`
- **Claude Code CLI** (`claude`)，可走 Router 到 DeepSeek
- **GitHub CLI** (`gh`)，已登录: `gh auth login`
- Git

## DeepSeek 花费追踪

每轮自动计算并输出 CNY 花费（基于 DeepSeek 官方 token 定价）：

| 模型 | 缓存命中输入 | 缓存未命中输入 | 输出 |
|------|------------|-------------|------|
| deepseek-v4-flash | ¥0.02/M | ¥1/M | ¥2/M |
| deepseek-v4-pro | ¥0.025/M | ¥3/M | ¥6/M |

花费记录写入 `logs/cost-tracking.jsonl`，最终汇总显示 CNY 总额。

## 许可证

MIT（继承自 [continuous-claude](https://github.com/AnandChowdhary/continuous-claude)）
