# continuous-claude-deepseek

> continuous-claude 的 DeepSeek 兼容版本。通过 Claude Code Router 使用 DeepSeek 模型时，`-p` 标志会阻止工具调用（Edit/Write）。本版本用 stdin-pipe 替代 `-p`，恢复工具调用能力。

## 与原始 continuous-claude 的区别

| 项目 | 原始 | continuous-claude-deepseek |
|------|------|---------------------------|
| 调用方式 | `claude -p "prompt" ...` | `echo "prompt" \| claude ...` |
| Anthropic Claude | ✅ | ✅ |
| DeepSeek (via Router) | ❌ 不执行工具调用 | ✅ 正常 |
| 其他功能 | 完全一致 | 完全一致 |

## 安装

```powershell
irm https://raw.githubusercontent.com/jacobhodges934-boop/continuous-claude-deepseek/main/install.ps1 | iex
```

## 用法

与 [continuous-claude](https://github.com/AnandChowdhary/continuous-claude) 完全相同，只是脚本名不同。

## 技术细节

核心改动：`Invoke-ExternalCommand` 剥离 `-p` 标志，通过 stdin pipe 传入 prompt，使 DeepSeek 能正常调用 Edit/Write 等工具。

## 许可证

MIT（继承自 [continuous-claude](https://github.com/AnandChowdhary/continuous-claude)）
