# Budget Alert Cloud Function デプロイ手順

## 概要
Google Cloud の予算アラートが発火したら：
1. Vercel の `OCR_ENABLED=false` に自動切替 → OCR 機能を緊急停止
2. メールで通知 → 何が起きたか・復旧方法を案内

## 前提
- Google Cloud プロジェクトで課金が有効
- Vercel にプロジェクトがデプロイ済み

## 手順

### 1. Vercel トークンを作成
1. https://vercel.com/account/tokens にアクセス
2. 「Create Token」→ 名前: `budget-alert` → スコープ: Full Account → 作成
3. トークンをメモ

### 2. Vercel プロジェクト ID を確認
1. https://vercel.com → プロジェクト → Settings → General
2. 「Project ID」をメモ

### 3. SendGrid API キーを取得（メール通知用）
1. https://signup.sendgrid.com/ でアカウント作成（無料: 100通/日）
2. Settings → API Keys → Create API Key
3. 権限: 「Restricted Access」→ Mail Send: Full Access
4. API キーをメモ
5. Settings → Sender Authentication で送信元メールアドレスを認証

### 4. Pub/Sub トピックを作成
1. https://console.cloud.google.com/cloudpubsub/topic/list にアクセス
2. 「CREATE TOPIC」→ Topic ID: `budget-alert` → 作成

### 5. 予算アラートに Pub/Sub を接続 + メール通知
1. https://console.cloud.google.com/billing/budgets にアクセス
2. 作成済みの予算を編集（または新規作成）
3. 「Actions」セクション:
   - ✅ 「Email alerts to billing admins and users」にチェック（組み込みメール通知）
   - 「Connect a Pub/Sub topic to this budget」→ `budget-alert` トピックを選択
4. 保存

### 6. Cloud Function をデプロイ
1. https://console.cloud.google.com/functions にアクセス
2. 「CREATE FUNCTION」
3. 設定:
   - Function name: `budget-alert`
   - Region: `asia-northeast1`（東京）
   - Trigger type: **Cloud Pub/Sub**
   - Topic: `budget-alert`（手順4で作成したもの）
4. 「NEXT」→ Runtime: **Node.js 20**
5. Entry point: `budgetAlert`
6. ソースコード: 「Inline Editor」で index.js と package.json の内容を貼り付け
7. 「Runtime environment variables」に以下を追加:

| 変数名 | 値 | 説明 |
|---|---|---|
| `VERCEL_TOKEN` | （手順1のトークン） | Vercel API 認証用 |
| `VERCEL_PROJECT_ID` | （手順2のID） | 対象プロジェクト |
| `BUDGET_THRESHOLD` | `0.8` | 80%で発動（1.0なら100%） |
| `SENDGRID_API_KEY` | （手順3のキー） | メール送信用 |
| `NOTIFY_EMAIL` | あなたのメール | 通知先 |

8. 「DEPLOY」

### 7. テスト
1. Cloud Function の「TESTING」タブ
2. 以下の JSON を入力:
```json
{
  "data": "eyJjb3N0QW1vdW50IjoxMCwiYnVkZ2V0QW1vdW50Ijo1fQ=="
}
```
（↑ `{"costAmount":10,"budgetAmount":5}` の base64）

3. 「TEST THE FUNCTION」
4. ログに "OCR_ENABLED set to false" + "Email sent" が出れば成功
5. メールが届くことを確認

### 復旧方法
予算内に戻ったら：
1. Vercel ダッシュボード → Settings → Environment Variables
2. `OCR_ENABLED` を `true` に変更
3. Deployments → 最新を Redeploy
