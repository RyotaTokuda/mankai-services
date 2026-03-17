import { createClient } from "./server";
import { NextResponse } from "next/server";

/**
 * Google OAuth コールバックハンドラー
 * 認可コードを Supabase セッションと交換する。
 *
 * 各アプリの app/auth/callback/route.ts でこれを re-export するだけでよい:
 *   export { GET } from "@mankai/auth/callback";
 *
 * セキュリティ:
 * - `next` パラメータは相対パス（/ 始まり）のみ許可（オープンリダイレクト防止）
 * - 認証失敗時は詳細を外部に漏らさずルートへリダイレクト
 */
export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url);
  const code = searchParams.get("code");
  const next = searchParams.get("next") ?? "/";

  // オープンリダイレクト防止：/ で始まる相対パスのみ受け付ける
  const safeNext = /^\/(?!\/|%2F)/.test(next) ? next : "/";

  if (code) {
    const supabase = await createClient();
    const { error } = await supabase.auth.exchangeCodeForSession(code);
    if (!error) {
      return NextResponse.redirect(`${origin}${safeNext}`);
    }
  }

  return NextResponse.redirect(`${origin}/?error=auth_failed`);
}
