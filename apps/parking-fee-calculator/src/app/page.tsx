import Link from "next/link";

export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center bg-gray-50 px-4">
      <div className="w-full max-w-md">
        <div className="mb-10 text-center">
          <h1 className="text-3xl font-bold text-gray-900">駐車料金リーダー</h1>
          <p className="mt-3 text-base text-gray-500">
            看板を撮影するだけで、料金ルールをわかりやすく整理します
          </p>
        </div>

        <Link
          href="/upload"
          className="flex h-14 w-full items-center justify-center rounded-2xl bg-blue-600 text-lg font-semibold text-white active:bg-blue-700"
        >
          看板を撮影・選択する
        </Link>

        <p className="mt-6 text-center text-sm text-gray-400">
          現地で看板を見ながらすぐ使えます
        </p>
      </div>
    </main>
  );
}
