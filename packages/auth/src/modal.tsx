"use client";

import { useEffect, useRef, useState } from "react";
import { createClient } from "./client";

interface Props {
  onClose: () => void;
}

type Step = "input" | "otp_sent";

export default function AuthModal({ onClose }: Props) {
  const [step, setStep] = useState<Step>("input");
  const [email, setEmail] = useState("");
  const [otp, setOtp] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const overlayRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function onKeyDown(e: KeyboardEvent) {
      if (e.key === "Escape") onClose();
    }
    window.addEventListener("keydown", onKeyDown);
    return () => window.removeEventListener("keydown", onKeyDown);
  }, [onClose]);

  useEffect(() => {
    document.body.style.overflow = "hidden";
    return () => {
      document.body.style.overflow = "";
    };
  }, []);

  async function handleGoogleLogin() {
    setLoading(true);
    setError(null);
    const supabase = createClient();
    const { error } = await supabase.auth.signInWithOAuth({
      provider: "google",
      options: {
        redirectTo: `${window.location.origin}/auth/callback`,
        queryParams: { access_type: "offline", prompt: "consent" },
      },
    });
    if (error) {
      setError("Googleログインに失敗しました。もう一度お試しください。");
      setLoading(false);
    }
  }

  async function handleSendOtp(e: React.FormEvent) {
    e.preventDefault();
    if (!email.trim()) return;
    setLoading(true);
    setError(null);
    const supabase = createClient();
    const { error } = await supabase.auth.signInWithOtp({
      email: email.trim().toLowerCase(),
      options: { shouldCreateUser: true },
    });
    if (error) {
      setError("メールの送信に失敗しました。アドレスをご確認ください。");
    } else {
      setStep("otp_sent");
    }
    setLoading(false);
  }

  async function handleVerifyOtp(e: React.FormEvent) {
    e.preventDefault();
    if (otp.length !== 6) return;
    setLoading(true);
    setError(null);
    const supabase = createClient();
    const { error } = await supabase.auth.verifyOtp({
      email: email.trim().toLowerCase(),
      token: otp.trim(),
      type: "email",
    });
    if (error) {
      setError("コードが正しくないか、有効期限が切れています。");
    } else {
      onClose();
    }
    setLoading(false);
  }

  return (
    <div
      ref={overlayRef}
      className="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-black/40"
      onClick={(e) => {
        if (e.target === overlayRef.current) onClose();
      }}
    >
      <div className="w-full sm:max-w-sm rounded-t-2xl sm:rounded-2xl bg-white shadow-xl max-h-[85vh] overflow-y-auto">
        <div className="flex items-center justify-between border-b border-gray-100 px-5 py-3">
          <h2 className="text-sm font-bold text-gray-900">
            ログイン / 新規登録
          </h2>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600 transition-colors text-lg leading-none"
            aria-label="閉じる"
          >
            ✕
          </button>
        </div>

        <div className="px-5 py-4 space-y-3">
          {step === "input" && (
            <>
              <button
                onClick={handleGoogleLogin}
                disabled={loading}
                className="flex w-full items-center justify-center gap-3 rounded-xl border border-gray-200 bg-white px-4 py-2.5 text-sm font-semibold text-gray-700 shadow-sm hover:bg-gray-50 transition-colors disabled:opacity-50"
              >
                <GoogleIcon />
                Googleでログイン
              </button>

              <div className="relative flex items-center gap-3">
                <hr className="flex-1 border-gray-200" />
                <span className="text-xs text-gray-400">または</span>
                <hr className="flex-1 border-gray-200" />
              </div>

              <form onSubmit={handleSendOtp} className="space-y-3">
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="メールアドレス"
                  required
                  autoComplete="email"
                  className="w-full rounded-xl border border-gray-200 px-4 py-2.5 text-sm outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-100 transition-all"
                />
                <button
                  type="submit"
                  disabled={loading || !email.trim()}
                  className="w-full rounded-xl bg-emerald-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-emerald-700 transition-colors disabled:opacity-50"
                >
                  {loading ? "送信中..." : "確認コードを送る"}
                </button>
              </form>
            </>
          )}

          {step === "otp_sent" && (
            <>
              <p className="text-sm text-gray-600 text-center leading-relaxed">
                <span className="font-semibold">{email}</span> に
                <br />
                6桁の確認コードを送信しました
              </p>

              <form onSubmit={handleVerifyOtp} className="space-y-3">
                <input
                  type="text"
                  value={otp}
                  onChange={(e) =>
                    setOtp(e.target.value.replace(/\D/g, "").slice(0, 6))
                  }
                  placeholder="123456"
                  inputMode="numeric"
                  autoComplete="one-time-code"
                  maxLength={6}
                  required
                  autoFocus
                  className="w-full rounded-xl border border-gray-200 px-4 py-2.5 text-center text-xl font-mono tracking-[0.4em] outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-100 transition-all"
                />
                <button
                  type="submit"
                  disabled={loading || otp.length !== 6}
                  className="w-full rounded-xl bg-emerald-600 px-4 py-2.5 text-sm font-semibold text-white hover:bg-emerald-700 transition-colors disabled:opacity-50"
                >
                  {loading ? "確認中..." : "ログイン"}
                </button>
              </form>

              <button
                onClick={() => {
                  setStep("input");
                  setOtp("");
                  setError(null);
                }}
                className="w-full text-center text-sm text-gray-500 hover:text-gray-700 transition-colors"
              >
                別のメールアドレスを使う
              </button>
            </>
          )}

          {error && (
            <p className="rounded-xl bg-red-50 px-4 py-2.5 text-sm text-red-700">
              {error}
            </p>
          )}

          <p className="text-center text-[11px] text-gray-400 leading-relaxed">
            続けることで{" "}
            <a href="/privacy" className="underline hover:text-gray-600">
              プライバシーポリシー
            </a>
            と{" "}
            <a href="/terms" className="underline hover:text-gray-600">
              利用規約
            </a>
            に同意します
          </p>
        </div>
      </div>
    </div>
  );
}

function GoogleIcon() {
  return (
    <svg
      width="18"
      height="18"
      viewBox="0 0 18 18"
      xmlns="http://www.w3.org/2000/svg"
      aria-hidden="true"
    >
      <path
        d="M17.64 9.205c0-.639-.057-1.252-.164-1.841H9v3.481h4.844a4.14 4.14 0 0 1-1.796 2.716v2.259h2.908c1.702-1.567 2.684-3.875 2.684-6.615z"
        fill="#4285F4"
      />
      <path
        d="M9 18c2.43 0 4.467-.806 5.956-2.18l-2.908-2.259c-.806.54-1.837.86-3.048.86-2.344 0-4.328-1.584-5.036-3.711H.957v2.332A8.997 8.997 0 0 0 9 18z"
        fill="#34A853"
      />
      <path
        d="M3.964 10.71A5.41 5.41 0 0 1 3.682 9c0-.593.102-1.17.282-1.71V4.958H.957A8.996 8.996 0 0 0 0 9c0 1.452.348 2.827.957 4.042l3.007-2.332z"
        fill="#FBBC05"
      />
      <path
        d="M9 3.58c1.321 0 2.508.454 3.44 1.345l2.582-2.58C13.463.891 11.426 0 9 0A8.997 8.997 0 0 0 .957 4.958L3.964 6.29C4.672 4.163 6.656 3.58 9 3.58z"
        fill="#EA4335"
      />
    </svg>
  );
}
