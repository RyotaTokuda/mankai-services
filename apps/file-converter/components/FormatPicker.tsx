"use client";

import { OutputFormat } from "@/lib/tools/image-convert";

interface Props {
  outputFormat: OutputFormat;
  quality: number;
  maxWidth: string;
  onOutputFormat: (f: OutputFormat) => void;
  onQuality: (q: number) => void;
  onMaxWidth: (w: string) => void;
}

const FORMATS: { value: OutputFormat; label: string }[] = [
  { value: "image/jpeg", label: "JPG" },
  { value: "image/png", label: "PNG" },
  { value: "image/webp", label: "WebP" },
];

const PRESETS = [
  { label: "高品質", quality: 0.95, maxWidth: "" },
  { label: "バランス", quality: 0.85, maxWidth: "1920" },
  { label: "軽量", quality: 0.7, maxWidth: "1280" },
  { label: "LINE / SNS", quality: 0.75, maxWidth: "1080" },
];

export default function FormatPicker({
  outputFormat, quality, maxWidth,
  onOutputFormat, onQuality, onMaxWidth,
}: Props) {
  return (
    <div className="rounded-2xl bg-white p-5 space-y-5 shadow-sm">
      {/* 出力形式 */}
      <div>
        <p className="text-xs font-semibold uppercase tracking-widest text-gray-400 mb-2">出力形式</p>
        <div className="flex gap-2">
          {FORMATS.map((f) => (
            <button
              key={f.value}
              onClick={() => onOutputFormat(f.value)}
              className={`flex-1 rounded-xl py-2 text-sm font-semibold transition-colors ${
                outputFormat === f.value
                  ? "bg-emerald-600 text-white"
                  : "bg-gray-100 text-gray-600 hover:bg-gray-200"
              }`}
            >
              {f.label}
            </button>
          ))}
        </div>
      </div>

      {/* プリセット */}
      <div>
        <p className="text-xs font-semibold uppercase tracking-widest text-gray-400 mb-2">プリセット</p>
        <div className="flex flex-wrap gap-2">
          {PRESETS.map((p) => (
            <button
              key={p.label}
              onClick={() => { onQuality(p.quality); onMaxWidth(p.maxWidth); }}
              className="rounded-xl border border-gray-200 px-3 py-1.5 text-xs font-medium text-gray-600 hover:border-emerald-400 hover:text-emerald-700 transition-colors"
            >
              {p.label}
            </button>
          ))}
        </div>
      </div>

      {/* 詳細設定 */}
      <div className="grid grid-cols-2 gap-4">
        <div>
          <p className="text-xs font-semibold text-gray-400 mb-1">
            品質 <span className="text-gray-600">{Math.round(quality * 100)}%</span>
          </p>
          <input
            type="range" min="0.1" max="1" step="0.05"
            value={quality}
            onChange={(e) => onQuality(Number(e.target.value))}
            className="w-full accent-emerald-600"
          />
        </div>
        <div>
          <p className="text-xs font-semibold text-gray-400 mb-1">最大幅（px）</p>
          <input
            type="number"
            placeholder="制限なし"
            value={maxWidth}
            onChange={(e) => onMaxWidth(e.target.value)}
            onWheel={(e) => e.currentTarget.blur()}
            className="w-full rounded-xl border border-gray-200 px-3 py-1.5 text-sm text-gray-800 focus:outline-none focus:border-emerald-400"
          />
        </div>
      </div>
    </div>
  );
}
