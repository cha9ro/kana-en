# Changelog

このプロジェクトの主な変更を記録します。

形式は [Keep a Changelog](https://keepachangelog.com/ja/1.1.0/) を参考にし、バージョン番号は [Semantic Versioning](https://semver.org/lang/ja/) に従います。

## [Unreleased]

### Added

- GitHub Release の公開時に universal 版アプリと SHA-256 チェックサムを添付する GitHub Actions
- 入力ソース切替を動作させたまま、メニューバーアイコンを非表示にする設定
- FinderやSpotlightからアプリをもう一度開いたときに表示する設定ウィンドウ
- キー監視とアクセシビリティ権限の状態表示、および監視の再試行
- ビルド時に `CODESIGN_IDENTITY` で正式な署名IDを指定する機能
- グローバルキー監視に必要な「入力監視」権限の正しい検出と設定案内

## [0.0.1] - 2026-08-13

### Added

- 左 Command 単押しで英語入力へ切り替える機能
- 右 Command 単押しで日本語入力へ切り替える機能
- ショートカット、クリック、スクロールとの併用を除外する判定
- メニューバー UI
- ログイン時起動
- アクセシビリティ権限の案内
- macOS 標準 API による入力ソース切替
