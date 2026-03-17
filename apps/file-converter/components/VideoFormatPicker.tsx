"use client";

import { VideoConvertOptions, VideoOutputFormat } from "@/lib/videoConverter";

export type { VideoConvertOptions };

interface Props {
  options: VideoConvertOptions;
  onChange: (o: VideoConvertOptions) => void;
}

const FORMATS: { value: VideoOutputFormat; label: string; desc: string }[] = [
  { value: "mp4", label: "MP4", desc: "汎用・高互換" },
  { value: "gif", label: "GIF", desc: "アニメ・SNS用" },
];

const PRESETS: { label: string; options: VideoConvertOptions }[] = [
  { label: "高品質",    options: { outputFormat: "mp4", videoBitrate: "4000k", maxWidth: "",     fps: "" } },
  { label: "バランス",  options: { outputFormat: "mp4", videoBitrate: "1500k", maxWidth: "1280", fps: "" } },
  { label: "軽量",      options: { outputFormat: "mp4", videoBitrate: "800k",  maxWidth: "854",  fps: "" } },
  { label: "GIFアニメ", options: { outputFormat: "gif", videoBitrate: "",      maxWidth: "480",  fps: "15" } },
];

const BITRATE_OPTIONS = [
  { value: "4000k", label: "高品質 (4 Mbps)" },
  { value: "2000k", label: "標準 (2 Mbps)" },
  { value: "1500k", label: "バランス (1.5 Mbps)" },
  { value: "800k",  label: "軽量 (800 Kbps)" },
  { value: "500k",  label: "超軽量 (500 Kbps)" },
  { value: "",      label: "自動 (CRF 23)" },
];

export default function VideoFormatPicker({ options, onChange }: Props) {
  const set = (patch: Partial<VideoConvertOptions>) =>
    onChange({ ...options, ...patch });

  return (
    <div className="rounded-2xl bg-white p-5 space-y-5 shadow-sm">
      {/* 出力形式 */}
      <div>
        <p className="text-xs font-semibold uppercase tracking-widest text-gray-400 mb-2">出力形式</p>
        <div className="flex gap-2">
          {FORMATS.map((f) => (
            <button
              key={f.value}
              onClick={() => set({ outputFormat: f.value })}
              className={`flex-1 rounded-xl py-2 text-sm font-semibold transition-colors ${
                options.outputFormat === f.value
                  ? "bg-emerald-600 text-white"
                  : "bg-gray-100 text-gray-600 hover:bg-gray-200"
              }`}
            >
              <span>{f.label}</span>
              <span className="block text-[10px] font-normal opacity-70">{f.desc}</span>
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
              onClick={() => onChange(p.options)}
              className="rounded-xl border border-gray-200 px-3 py-1.5 text-xs font-medium text-gray-600 hover:border-emerald-400 hover:text-emerald-700 transition-colors"
            >
              {p.label}
            </button>
          ))}
        </div>
      </div>

      {/* 詳細設定 */}
      {options.outputFormat === "mp4" && (
        <div className="grid grid-cols-2 gap-4">
          <div>
            <p className="text-xs font-semibold text-gray-400 mb-1">ビットレート</p>
            <select
              value={options.videoBitrate}
              onChange={(e) => set({ videoBitrate: e.target.value })}
              className="w-full rounded-xl border border-gray-200 px-3 py-1.5 text-sm text-gray-800 focus:outline-none focus:border-emerald-400"
            >
              {BITRATE_OPTIONS.map((o) => (
                <option key={o.value} value={o.value}>{o.label}</option>
              ))}
            </select>
          </div>
          <div>
            <p className="text-xs font-semibold text-gray-400 mb-1">最大幅（px）</p>
            <input
              type="number"
              placeholder="制限なし"
              value={options.maxWidth}
              onChange={(e) => set({ maxWidth: e.target.value })}
              onWheel={(e) => e.currentTarget.blur()}
              className="w-full rounded-xl border border-gray-200 px-3 py-1.5 text-sm text-gray-800 focus:outline-none focus:border-emerald-400"
            />
          </div>
        </div>
      )}

      {options.outputFormat === "gif" && (
        <div className="grid grid-cols-2 gap-4">
          <div>
            <p className="text-xs font-semibold text-gray-400 mb-1">
              FPS <span className="text-gray-600">{options.fps || "15"}</span>
            </p>
            <input
              type="range" min="5" max="30" step="5"
              value={options.fps || "15"}
              onChange={(e) => set({ fps: e.target.value })}
              className="w-full accent-emerald-600"
            />
          </div>
          <div>
            <p className="text-xs font-semibold text-gray-400 mb-1">最大幅（px）</p>
            <input
              type="number"
              placeholder="480"
              value={options.maxWidth}
              onChange={(e) => set({ maxWidth: e.target.value })}
              onWheel={(e) => e.currentTarget.blur()}
              className="w-full rounded-xl border border-gray-200 px-3 py-1.5 text-sm text-gray-800 focus:outline-none focus:border-emerald-400"
            />
          </div>
        </div>
      )}

      {/* 注意書き */}
      <p className="text-xs text-gray-400 leading-relaxed">
        ⚠️ 初回変換時に ffmpeg エンジン（約30MB）を読み込みます。動画サイズは100MB以下・短尺（目安5分以内）を推奨します。
      </p>
    </div>
  );
}
