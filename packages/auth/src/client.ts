import { createBrowserClient } from "@supabase/ssr";

/**
 * クライアントサイド用 Supabase クライアント
 * "use client" コンポーネントから呼び出す。
 * createBrowserClient は内部でシングルトンを管理するため
 * コンポーネント内で複数回呼んでも安全。
 */
export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  );
}
