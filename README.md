# continuous-claude-deepseek

> [continuous-claude](https://github.com/AnandChowdhary/continuous-claude) 的 DeepSeek 兼容版本。

## 这是什么

[continuous-claude](https://github.com/AnandChowdhary/continuous-claude) 是一个自动化开发工具：它读取任务描述，循环调用 Claude Code CLI 执行代码修改，每轮自动创建分支 → commit → PR，实现 **GitHub PR 永动机**。

**问题**：当 `claude` 命令通过 Router 代理到 DeepSeek 模型时，`-p`（`--print`）模式下 DeepSeek **不执行工具调用**。它只返回文本分析，不会用 Edit/Write 修改文件。导致 continuous-claude 空转，每轮都报 `invalid_json`。

**解决**：这个版本只改了一处——把 `claude -p "任务描述"` 改为 `echo "任务描述" | claude`（stdin pipe）。DeepSeek 在 stdin 模式下能正常调用所有工具。

## 与原始版本的区别

| 项目 | 原始 continuous-claude | continuous-claude-deepseek |
|------|----------------------|---------------------------|
| Claude 调用方式 | `claude -p "prompt" --输出-format json` | `echo "prompt" \| claude --输出-format json` |
| Anthropic Claude（直连） | ✅ | ✅ |
| DeepSeek（Router 代理） | ❌ 不调 Edit/Write | ✅ 正常 |
| 分支/PR/commit 逻辑 | 不变 | 不变 |
| 命令行参数 | 不变 | 不变 |

## 安装

```powershell
irm https://raw.githubusercontent.com/jacobhodges934-boop/continuous-claude-deepseek/main/install.ps1 | iex
```

## 用法

与 [continuous-claude](https://github.com/AnandChowdhary/continuous-claude) 完全相同：

```powershell
# 1 轮 dry-run
continuous-claude-deepseek.ps1 --prompt "追加一行到 docs/NOTES.md" --max-runs 1

# 3 轮 safe mode
continuous-claude-deepseek.ps1 --prompt "你的任务描述" --max-runs 3

# 在项目目录下运行，自动创建 GitHub PR
```

## 前置条件

- PowerShell 7（`pwsh`）
- Claude Code CLI（`claude`，可走 Router）
- GitHub CLI（`gh`，已登录）
- Git

## 技术细节

唯一改动在 `Invoke-ExternalCommand` 函数：

```powershell
# 原始版本
$arguments = @("-p", $PromptText, "--output-format=json", "--dangerously-skip-permissions")
& claude @arguments

# DeepSeek 版本：剥离 -p，用 stdin 传 prompt
# -p 在 DeepSeek 下阻止工具调用（Edit/Write/Bash），stdin pipe 不会
$PromptText | & claude --output-format=json --dangerously-skip-permissions
```

## 许可证

MIT（继承自 [continuous-claude](https://github.com/AnandChowdhary/continuous-claude)）
