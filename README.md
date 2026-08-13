# KanaEn

[English](README.en.md)

左右の Command キーを単押しするだけで、英語／日本語の入力ソースを切り替える軽量な macOS メニューバーアプリです。

Karabiner-Elements のような汎用キーカスタマイズツールを、この操作だけのために常駐させたくない人向けに作られています。外部依存はなく、macOS の標準 API だけで動作します。

## 動作

| 操作 | 結果 |
| --- | --- |
| 左 Command を単押し | 英語入力に切り替え |
| 右 Command を単押し | 日本語入力に切り替え |
| Command と別のキーを併用 | 何もしない |
| Command を押しながらクリック／スクロール | 何もしない |

`⌘C`、`⌘V` など、通常のキーボードショートカットには干渉しません。

## 特徴

- AppKit 製の小さなメニューバーアプリ
- サードパーティライブラリ、ドライバ、カーネル拡張なし
- Dock アイコンなし、必要なときだけ表示される設定ウィンドウ
- ログイン時起動をメニューから切り替え可能
- キーイベントは読み取り専用で監視
- ネットワーク通信、テレメトリ、キー入力の保存なし

## 必要環境

- macOS 13 Ventura 以降
- US キーボード、または左右の Command キーを持つキーボード
- macOS の入力ソースに英語と日本語が追加済みであること
- ビルドする場合は Xcode Command Line Tools

## インストール

最新版は [KanaEn.zip をダウンロード](https://github.com/cha9ro/kana-en/releases/latest/download/KanaEn.zip) して展開し、`KanaEn.app` を「アプリケーション」フォルダへ移動してください。

現在の配布ビルドは Developer ID による署名・公証を行っていません。初回起動時に macOS で警告が表示された場合は、Finder で `KanaEn.app` を Control キーを押しながらクリックし、「開く」を選択してください。

ソースからビルドする場合:

```sh
git clone https://github.com/cha9ro/kana-en.git
cd kana-en
./scripts/build-app.sh
open dist/KanaEn.app
```

生成された `dist/KanaEn.app` は、必要に応じて `/Applications` に移動してください。

## 初回設定

1. KanaEn を起動します。
2. 表示された案内から「システム設定」を開きます。
3. 「プライバシーとセキュリティ」→「入力監視」で KanaEn を許可します。
4. KanaEn を終了し、もう一度起動します。

入力監視の権限は、左右の Command キーが単押しされたことをシステム全体で検出するために必要です。アプリをビルドし直した場合、macOS から再許可を求められることがあります。

アプリは Dock に表示されません。メニューバーのアイコンから、次の操作ができます。

- メニューバーアイコンの表示／非表示
- ログイン時起動の有効化／無効化
- 入力監視設定を開く
- KanaEn を終了する

「メニューバーに表示」のチェックを外すと、入力ソース切替を動作させたままアイコンだけを非表示にできます。Finder、Spotlight、Launchpadなどから KanaEn をもう一度開くと設定ウィンドウが表示され、メニューバー表示やログイン時起動を変更できます。

## 入力ソース

英語は `ABC`、次に `US` を優先します。日本語は macOS 標準の日本語入力を優先します。該当する識別子が見つからない場合は、入力ソースが宣言する言語（`en`／`ja`）から選択します。

期待どおりに切り替わらない場合は、「システム設定」→「キーボード」→「テキスト入力」→「編集」で、英語と日本語の入力ソースが有効になっているか確認してください。

## Karabiner-Elements から移行する場合

KanaEn の動作を確認してから、Karabiner-Elements 側の左右 Command 用ルールを無効にしてください。両方を有効にすると、入力ソース切替が重複する可能性があります。

## 開発

デバッグビルドとテスト:

```sh
swift test
```

配布用アプリの生成:

```sh
./scripts/build-app.sh
```

ビルドスクリプトはリリース構成でコンパイルし、アイコンを生成して、`dist/KanaEn.app` に ad-hoc 署名を行います。

ローカルのad-hoc署名はビルドごとにコードハッシュが変わるため、macOSから入力監視権限の再許可を求められる場合があります。Apple DevelopmentまたはDeveloper IDの署名証明書がある場合は、安定した署名IDを指定できます。

```sh
CODESIGN_IDENTITY="Apple Development: Your Name (TEAMID)" ./scripts/build-app.sh
```

配布するバイナリには正式な署名と公証を行うことを推奨します。

構成:

```text
Sources/KanaEn/       アプリ本体
Tests/KanaEnTests/    Command 単押し判定のテスト
Resources/            Info.plist とアプリアイコン
scripts/              ビルド／アイコン生成スクリプト
```

## プライバシーとセキュリティ

KanaEn は `listenOnly` の CGEvent tap でイベントを監視し、イベントを書き換えません。ネットワーク機能や永続的な入力ログもありません。

脆弱性を見つけた場合は、公開 Issue を作成する前に [SECURITY.md](SECURITY.md) を確認してください。

## コントリビューション

バグ報告、機能提案、Pull Request を歓迎します。手順は [CONTRIBUTING.md](CONTRIBUTING.md) を参照してください。

## ライセンス

[MIT License](LICENSE) で公開しています。
