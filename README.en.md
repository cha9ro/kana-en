# KanaEn

[日本語](README.md)

KanaEn is a lightweight macOS menu bar app that switches input sources with a single press of either Command key.

- Left Command alone switches to English.
- Right Command alone switches to Japanese.
- Command shortcuts such as `⌘C` and `⌘V` continue to work normally.
- Using Command with another key, click, or scroll does not switch the input source.

KanaEn is intended for people who do not want to keep a general-purpose keyboard customization tool running for this one behavior. It uses only standard macOS frameworks and has no third-party dependencies.

## Features

- Small native AppKit menu bar app
- No third-party libraries, drivers, or kernel extensions
- No Dock icon; the settings window appears only when requested
- Optional launch at login
- Read-only keyboard event monitoring
- No networking, telemetry, or key logging

## Requirements

- macOS 13 Ventura or later
- A keyboard with distinct left and right Command keys
- English and Japanese input sources enabled in macOS
- Xcode Command Line Tools when building from source

## Installation

Download the latest [KanaEn.zip](https://github.com/cha9ro/kana-en/releases/latest/download/KanaEn.zip), extract it, and move `KanaEn.app` to the Applications folder.

The current distribution build is not signed and notarized with a Developer ID. If macOS shows a warning on first launch, Control-click `KanaEn.app` in Finder and choose Open.

To build from source:

```sh
git clone https://github.com/cha9ro/kana-en.git
cd kana-en
./scripts/build-app.sh
open dist/KanaEn.app
```

Move `dist/KanaEn.app` to `/Applications` if desired.

## First launch

1. Launch KanaEn.
2. Open System Settings when prompted.
3. Enable KanaEn under Privacy & Security → Input Monitoring.
4. Quit and relaunch KanaEn.

Input Monitoring permission is required to identify a standalone Command-key press system-wide. macOS may ask you to grant permission again after rebuilding the app.

KanaEn does not appear in the Dock. Its menu bar menu lets you show or hide the menu bar icon, toggle launch at login, open Input Monitoring settings, or quit the app.

Turning off “メニューバーに表示” hides only the icon; input-source switching continues to run. Open KanaEn again from Finder, Spotlight, or Launchpad to display its settings window, where you can change menu bar visibility and launch-at-login behavior.

## Input sources

KanaEn prefers `ABC`, then `US`, for English. It prefers the built-in macOS Japanese input method for Japanese. If those identifiers are unavailable, it falls back to an enabled input source declaring the `en` or `ja` language.

## Development

Run the test suite:

```sh
swift test
```

Build the app bundle:

```sh
./scripts/build-app.sh
```

The build script creates the icon, compiles a release build, assembles `dist/KanaEn.app`, and applies an ad-hoc code signature.

An ad-hoc signature changes its code hash after every rebuild, so macOS may require Input Monitoring permission again. If an Apple Development or Developer ID certificate is available, provide a stable signing identity:

```sh
CODESIGN_IDENTITY="Apple Development: Your Name (TEAMID)" ./scripts/build-app.sh
```

Release binaries should be signed and notarized with an Apple-issued certificate.

## Privacy and security

KanaEn uses a listen-only CGEvent tap. It does not modify events, store input, send telemetry, or make network requests.

See [SECURITY.md](SECURITY.md) to report a vulnerability responsibly.

## Contributing

Bug reports, feature suggestions, and pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

KanaEn is available under the [MIT License](LICENSE).
