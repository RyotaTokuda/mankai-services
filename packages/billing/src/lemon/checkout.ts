/**
 * Lemon Squeezy チェックアウト URL を生成する
 *
 * 使い方:
 *   const url = createCheckoutUrl({
 *     variantId: process.env.NEXT_PUBLIC_LS_PRO_VARIANT_ID!,
 *     userId: user.id,
 *     email: user.email,
 *   });
 *   window.location.href = url;
 *
 * セキュリティ:
 * - user_id を custom_data に埋め込むことで、webhook がどのユーザーの
 *   購入かを特定できる。メールアドレスは渡さない。
 * - variantId は環境変数から取得し、コードに直接書かない。
 */
export function createCheckoutUrl(params: {
  /** Lemon Squeezy の Variant ID（NEXT_PUBLIC_LS_PRO_VARIANT_ID） */
  variantId: string;
  /** Supabase の user.id（UUID）。webhook の紐付けに必須 */
  userId: string;
  /** メールアドレス（任意・フォームの事前入力用） */
  email?: string;
  /** 購入完了後のリダイレクト先（任意） */
  redirectUrl?: string;
}): string {
  const { variantId, userId, email, redirectUrl } = params;

  const storeSlug = process.env.NEXT_PUBLIC_LS_STORE_SLUG;
  if (!storeSlug) {
    throw new Error("NEXT_PUBLIC_LS_STORE_SLUG が未設定です");
  }

  const url = new URL(
    `https://${storeSlug}.lemonsqueezy.com/checkout/buy/${variantId}`
  );

  // user_id を custom_data として埋め込む（webhook で受け取る）
  url.searchParams.set("checkout[custom][user_id]", userId);

  if (email) {
    url.searchParams.set("checkout[email]", email);
  }

  if (redirectUrl) {
    // リダイレクト先は自サービスの URL のみ許可（オープンリダイレクト防止）
    const allowed = process.env.NEXT_PUBLIC_APP_URL ?? "";
    if (allowed && !redirectUrl.startsWith(allowed)) {
      throw new Error("redirectUrl が許可されていないオリジンです");
    }
    url.searchParams.set("checkout[redirect_url]", redirectUrl);
  }

  return url.toString();
}
