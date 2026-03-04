# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

Clify 是一个 macOS 菜单栏应用，为 Claude Code CLI 添加声音提醒功能。应用使用 accessory 模式运行，不显示在 Dock 中。

## 构建与运行

```bash
# Xcode 打开项目
open Clify.xcodeproj

# Debug 构建
xcodebuild -project Clify.xcodeproj -scheme Clify -configuration Debug build

# Release 归档
xcodebuild -project Clify.xcodeproj -scheme Clify -configuration Release archive -archivePath build/Clify.xcarchive

# 打包 App
cd build/Clify.xcarchive/Products/Applications
zip -r ../../../Clify.zip Clify.app
```

## 核心架构

### 单文件架构

整个应用逻辑在 `Clify/AppDelegate.swift` 中：

```
Clify/
├── AppDelegate.swift              # 全部应用逻辑
├── Assets.xcassets                # 资源文件
└── Base.lproj/Main.storyboard     # 界面布局
```

### 功能模块

| 模块 | 方法 | 说明 |
|------|------|------|
| 状态栏管理 | `setupStatusBar`, `updateIcon` | 使用 SF Symbols 图标 (bell.badge/circle) |
| 菜单管理 | `updateMenu` | 构建菜单栏菜单 |
| Hook 检测 | `isClifyHookEnabled` | 检查配置文件是否已启用提醒 |
| Hook 启用 | `enableHook` | 写入 Notification 和 Stop hooks |
| Hook 禁用 | `disableHook` | 移除 Clify hooks |
| 配置读写 | `readConfig`, `writeConfig` | 操作 `~/.claude/settings.json` |

### 配置文件结构

Clify 修改 `~/.claude/settings.json`，添加以下 hooks：

```json
{
  "hooks": {
    "Notification": [
      { "matcher": "idle_prompt", "hooks": [{ "type": "command", "command": "afplay /System/Library/Sounds/Glass.aiff" }] },
      { "matcher": "permission_prompt", "hooks": [{ "type": "command", "command": "afplay /System/Library/Sounds/Funk.aiff" }] }
    ],
    "Stop": [
      { "hooks": [{ "type": "command", "command": "afplay /System/Library/Sounds/Glass.aiff" }] }
    ]
  }
}
```

## 测试清单

- [ ] 启动后菜单栏图标正常显示
- [ ] 启用提醒后图标变为铃铛
- [ ] 关闭提醒后图标变为圆圈
- [ ] 配置文件正确写入/读取
- [ ] 应用不在 Dock 显示

## 发布流程

```bash
# 1. 在 Xcode 中更新 Info.plist 版本号
# 2. 创建 Git 标签
git tag -a v0.1.2 -m "release: 版本说明"
git push origin v0.1.2

# 3. 构建并打包
xcodebuild -project Clify.xcodeproj -scheme Clify -configuration Release archive -archivePath build/Clify.xcarchive
cd build/Clify.xcarchive/Products/Applications && zip -r ../../../Clify.zip Clify.app
```

## 相关文档

- [PLAN.md](PLAN.md) - 项目计划与待办功能
- [README.md](README.md) - 用户使用说明
- [Claude Code Hooks 文档](https://docs.anthropic.com/claude-code/hooks)
