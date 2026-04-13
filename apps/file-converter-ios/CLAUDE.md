# CLAUDE.md — file-converter-ios

> モノレポ全体のルール → `/CLAUDE.md`（必ず先に読む）

## このアプリについて

iOS / iPadOS / macOS ユニバーサル対応のファイル変換アプリ。
画像・PDF・動画をネイティブAPIで端末内処理する。**ファイルはサーバーに送らない。**

Web版（`apps/file-converter`）の機能をネイティブ化したもの。

## Stack

- SwiftUI / iOS 17.0+ / macOS 14.0+
- StoreKit 2（auto-renewable subscription）
- CoreImage / ImageIO（画像変換・圧縮・リサイズ）
- PDFKit（PDF操作全般）
- AVFoundation（動画変換）
- CGImageSource（メタデータ除去）
- xcodegen（`project.yml`）でプロジェクト生成
- サーバー不要・認証不要・ローカルファースト

## 構造

```
Shared/          モデル・サービス（変換エンジン・PlanService）
FileConverter/   iOS / iPadOS / macOS アプリ（MVVM）
FileConverterTests/  ユニットテスト
```

## コア原則

1. **ローカル処理**: ファイル本体をサーバーに送信しない
2. **無料でも便利**: Free プランは単発変換に制限なし（5ファイル/25MBまで）
3. **継続価値は有料**: 一括処理・プリセット・履歴・高度機能は Plus
4. **ユニバーサル**: 1コードベースで iPhone / iPad / Mac 対応

## 課金

- StoreKit 2 auto-renewable subscription
- Product IDs: `fileconverter.plus.monthly`, `fileconverter.plus.yearly`
- Subscription Group: `fileconverter.plus`

## 判断基準

**確認してから進める**
- 技術スタック・課金の設計変更
- 新しい変換ツールの追加
- 外部依存ライブラリの追加

**確認せず進めてよい**
- 軽微な UI 調整・文言修正
- 変換品質の改善
- エラーハンドリングの強化

## セキュリティ

- ファイルはメモリ上でのみ処理。一時ファイルは変換完了後に削除
- サーバー通信なし。認証なし
- StoreKit 2 のトランザクション検証はクライアントサイドのみ（MVP）
