"use client";

import { formatBytes } from "@/lib/imageConverter";

interface FileItem {
  file: File;
  status: "waiting" | "converting" | "done" | "error";
  result?: { blob: Blob; filename: string };
  error?: string;
  progress?: number;
}

interface Props {
  items: FileItem[];
  onConvert: () => void;
  onClear: () => void;
  isConverting: boolean;
}

const STATUS_LABEL: Record<FileItem["status"], string> = {
  waiting: "待機中",
  converting: "変換中...",
  done: "完了",
  error: "エラー",
};

const STATUS_COLOR: Record<FileItem["status"], string> = {
  waiting: "text-gray-400",
  converting: "text-blue-500",
  done: "text-emerald-600",
  error: "text-red-500",
};

export default function ConvertPanel({ items, onConvert, onClear, isConverting }: Props) {
  if (items.length === 0) return null;

  const allDone = items.every((i) => i.status === "done" || i.status === "error");
  const hasWaiting = items.some((i) => i.status === "waiting");
  const convertDisabled = isConverting || !hasWaiting;

  // 変換ボタン付近に表示する警告
  const warning = (() => {
    if (isConverting) return null;
    if (!hasWaiting && allDone) {
      const errorCount = items.filter((i) => i.status === "error").length;
      if (errorCount > 0 && errorCount === items.length) {
        return "すべてのファイルでエラーが発生しました。クリアして再試行してください。";
      }
      return "変換済みです。クリアして新しいファイルを追加してください。";
    }
    if (!hasWaiting && items.length > 0) {
      return "変換待ちのファイルがありません。";
    }
    return null;
  })();

  function downloadAll() {
    items.forEach((item) => {
      if (item.result) {
        const url = URL.createObjectURL(item.result.blob);
        const a = document.createElement("a");
        a.href = url;
        a.download = item.result.filename;
        a.click();
        URL.revokeObjectURL(url);
      }
    });
  }

  return (
    <div className="rounded-2xl bg-white p-5 space-y-4 shadow-sm">
      <div className="flex items-center justify-between">
        <p className="text-xs font-semibold uppercase tracking-widest text-gray-400">
          ファイル {items.length}件
        </p>
        <button onClick={onClear} className="text-xs text-gray-400 hover:text-gray-600">
          クリア
        </button>
      </div>

      {/* ファイル一覧 */}
      <ul className="space-y-2">
        {items.map((item, i) => (
          <li key={i} className="flex items-center justify-between gap-3 rounded-xl bg-gray-50 px-4 py-3">
            <div className="flex-1 min-w-0">
              <p className="text-sm font-medium text-gray-800 truncate">{item.file.name}</p>
              <p className="text-xs text-gray-400">
                {formatBytes(item.file.size)}
                {item.result && (
                  <span className="ml-2 text-emerald-600">
                    → {formatBytes(item.result.blob.size)}
                  </span>
                )}
              </p>
              {item.status === "converting" && item.progress !== undefined && (
                <div className="mt-1.5 h-1 w-full rounded-full bg-gray-200 overflow-hidden">
                  <div
                    className="h-full bg-blue-500 rounded-full transition-all duration-300"
                    style={{ width: `${item.progress}%` }}
                  />
                </div>
              )}
              {item.error && <p className="text-xs text-red-500 mt-0.5">{item.error}</p>}
            </div>
            <div className="flex items-center gap-2 shrink-0">
              <span className={`text-xs font-medium ${STATUS_COLOR[item.status]}`}>
                {STATUS_LABEL[item.status]}
              </span>
              {item.result && (
                <a
                  href={URL.createObjectURL(item.result.blob)}
                  download={item.result.filename}
                  className="rounded-lg bg-emerald-50 px-2.5 py-1 text-xs font-semibold text-emerald-700 hover:bg-emerald-100"
                  onClick={(e) => {
                    const url = URL.createObjectURL(item.result!.blob);
                    (e.currentTarget as HTMLAnchorElement).href = url;
                    setTimeout(() => URL.revokeObjectURL(url), 1000);
                  }}
                >
                  ↓
                </a>
              )}
            </div>
          </li>
        ))}
      </ul>

      {/* アクションボタン */}
      <div className="space-y-2">
        <div className="flex gap-2">
          {/* 変換ボタン（常に表示、条件でグレイアウト） */}
          <button
            onClick={onConvert}
            disabled={convertDisabled}
            className={`flex-1 h-12 rounded-2xl text-sm font-bold transition-colors ${
              convertDisabled
                ? "bg-gray-100 text-gray-400 cursor-not-allowed"
                : "bg-emerald-600 text-white hover:bg-emerald-700"
            }`}
          >
            {isConverting ? "変換中..." : "変換する"}
          </button>

          {/* 一括ダウンロード（完了時のみ） */}
          {allDone && items.some((i) => i.result) && (
            <button
              onClick={downloadAll}
              className="flex-1 h-12 rounded-2xl bg-emerald-600 text-white text-sm font-bold hover:bg-emerald-700 transition-colors"
            >
              すべてダウンロード
            </button>
          )}
        </div>

        {/* 警告テキスト */}
        {warning && (
          <p className="text-xs text-amber-600 text-center">⚠️ {warning}</p>
        )}
      </div>
    </div>
  );
}
