import { updateSession } from "@mankai/auth/middleware";
import type { NextRequest } from "next/server";

export async function middleware(request: NextRequest) {
  return updateSession(request);
}

// Next.js はビルド時にこのオブジェクトを静的解析するため、
// パッケージから import せず各アプリで直接定義する必要がある
export const config = {
  matcher: [
    "/((?!_next/static|_next/image|favicon\\.ico|sw\\.js|icon\\.svg|offline\\.html|manifest\\.webmanifest).*)",
  ],
};
