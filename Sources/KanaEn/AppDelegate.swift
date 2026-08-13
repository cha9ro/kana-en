import AppKit
import ApplicationServices
import CoreGraphics
import ServiceManagement

final class AppDelegate: NSObject, NSApplicationDelegate {
    private static let showsStatusItemKey = "showsStatusItem"

    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let inputSourceController = InputSourceController()
    private var eventMonitor: CommandEventMonitor?
    private var settingsWindowController: SettingsWindowController?
    private var monitoringStatus: MonitoringStatus = .starting

    func applicationDidFinishLaunching(_ notification: Notification) {
        UserDefaults.standard.register(defaults: [Self.showsStatusItemKey: true])
        configureStatusItem()
        statusItem.isVisible = UserDefaults.standard.bool(forKey: Self.showsStatusItemKey)
        startMonitoring()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        retryMonitoring(requestPermission: false)
        showSettingsWindow()
        return false
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        retryMonitoring(requestPermission: false)
    }

    func applicationWillTerminate(_ notification: Notification) {
        eventMonitor?.stop()
    }

    private func configureStatusItem() {
        if let button = statusItem.button {
            button.image = NSImage(
                systemSymbolName: "character.cursor.ibeam",
                accessibilityDescription: "KanaEn"
            )
        }

        rebuildMenu()
    }

    private func rebuildMenu() {
        let menu = NSMenu()

        if eventMonitor != nil {
            let stateItem = NSMenuItem(
                title: "左右 Command の単押しを監視中",
                action: nil,
                keyEquivalent: ""
            )
            stateItem.isEnabled = false
            menu.addItem(stateItem)
            menu.addItem(.separator())
        }
        menu.addItem(withTitle: "左 Command → 英語", action: nil, keyEquivalent: "")
        menu.addItem(withTitle: "右 Command → 日本語", action: nil, keyEquivalent: "")

        menu.addItem(.separator())
        let settingsItem = NSMenuItem(
            title: "設定…",
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        settingsItem.target = self
        menu.addItem(settingsItem)

        let visibilityItem = NSMenuItem(
            title: "メニューバーに表示",
            action: #selector(toggleStatusItemVisibility(_:)),
            keyEquivalent: ""
        )
        visibilityItem.target = self
        visibilityItem.state = statusItem.isVisible ? .on : .off
        menu.addItem(visibilityItem)

        let loginItem = NSMenuItem(
            title: "ログイン時に起動",
            action: #selector(toggleLaunchAtLogin(_:)),
            keyEquivalent: ""
        )
        loginItem.target = self
        loginItem.state = SMAppService.mainApp.status == .enabled ? .on : .off
        menu.addItem(loginItem)

        let permissionItem = NSMenuItem(
            title: "入力監視設定を開く",
            action: #selector(openInputMonitoringSettings),
            keyEquivalent: ""
        )
        permissionItem.target = self
        menu.addItem(permissionItem)

        menu.addItem(.separator())
        let quitItem = NSMenuItem(title: "KanaEn を終了", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    private func startMonitoring() {
        guard CGPreflightListenEventAccess() || CGRequestListenEventAccess() else {
            monitoringStatus = .inputMonitoringRequired
            updateSettingsWindow()
            showInputMonitoringPermissionAlert()
            return
        }

        let monitor = CommandEventMonitor { [weak self] command in
            DispatchQueue.main.async {
                switch command {
                case .left:
                    self?.inputSourceController.selectEnglish()
                case .right:
                    self?.inputSourceController.selectJapanese()
                }
            }
        }

        guard monitor.start() else {
            monitoringStatus = .failed
            updateSettingsWindow()
            showEventTapError()
            return
        }

        eventMonitor = monitor
        monitoringStatus = .active
        rebuildMenu()
        updateSettingsWindow()
    }

    private func retryMonitoring(requestPermission: Bool) {
        if let eventMonitor {
            eventMonitor.ensureEnabled()
            monitoringStatus = .active
            updateSettingsWindow()
            return
        }

        let canListen = requestPermission
            ? CGRequestListenEventAccess()
            : CGPreflightListenEventAccess()

        guard canListen else {
            monitoringStatus = .inputMonitoringRequired
            updateSettingsWindow()
            return
        }

        let monitor = CommandEventMonitor { [weak self] command in
            DispatchQueue.main.async {
                switch command {
                case .left:
                    self?.inputSourceController.selectEnglish()
                case .right:
                    self?.inputSourceController.selectJapanese()
                }
            }
        }

        guard monitor.start() else {
            monitoringStatus = .failed
            updateSettingsWindow()
            return
        }

        eventMonitor = monitor
        monitoringStatus = .active
        rebuildMenu()
        updateSettingsWindow()
    }

    private func showInputMonitoringPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "入力監視の権限が必要です"
        alert.informativeText = "システム設定の「入力監視」で KanaEn を許可したあと、KanaEnをもう一度開くか、設定画面で「監視を再試行」を押してください。キー入力の内容は保存・送信しません。"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "設定を開く")
        alert.addButton(withTitle: "あとで")
        if alert.runModal() == .alertFirstButtonReturn {
            openInputMonitoringSettings()
        }
    }

    private func showEventTapError() {
        let alert = NSAlert()
        alert.messageText = "キー監視を開始できませんでした"
        alert.informativeText = "入力監視の設定で KanaEn が有効になっているか確認し、設定画面で「監視を再試行」を押してください。"
        alert.alertStyle = .warning
        alert.runModal()
    }

    @objc private func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }

