import { createClient } from "@supabase/supabase-js";

/**
 * Supabase Service Role クライアント（サーバーサイド専用）
 *
 * ⚠️  このクライアントは RLS を完全にバイパスする。
 * ⚠️  "use client" コードや NEXT_PUBLIC_* 変数から絶対に使わない。
 * ⚠️  使用箇所: apps/api の webhook ハンドラーのみ。
 *
 * SUPABASE_SERVICE_ROLE_KEY は Vercel の Environment Variables に設定し、
 * コードに直接書かない（Gitleaks CI で検知される）。
 */
export function createAdminClient() {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

  if (!url || !serviceRoleKey) {
    throw new Error(
      "NEXT_PUBLIC_SUPABASE_URL または SUPABASE_SERVICE_ROLE_KEY が未設定です"
    );
  }

  return createClient(url, serviceRoleKey, {
    auth: {
      // サーバーサイドのみ使用するためセッション管理は不要
      autoRefreshToken: false,
      persistSession: false,
    },
  });
}
