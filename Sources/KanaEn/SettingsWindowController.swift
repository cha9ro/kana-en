import AppKit

enum MonitoringStatus {
    case starting
    case active
    case inputMonitoringRequired
    case failed
}

final class SettingsWindowController: NSWindowController {
    private let onStatusItemVisibilityChanged: (Bool) -> Void
    private let onLaunchAtLoginChanged: (Bool) -> Void
    private let onOpenInputMonitoringSettings: () -> Void
    private let onRetryMonitoring: () -> Void
    private let onQuit: () -> Void

    private let monitoringStatusLabel = NSTextField(labelWithString: "監視を開始しています…")

    private lazy var statusItemCheckbox = NSButton(
        checkboxWithTitle: "メニューバーに表示",
        target: self,
        action: #selector(statusItemVisibilityChanged(_:))
    )

    private lazy var launchAtLoginCheckbox = NSButton(
        checkboxWithTitle: "ログイン時に起動",
        target: self,
        action: #selector(launchAtLoginChanged(_:))
    )

    init(
        onStatusItemVisibilityChanged: @escaping (Bool) -> Void,
        onLaunchAtLoginChanged: @escaping (Bool) -> Void,
        onOpenInputMonitoringSettings: @escaping () -> Void,
        onRetryMonitoring: @escaping () -> Void,
        onQuit: @escaping () -> Void
    ) {
        self.onStatusItemVisibilityChanged = onStatusItemVisibilityChanged
        self.onLaunchAtLoginChanged = onLaunchAtLoginChanged
        self.onOpenInputMonitoringSettings = onOpenInputMonitoringSettings
        self.onRetryMonitoring = onRetryMonitoring
        self.onQuit = onQuit

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 440, height: 280),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "KanaEn 設定"
        window.isReleasedWhenClosed = false
        window.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary]

        super.init(window: window)
        window.contentViewController = makeContentViewController()
        window.setContentSize(NSSize(width: 440, height: 280))
        window.contentMinSize = NSSize(width: 440, height: 280)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(showsStatusItem: Bool, launchesAtLogin: Bool, monitoringStatus: MonitoringStatus) {
        statusItemCheckbox.state = showsStatusItem ? .on : .off
        launchAtLoginCheckbox.state = launchesAtLogin ? .on : .off

        switch monitoringStatus {
        case .starting:
            monitoringStatusLabel.stringValue = "● 監視を開始しています…"
            monitoringStatusLabel.textColor = .secondaryLabelColor
        case .active:
            monitoringStatusLabel.stringValue = "● 左右 Command を監視中"
            monitoringStatusLabel.textColor = .systemGreen
        case .inputMonitoringRequired:
            monitoringStatusLabel.stringValue = "● 入力監視の権限が必要です"
            monitoringStatusLabel.textColor = .systemOrange
        case .failed:
            monitoringStatusLabel.stringValue = "● キー監視を開始できませんでした"
            monitoringStatusLabel.textColor = .systemRed
        }
    }

    private func makeContentViewController() -> NSViewController {
        let viewController = NSViewController()
        let contentView = NSView(frame: NSRect(x: 0, y: 0, width: 440, height: 280))
        contentView.autoresizingMask = [.width, .height]
        viewController.view = contentView

        let titleLabel = NSTextField(labelWithString: "KanaEn")
        titleLabel.font = .systemFont(ofSize: 22, weight: .semibold)


        let inputMonitoringButton = NSButton(
            title: "入力監視設定を開く",
            target: self,
            action: #selector(openInputMonitoringSettings)
        )
        inputMonitoringButton.bezelStyle = .rounded

        let retryButton = NSButton(
            title: "監視を再試行",
            target: self,
            action: #selector(retryMonitoring)
        )
        retryButton.bezelStyle = .rounded

        let quitButton = NSButton(
            title: "KanaEn を終了",
            target: self,
            action: #selector(quitApplication)
        )
        quitButton.bezelStyle = .rounded

        let spacer = NSView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        let buttonRow = NSStackView(views: [inputMonitoringButton, retryButton, spacer, quitButton])
        buttonRow.orientation = .horizontal
        buttonRow.alignment = .centerY
        buttonRow.spacing = 8

        let stack = NSStackView(views: [
            titleLabel,
            monitoringStatusLabel,
            statusItemCheckbox,
            launchAtLoginCheckbox,
            buttonRow
        ])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.setCustomSpacing(20, after: monitoringStatusLabel)
        stack.setCustomSpacing(6, after: statusItemCheckbox)
        stack.setCustomSpacing(20, after: launchAtLoginCheckbox)
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            buttonRow.widthAnchor.constraint(equalTo: stack.widthAnchor)
        ])

        return viewController
    }

    @objc private func statusItemVisibilityChanged(_ sender: NSButton) {
        onStatusItemVisibilityChanged(sender.state == .on)
    }

    @objc private func launchAtLoginChanged(_ sender: NSButton) {
        onLaunchAtLoginChanged(sender.state == .on)
    }

    @objc private func openInputMonitoringSettings() {
        onOpenInputMonitoringSettings()
    }

    @objc private func retryMonitoring() {
        onRetryMonitoring()
    }

    @objc private func quitApplication() {
        onQuit()
    }
}
