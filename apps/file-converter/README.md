# ローカルファイル変換

ブラウザ内だけで動作するファイル変換サービス。**ファイルはサーバーに送られません。**

🔗 https://file-converter-beige.vercel.app

---

## 対応形式

### 画像
| 入力 | 出力 |
|---|---|
| HEIC / HEIF | JPG / PNG |
| WebP | JPG / PNG / WebP |
| JPG / PNG | JPG / PNG / WebP |

上限 100MB

### 動画
| 入力 | 出力 |
|---|---|
| MP4 / MOV / AVI / MKV | MP4 |
| MP4 / MOV / AVI / MKV | GIF |

上限 500MB（目安 5 分以内の短尺推奨）

---

## セットアップ

Node.js v20 が必要です。

```bash
source ~/.nvm/nvm.sh && nvm use 20
npm install
npm run dev
```

`http://localhost:3000` をブラウザで開く。

---

## 技術スタック

| パッケージ | 役割 |
|---|---|
| Next.js 16 (App Router) | フレームワーク |
| Tailwind CSS v4 | スタイル |
| heic2any | HEIC → JPG / PNG |
| Canvas API | 画像変換・圧縮・リサイズ |
| @ffmpeg/ffmpeg | 動画変換（ブラウザ内 WASM） |

---

## ディレクトリ構成

```
app/
  page.tsx              メインUI・状態管理
  layout.tsx
components/
  DropZone.tsx          ドラッグ&ドロップ・サムネイル表示
  FormatPicker.tsx      画像：形式・品質・プリセット設定
  VideoFormatPicker.tsx 動画：形式・ビットレート・プリセット設定
  ConvertPanel.tsx      ファイル一覧・進捗・ダウンロード
lib/
  imageConverter.ts     画像変換ロジック
  videoConverter.ts     動画変換ロジック（ffmpeg.wasm）
.github/workflows/      CI（lint・typecheck・audit・license・bundle-size）
```
