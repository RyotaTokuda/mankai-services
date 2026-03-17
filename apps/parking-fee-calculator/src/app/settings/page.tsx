export default function SettingsPage() {
  return (
    <main className="flex min-h-screen flex-col bg-slate-50">
      <header className="px-5 pt-14 pb-6">
        <h1 className="text-2xl font-bold text-slate-900">設定</h1>
      </header>

      <div className="px-4 space-y-4">
        {/* アカウント */}
        <section>
          <p className="mb-2 text-xs font-semibold uppercase tracking-widest text-slate-400 px-1">
            アカウント
          </p>
          <div className="rounded-2xl bg-white border border-slate-100 overflow-hidden divide-y divide-slate-100">
            <button className="flex w-full items-center justify-between px-4 py-3 active:bg-slate-50">
              <span className="text-sm font-medium text-slate-800">Googleでログイン</span>
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                <path d="M9 18l6-6-6-6" stroke="#94A3B8" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
              </svg>
            </button>
          </div>
        </section>

        {/* サポート */}
        <section>
          <p className="mb-2 text-xs font-semibold uppercase tracking-widest text-slate-400 px-1">
            サポート
          </p>
          <div className="rounded-2xl bg-white border border-slate-100 overflow-hidden divide-y divide-slate-100">
            {[
              { label: "フィードバックを送る", href: null },
              { label: "プライバシーポリシー", href: null },
              { label: "利用規約", href: null },
            ].map((item) => (
              <button
                key={item.label}
                className="flex w-full items-center justify-between px-4 py-3 active:bg-slate-50"
              >
                <span className="text-sm font-medium text-slate-800">{item.label}</span>
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                  <path d="M9 18l6-6-6-6" stroke="#94A3B8" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
                </svg>
              </button>
            ))}
          </div>
        </section>

        {/* アプリ情報 */}
        <section>
          <p className="mb-2 text-xs font-semibold uppercase tracking-widest text-slate-400 px-1">
            アプリ情報
          </p>
          <div className="rounded-2xl bg-white border border-slate-100 overflow-hidden divide-y divide-slate-100">
            <div className="flex items-center justify-between px-4 py-3">
              <span className="text-sm font-medium text-slate-800">バージョン</span>
              <span className="text-sm text-slate-400">0.1.0</span>
            </div>
          </div>
        </section>
      </div>
    </main>
  );
}
