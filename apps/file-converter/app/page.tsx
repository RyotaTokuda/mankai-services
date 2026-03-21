/**
 * ルートページ
 * (marketing) グループの page.tsx がトップページとして機能するが、
 * Next.js の Route Groups は URL に影響しないため、
 * app/page.tsx がルート "/" に対応する。
 * (marketing)/page.tsx を直接使うため、ここからエクスポートする。
 */
export { default } from "./(marketing)/page";
