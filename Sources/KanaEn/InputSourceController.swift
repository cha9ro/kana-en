import Carbon

final class InputSourceController {
    private let englishPreferredIDs = [
        "com.apple.keylayout.ABC",
        "com.apple.keylayout.US"
    ]

    private let japanesePreferredIDs = [
        "com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese",
        "com.apple.inputmethod.Kotoeri.Japanese"
    ]

    func selectEnglish() {
        select(preferredIDs: englishPreferredIDs, language: "en")
    }

    func selectJapanese() {
        select(preferredIDs: japanesePreferredIDs, language: "ja")
    }

    private func select(preferredIDs: [String], language: String) {
        let sources = enabledKeyboardInputSources()

        for preferredID in preferredIDs {
            if let source = sources.first(where: { sourceID(of: $0) == preferredID }) {
                TISSelectInputSource(source)
                return
            }
        }

        if let source = sources.first(where: { languages(of: $0).contains(language) }) {
            TISSelectInputSource(source)
        }
    }

    private func enabledKeyboardInputSources() -> [TISInputSource] {
        let filter: [CFString: Any] = [
            kTISPropertyInputSourceCategory: kTISCategoryKeyboardInputSource!,
            kTISPropertyInputSourceIsEnabled: true,
            kTISPropertyInputSourceIsSelectCapable: true
        ]

        guard let list = TISCreateInputSourceList(filter as CFDictionary, false)?.takeRetainedValue() as? [TISInputSource] else {
            return []
        }
        return list
    }

    private func sourceID(of source: TISInputSource) -> String? {
        guard let pointer = TISGetInputSourceProperty(source, kTISPropertyInputSourceID) else { return nil }
        return Unmanaged<CFString>.fromOpaque(pointer).takeUnretainedValue() as String
    }

    private func languages(of source: TISInputSource) -> [String] {
        guard let pointer = TISGetInputSourceProperty(source, kTISPropertyInputSourceLanguages) else { return [] }
        return Unmanaged<CFArray>.fromOpaque(pointer).takeUnretainedValue() as? [String] ?? []
    }
}
