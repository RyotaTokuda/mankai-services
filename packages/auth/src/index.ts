// 便宜上の re-export（直接 @mankai/auth/<module> を使うことを推奨）
export { createClient as createBrowserClient } from "./client";
export { AuthProvider, useAuth } from "./context";
