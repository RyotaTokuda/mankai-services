import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";

/**
 * セッションリフレッシュ処理
 * 各アプリの middleware.ts からこの関数を呼び出す。
 *
 * セキュリティ:
 * - getSession() はキャッシュを返す可能性があるため使用しない
 * - getUser() は Supabase サーバーで検証するため常に信頼できる
 */
export async function updateSession(request: NextRequest) {
  let supabaseResponse = NextResponse.next({ request });

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll();
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) =>
            request.cookies.set(name, value)
          );
          supabaseResponse = NextResponse.next({ request });
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options)
          );
        },
      },
    }
  );

  await supabase.auth.getUser();

  return supabaseResponse;
}

/**
 * 各アプリの middleware config に使う matcher
 * 静的ファイル・内部ルートはスキップ
 */
export const middlewareConfig = {
  matcher: [
    "/((?!_next/static|_next/image|favicon\\.ico|sw\\.js|icon\\.svg|offline\\.html|manifest\\.webmanifest).*)",
  ],
};
