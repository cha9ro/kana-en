import ApplicationServices

final class CommandEventMonitor {
    private static let leftCommandKeyCode: Int64 = 55
    private static let rightCommandKeyCode: Int64 = 54

    private let onTap: (CommandSide) -> Void
    private var detector = CommandTapDetector()
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    init(onTap: @escaping (CommandSide) -> Void) {
        self.onTap = onTap
    }

    deinit {
        stop()
    }

    func start() -> Bool {
        guard eventTap == nil else { return true }

        let eventTypes: [CGEventType] = [
            .flagsChanged,
            .keyDown,
            .leftMouseDown,
            .rightMouseDown,
            .otherMouseDown,
            .scrollWheel
        ]
        let mask = eventTypes.reduce(CGEventMask(0)) { $0 | (CGEventMask(1) << $1.rawValue) }

        let callback: CGEventTapCallBack = { _, type, event, userInfo in
            guard let userInfo else { return Unmanaged.passUnretained(event) }
            let monitor = Unmanaged<CommandEventMonitor>.fromOpaque(userInfo).takeUnretainedValue()
            monitor.handle(type: type, event: event)
            return Unmanaged.passUnretained(event)
        }

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: mask,
            callback: callback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            return false
        }

        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        eventTap = tap
        runLoopSource = source
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        return true
    }

    func stop() {
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        }
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }
        runLoopSource = nil
        eventTap = nil
    }

    func ensureEnabled() {
        guard let eventTap else { return }
        if !CGEvent.tapIsEnabled(tap: eventTap) {
            CGEvent.tapEnable(tap: eventTap, enable: true)
        }
    }

    private func handle(type: CGEventType, event: CGEvent) {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let eventTap {
                CGEvent.tapEnable(tap: eventTap, enable: true)
            }
            return
        }

        let observed: ObservedKeyEvent
        if type == .flagsChanged {
            let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
            let side: CommandSide
            switch keyCode {
            case Self.leftCommandKeyCode: side = .left
            case Self.rightCommandKeyCode: side = .right
            default:
                _ = detector.process(.otherActivity)
                return
            }

            let isDown = event.flags.contains(.maskCommand)
            observed = isDown ? .commandDown(side) : .commandUp(side)
        } else {
            observed = .otherActivity
        }

        if let command = detector.process(observed) {
            onTap(command)
        }
    }
}
