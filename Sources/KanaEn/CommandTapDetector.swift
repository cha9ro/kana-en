enum CommandSide: Equatable {
    case left
    case right
}

enum ObservedKeyEvent: Equatable {
    case commandDown(CommandSide)
    case commandUp(CommandSide)
    case otherActivity
}

/// A tiny state machine that only accepts a Command key pressed and released by itself.
struct CommandTapDetector {
    private var candidate: CommandSide?

    mutating func process(_ event: ObservedKeyEvent) -> CommandSide? {
        switch event {
        case .commandDown(let side):
            if candidate == nil {
                candidate = side
            } else {
                candidate = nil
            }
            return nil

        case .commandUp(let side):
            defer { candidate = nil }
            return candidate == side ? side : nil

        case .otherActivity:
            candidate = nil
            return nil
        }
    }
}
