# Contributing to KanaEn

KanaEn へのコントリビューションを歓迎します。

参加者には、建設的で敬意のあるコミュニケーションをお願いします。嫌がらせ、差別、個人攻撃、他者の個人情報の公開は認められません。問題がある場合は公開の場で応酬せず、メンテナーへ報告してください。

## Issue を作成する前に

- 同じ内容の Issue がないか確認してください。
- バグの場合は、macOS のバージョン、キーボード、使用している入力ソース、再現手順を記載してください。
- セキュリティ上の問題は公開 Issue にせず、[SECURITY.md](SECURITY.md) に従ってください。

## 開発環境

- macOS 13 以降
- Xcode Command Line Tools
- Swift 5.9 以降

テストを実行します。

```sh
swift test
```

アプリバンドルを生成します。

```sh
./scripts/build-app.sh
```

## Pull Request

1. 変更は1つの目的に絞ってください。
2. 挙動を変更する場合は、可能な範囲でテストを追加または更新してください。
3. `swift test` と `./scripts/build-app.sh` が成功することを確認してください。
4. ユーザー向けの変更がある場合は README または CHANGELOG を更新してください。
5. Pull Request に変更理由と確認方法を記載してください。

提出されたコントリビューションは、プロジェクトと同じ [MIT License](LICENSE) の下で提供されるものとします。
