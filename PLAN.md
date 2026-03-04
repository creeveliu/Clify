# Clify 项目计划

## 项目概述

**Clify** 是一个 macOS 菜单栏应用，为 Claude Code CLI 添加声音提醒功能。

## 当前版本

- **最新版本**: v0.1.1
- **发布日期**: 2026-03-04

---

## 已完成功能

### v0.1.1 (当前版本)

| 功能 | 状态 | 说明 |
|------|------|------|
| 菜单栏状态栏图标 | ✅ | 使用 SF Symbols 图标，支持状态切换 |
| 空闲提醒 | ✅ | Claude 空闲等待输入时播放 Glass 音效 |
| 权限请求提醒 | ✅ | Claude 请求执行命令权限时播放 Funk 音效 |
| 命令完成提醒 | ✅ | 命令执行完成时播放 Glass 音效 |
| 启用/禁用切换 | ✅ | 通过菜单栏菜单切换提醒状态 |
| 配置文件管理 | ✅ | 自动读写 `~/.claude/settings.json` |
| Accessory 模式 | ✅ | 应用不显示在 Dock，纯菜单栏运行 |

### 技术实现

```swift
// 核心功能模块
- AppDelegate.swift
  ├── applicationDidFinishLaunching - 应用启动，设置 accessory 模式
  ├── setupStatusBar - 设置菜单栏图标
  ├── updateMenu - 更新菜单内容
  ├── isClifyHookEnabled - 检查是否已启用
  ├── enableHook - 写入 hooks 配置
  └── disableHook - 移除 hooks 配置
```

---

## 待办功能 (Backlog)

### 优先级 P0 - 核心功能完善

| ID | 功能 | 描述 | 状态 |
|----|------|------|------|
| P0-1 | 自定义音效 | 允许用户选择不同的提示音 | 📋 |
| P0-2 | 音量调节 | 独立控制提醒音量 | 📋 |
| P0-3 | 静默时段 | 设置免打扰时间段 | 📋 |

### 优先级 P1 - 用户体验

| ID | 功能 | 描述 | 状态 |
|----|------|------|------|
| P1-1 | 偏好设置窗口 | 图形化配置界面 | 📋 |
| P1-2 | 测试音效 | 在设置中测试当前音效 | 📋 |
| P1-3 | 开机自启 | 登录后自动启动 | 📋 |
| P1-4 | 通知中心提醒 | 配合声音发送系统通知 | 📋 |

### 优先级 P2 - 高级功能

| ID | 功能 | 描述 | 状态 |
|----|------|------|------|
| P2-1 | 多配置支持 | 支持多个 Claude 配置场景 | 📋 |
| P2-2 | 自定义 Hook 事件 | 支持更多 Claude hook 类型 | 📋 |
| P2-3 | 状态历史记录 | 记录提醒触发历史 | 📋 |
| P2-4 | 快捷键支持 | 全局快捷键快速开关提醒 | 📋 |

---

## 技术债务

| 问题 | 影响 | 建议方案 |
|------|------|----------|
| 无 | 当前代码结构清晰 | 保持代码审查 |

---

## 发布流程

### 发布新版本

```bash
# 1. 确认代码已提交
git status

# 2. 更新版本号 (根据需要更新 major.minor.patch)
# 在 Xcode 中修改 Info.plist 中的版本号

# 3. 创建 Git 标签
git tag -a v0.1.2 -m "release: 版本说明"

# 4. 推送标签
git push origin v0.1.2

# 5. 构建 Release
xcodebuild -project Clify.xcodeproj -scheme Clify -configuration Release archive -archivePath build/Clify.xcarchive

# 6. 打包
cd build/Clify.xcarchive/Products/Applications
zip -r ../../../Clify.zip Clify.app

# 7. 在 GitHub 创建 Release 并上传 Clify.zip
```

---

## 开发规范

### 代码风格
- Swift 5.9+
- 使用 `private` 明确访问控制
- 函数按功能模块分组，使用 `// MARK:` 注释

### 提交规范
```
feat: 新功能
fix: 修复 bug
docs: 文档更新
chore: 构建/配置变更
refactor: 代码重构
```

### 测试清单
- [ ] 启动后菜单栏图标正常显示
- [ ] 启用提醒后图标变为铃铛
- [ ] 关闭提醒后图标变为圆圈
- [ ] 配置文件正确写入/读取
- [ ] 应用不在 Dock 显示

---

## 参考资料

- [Claude Code Hooks 文档](https://docs.anthropic.com/claude-code/hooks)
- [macOS Menu Bar Apps](https://developer.apple.com/documentation/appkit/nsstatusitem)
- [System Sounds](https://gist.github.com/nikhilsh/2356486)
