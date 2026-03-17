"use client";

import { useState } from "react";
import { useAuth } from "./context";
import AuthModal from "./modal";

export default function AuthButton() {
  const { user, loading, signOut } = useAuth();
  const [showModal, setShowModal] = useState(false);
  const [showMenu, setShowMenu] = useState(false);

  if (loading) {
    return <div className="h-8 w-16 rounded-full bg-gray-100 animate-pulse" />;
  }

  if (user) {
    const initial =
      (user.user_metadata?.full_name as string | undefined)?.[0]?.toUpperCase() ??
      user.id[0].toUpperCase();

    return (
      <div className="relative">
        <button
          onClick={() => setShowMenu((v) => !v)}
          className="flex h-8 w-8 items-center justify-center rounded-full bg-emerald-600 text-xs font-bold text-white hover:bg-emerald-700 transition-colors"
          aria-label="アカウントメニュー"
          aria-expanded={showMenu}
        >
          {initial}
        </button>

        {showMenu && (
          <>
            <div
              className="fixed inset-0 z-30"
              onClick={() => setShowMenu(false)}
              aria-hidden="true"
            />
            <div className="absolute right-0 z-40 mt-2 w-48 rounded-xl border border-gray-100 bg-white py-1 shadow-lg">
              <div className="border-b border-gray-100 px-4 py-2">
                <p className="text-xs font-semibold text-gray-900 truncate">
                  {(user.user_metadata?.full_name as string | undefined) ??
                    "ログイン中"}
                </p>
              </div>
              <button
                onClick={async () => {
                  await signOut();
                  setShowMenu(false);
                }}
                className="w-full px-4 py-2 text-left text-sm text-gray-600 hover:bg-gray-50 transition-colors"
              >
                ログアウト
              </button>
            </div>
          </>
        )}
      </div>
    );
  }

  return (
    <>
      <button
        onClick={() => setShowModal(true)}
        className="rounded-full bg-emerald-600 px-4 py-1.5 text-xs font-semibold text-white hover:bg-emerald-700 transition-colors"
      >
        ログイン
      </button>
      {showModal && <AuthModal onClose={() => setShowModal(false)} />}
    </>
  );
}