    @objc private func openInputMonitoringSettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")!
        NSWorkspace.shared.open(url)
    }

    @objc private func toggleLaunchAtLogin(_ sender: NSMenuItem) {
        setLaunchAtLogin(SMAppService.mainApp.status != .enabled)
        rebuildMenu()
    }

    @objc private func toggleStatusItemVisibility(_ sender: NSMenuItem) {
        setStatusItemVisible(!statusItem.isVisible)
    }

    private func setStatusItemVisible(_ isVisible: Bool) {
        UserDefaults.standard.set(isVisible, forKey: Self.showsStatusItemKey)
        statusItem.isVisible = isVisible
        updateSettingsWindow()
        if isVisible {
            rebuildMenu()
        }
    }

    private func setLaunchAtLogin(_ isEnabled: Bool) {
        do {
            if isEnabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            let alert = NSAlert(error: error)
            alert.messageText = "ログイン時起動を変更できませんでした"
            alert.runModal()
        }
        updateSettingsWindow()
    }

    @objc private func openSettings() {
        showSettingsWindow()
    }

    private func showSettingsWindow() {
        if settingsWindowController == nil {
            settingsWindowController = SettingsWindowController(
                onStatusItemVisibilityChanged: { [weak self] isVisible in
                    self?.setStatusItemVisible(isVisible)
                },
                onLaunchAtLoginChanged: { [weak self] isEnabled in
                    self?.setLaunchAtLogin(isEnabled)
                    self?.rebuildMenu()
                },
                onOpenInputMonitoringSettings: { [weak self] in
                    self?.openInputMonitoringSettings()
                },
                onRetryMonitoring: { [weak self] in
                    self?.retryMonitoring(requestPermission: true)
                },
                onQuit: {
                    NSApp.terminate(nil)
                }
            )
        }

        updateSettingsWindow()
        settingsWindowController?.showWindow(nil)
        settingsWindowController?.window?.center()
        NSApp.activate(ignoringOtherApps: true)
        settingsWindowController?.window?.makeKeyAndOrderFront(nil)
    }

    private func updateSettingsWindow() {
        settingsWindowController?.update(
            showsStatusItem: statusItem.isVisible,
            launchesAtLogin: SMAppService.mainApp.status == .enabled,
            monitoringStatus: monitoringStatus
        )
    }
}
