/**
 * Google Cloud Budget Alert → Vercel OCR_ENABLED=false + メール通知
 *
 * Pub/Sub トピックから予算超過通知を受け取り、
 * 1. Vercel API で OCR_ENABLED=false に更新 → 再デプロイ
 * 2. メールで通知（SendGrid 経由）
 *
 * 環境変数（Cloud Function に設定）:
 *   VERCEL_TOKEN        — Vercel のアクセストークン
 *   VERCEL_PROJECT_ID   — Vercel プロジェクト ID
 *   VERCEL_TEAM_ID      — Vercel チーム ID（個人なら不要）
 *   BUDGET_THRESHOLD    — 通知を実行するしきい値（0.0〜1.0、デフォルト 1.0 = 100%）
 *   SENDGRID_API_KEY    — SendGrid API キー（メール通知用）
 *   NOTIFY_EMAIL        — 通知先メールアドレス
 */

// eslint-disable-next-line @typescript-eslint/no-require-imports -- Cloud Functions CommonJS entrypoint
const https = require("https");

function httpPost(hostname, path, body, headers) {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify(body);
    const req = https.request(
      {
        hostname,
        path,
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Content-Length": Buffer.byteLength(data),
          ...headers,
        },
      },
      (res) => {
        let chunks = "";
        res.on("data", (c) => (chunks += c));
        res.on("end", () => {
          try {
            resolve({ status: res.statusCode, data: JSON.parse(chunks) });
          } catch {
            resolve({ status: res.statusCode, data: chunks });
          }
        });
      }
    );
    req.on("error", reject);
    req.write(data);
    req.end();
  });
}

function vercelApi(method, path, body, token) {
  return new Promise((resolve, reject) => {
    const data = body ? JSON.stringify(body) : null;
    const req = https.request(
      {
        hostname: "api.vercel.com",
        path,
        method,
        headers: {
          Authorization: `Bearer ${token}`,
          "Content-Type": "application/json",
          ...(data ? { "Content-Length": Buffer.byteLength(data) } : {}),
        },
      },
      (res) => {
        let chunks = "";
        res.on("data", (c) => (chunks += c));
        res.on("end", () => {
          try {
            resolve({ status: res.statusCode, data: JSON.parse(chunks) });
          } catch {
            resolve({ status: res.statusCode, data: chunks });
          }
        });
      }
    );
    req.on("error", reject);
    if (data) req.write(data);
    req.end();
  });
}

async function sendEmail(to, subject, body) {
  const apiKey = process.env.SENDGRID_API_KEY;
  if (!apiKey || !to) {
    console.log("SENDGRID_API_KEY or NOTIFY_EMAIL not set, skipping email.");
    return;
  }

  const res = await httpPost(
    "api.sendgrid.com",
    "/v3/mail/send",
    {
      personalizations: [{ to: [{ email: to }] }],
      from: { email: "noreply@parking-reader.app", name: "駐車料金リーダー" },
      subject,
      content: [{ type: "text/plain", value: body }],
    },
    { Authorization: `Bearer ${apiKey}` }
  );

  console.log(`Email sent to ${to}: status=${res.status}`);
}

// eslint-disable-next-line @typescript-eslint/no-unused-vars -- GCP Pub/Sub function signature requires (message, context)
exports.budgetAlert = async (message, _context) => {
  // Pub/Sub メッセージをデコード
  const payload = message.data
    ? JSON.parse(Buffer.from(message.data, "base64").toString())
    : {};

  const threshold = parseFloat(process.env.BUDGET_THRESHOLD || "1.0");
  const alertSpend = payload.costAmount || 0;
  const budgetAmount = payload.budgetAmount || 1;
  const ratio = alertSpend / budgetAmount;

  console.log(
    `Budget alert: spent $${alertSpend} / $${budgetAmount} (${(ratio * 100).toFixed(1)}%), threshold: ${(threshold * 100).toFixed(0)}%`
  );

  if (ratio < threshold) {
    console.log("Below threshold, skipping.");
    return;
  }

  const token = process.env.VERCEL_TOKEN;
  const projectId = process.env.VERCEL_PROJECT_ID;
  const teamId = process.env.VERCEL_TEAM_ID;
  const notifyEmail = process.env.NOTIFY_EMAIL;

  if (!token || !projectId) {
    console.error("Missing VERCEL_TOKEN or VERCEL_PROJECT_ID");
    return;
  }

  const teamQuery = teamId ? `?teamId=${teamId}` : "";

  // 1. 既存の OCR_ENABLED 環境変数を取得
  const envRes = await vercelApi(
    "GET",
    `/v9/projects/${projectId}/env${teamQuery}`,
    null,
    token
  );

  const envVars = envRes.data?.envs || [];
  const ocrEnv = envVars.find((e) => e.key === "OCR_ENABLED");

  if (ocrEnv && ocrEnv.value === "false") {
    console.log("OCR_ENABLED is already false, skipping.");
    return;
  }

  // 2. OCR_ENABLED=false に更新
  if (ocrEnv) {
    await vercelApi(
      "PATCH",
      `/v9/projects/${projectId}/env/${ocrEnv.id}${teamQuery}`,
      { value: "false" },
      token
    );
  } else {
    await vercelApi(
      "POST",
      `/v10/projects/${projectId}/env${teamQuery}`,
      {
        key: "OCR_ENABLED",
        value: "false",
        type: "plain",
        target: ["production"],
      },
      token
    );
  }
  console.log("OCR_ENABLED set to false");

  // 3. 再デプロイ
  const deployRes = await vercelApi(
    "POST",
    `/v13/deployments${teamQuery}`,
    {
      name: "parking-fee-calculator",
      project: projectId,
      target: "production",
      gitSource: { type: "github", repoId: projectId },
    },
    token
  );
  console.log(`Redeploy triggered: status=${deployRes.status}`);

  // 4. メール通知
  const now = new Date().toLocaleString("ja-JP", { timeZone: "Asia/Tokyo" });
  await sendEmail(
    notifyEmail,
    "⚠️ 駐車料金リーダー: OCR機能を自動停止しました",
    [
      `駐車料金リーダーの OCR 機能が自動停止されました。`,
      ``,
      `【理由】Google Cloud の API 利用料が予算のしきい値を超えたため`,
      `【発生日時】${now}`,
      `【利用額】$${alertSpend} / 予算 $${budgetAmount} (${(ratio * 100).toFixed(1)}%)`,
      ``,
      `【復旧方法】`,
      `1. Vercel ダッシュボード → Settings → Environment Variables`,
      `2. OCR_ENABLED を "true" に変更`,
      `3. Deployments → 最新を Redeploy`,
      ``,
      `https://vercel.com/dashboard`,
    ].join("\n")
  );
};
