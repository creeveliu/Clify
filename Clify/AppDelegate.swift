//
//  AppDelegate.swift
//  Clify
//
//  Created by cl on 2026/3/4.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    /// 状态栏项
    private var statusItem: NSStatusItem?

    /// 配置文件路径
    private let settingsPath: String = FileManager.default.homeDirectoryForCurrentUser.path + "/.claude/settings.json"

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // 隐藏主窗口
        if let window = NSApp.windows.first {
            window.isReleasedWhenClosed = true
            window.close()
        }

        setupStatusBar()
        updateMenu()
        print("[AppDelegate] Clify 启动完成")
    }

    // MARK: - 状态栏设置

    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.action = #selector(statusBarButtonClicked)
        statusItem?.button?.target = self
        updateIcon()
    }

    private func updateIcon() {
        let isEnabled = isClifyHookEnabled()
        let imageName = isEnabled ? "bell.badge" : "circle"
        let image = NSImage(systemSymbolName: imageName, accessibilityDescription: nil)!
        image.isTemplate = true
        statusItem?.button?.image = image
    }

    private func updateMenu() {
        let menu = NSMenu()

        // 标题
        let titleItem = NSMenuItem(title: "Clify - Claude 提醒助手", action: nil, keyEquivalent: "")
        titleItem.isEnabled = false
        menu.addItem(titleItem)

        menu.addItem(NSMenuItem.separator())

        // 启用/禁用
        let isEnabled = isClifyHookEnabled()
        let toggleTitle = isEnabled ? "关闭提醒" : "启用提醒"
        let toggleItem = NSMenuItem(title: toggleTitle, action: #selector(toggleHook), keyEquivalent: "")
        toggleItem.target = self
        menu.addItem(toggleItem)

        menu.addItem(NSMenuItem.separator())

        // 打开配置目录
        let openConfigItem = NSMenuItem(title: "打开配置目录", action: #selector(openConfigDirectory), keyEquivalent: "")
        openConfigItem.target = self
        menu.addItem(openConfigItem)

        menu.addItem(NSMenuItem.separator())

        // 退出
        let quitItem = NSMenuItem(title: "退出 Clify", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
    }

    // MARK: - Actions

    @objc private func statusBarButtonClicked() {
        statusItem?.button?.performClick(nil)
    }

    @objc private func toggleHook() {
        if isClifyHookEnabled() {
            disableHook()
        } else {
            enableHook()
        }
        updateIcon()
        updateMenu()
    }

    @objc private func openConfigDirectory() {
        let configPath = FileManager.default.homeDirectoryForCurrentUser.path + "/.claude"
        let configURL = URL(fileURLWithPath: configPath, isDirectory: true)
        NSWorkspace.shared.open(configURL)
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }

    // MARK: - Hook 操作

    private func isClifyHookEnabled() -> Bool {
        guard let config = readConfig(),
              let hooks = config["hooks"] as? [String: Any],
              let notifications = hooks["Notification"] as? [[String: Any]] else {
            return false
        }

        // 检查是否有 Glass.aiff hook（我们的提醒 hook）
        for notification in notifications {
            guard let hooksArray = notification["hooks"] as? [[String: Any]] else {
                continue
            }

            for hook in hooksArray {
                if let command = hook["command"] as? String,
                   command.contains("Glass.aiff") {
                    return true
                }
            }
        }
        return false
    }

    private func isClifyHook(command: String) -> Bool {
        return command.contains("Glass.aiff") ||
               command.contains("Funk.aiff")
    }

    private func enableHook() {
        guard var config = readConfig() else {
            showAlert("启用失败", "无法读取配置文件")
            return
        }

        if var hooks = config["hooks"] as? [String: Any] {
            var notifications = hooks["Notification"] as? [[String: Any]] ?? []

            // 移除已有的 Clify hooks
            notifications = notifications.filter { notification in
                guard let hooksArray = notification["hooks"] as? [[String: Any]] else { return true }
                for hook in hooksArray {
                    if let command = hook["command"] as? String, isClifyHook(command: command) {
                        return false
                    }
                }
                return true
            }

            // 添加 Clify hooks - idle_prompt: Glass.aiff
            notifications.append([
                "matcher": "idle_prompt",
                "hooks": [
                    ["type": "command", "command": "afplay /System/Library/Sounds/Glass.aiff"]
                ]
            ])
            // permission_prompt: Funk.aiff
            notifications.append([
                "matcher": "permission_prompt",
                "hooks": [
                    ["type": "command", "command": "afplay /System/Library/Sounds/Funk.aiff"]
                ]
            ])

            hooks["Notification"] = notifications

            // 添加 Stop hook - 命令完成提示
            hooks["Stop"] = [
                [
                    "hooks": [
                        ["type": "command", "command": "afplay /System/Library/Sounds/Glass.aiff"]
                    ]
                ]
            ]

            config["hooks"] = hooks

            if writeConfig(config) {
                showAlert("提醒已启用", "Claude Code 提醒功能已开启\n菜单栏图标将显示为 🔔")
            } else {
                showAlert("启用失败", "无法写入配置文件")
            }
        }
    }

    private func disableHook() {
        guard var config = readConfig() else {
            showAlert("禁用失败", "无法读取配置文件")
            return
        }

        if var hooks = config["hooks"] as? [String: Any] {
            var notifications = hooks["Notification"] as? [[String: Any]] ?? []

            // 移除 Clify hooks
            notifications = notifications.filter { notification in
                guard let hooksArray = notification["hooks"] as? [[String: Any]] else { return true }
                for hook in hooksArray {
                    if let command = hook["command"] as? String, isClifyHook(command: command) {
                        return false
                    }
                }
                return true
            }

            if notifications.isEmpty {
                hooks.removeValue(forKey: "Notification")
            } else {
                hooks["Notification"] = notifications
            }
            config["hooks"] = hooks

            if writeConfig(config) {
                showAlert("提醒已关闭", "Claude Code 提醒功能已关闭\n菜单栏图标将显示为 ⚪")
            } else {
                showAlert("禁用失败", "无法写入配置文件")
            }
        }
    }

    // MARK: - 辅助方法

    private func readConfig() -> [String: Any]? {
        guard FileManager.default.fileExists(atPath: settingsPath) else {
            return nil
        }
        let data = try! Data(contentsOf: URL(fileURLWithPath: settingsPath))
        return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
    }

    private func writeConfig(_ config: [String: Any]) -> Bool {
        do {
            let data = try JSONSerialization.data(withJSONObject: config, options: .prettyPrinted)
            try data.write(to: URL(fileURLWithPath: settingsPath))
            return true
        } catch {
            return false
        }
    }

    private func showAlert(_ title: String, _ message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .informational
        alert.addButton(withTitle: "确定")
        alert.runModal()
    }
}
