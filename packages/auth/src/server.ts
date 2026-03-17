import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";

/**
 * サーバーサイド用 Supabase クライアント
 * Server Components・Route Handlers・middleware から呼び出す。
 * セッションは httpOnly Cookie で管理されるため
 * localStorage ベースの実装より安全。
 */
export async function createClient() {
  const cookieStore = await cookies();

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            );
          } catch {
            // Server Component（読み取り専用コンテキスト）からの呼び出しは無視
          }
        },
      },
    }
  );
}
