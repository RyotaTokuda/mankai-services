"use client";

import { useRef, useState, useEffect, DragEvent, ChangeEvent } from "react";

interface FileItem {
  file: File;
  status: string;
}

interface Preview {
  key: string;
  name: string;
  url: string | null;
}

interface Props {
  onFiles: (files: File[]) => void;
  accept?: string;
  disabled?: boolean;
  items?: FileItem[];
  mode?: "image" | "video";
}

const ACCEPT_TEXT: Record<"image" | "video", string> = {
  image: "HEIC / WebP / JPG / PNG 対応",
  video: "MP4 / MOV / AVI / MKV 対応",
};

function getFileIcon(filename: string): string {
  const ext = filename.split(".").pop()?.toLowerCase() ?? "";
  if (["mp4", "mov", "avi", "mkv", "webm"].includes(ext)) return "🎬";
  if (["heic", "heif"].includes(ext)) return "📷";
  return "📄";
}

function canPreview(file: File): boolean {
  return (
    file.type.startsWith("image/") &&
    !file.type.includes("heic") &&
    !file.type.includes("heif")
  );
}

export default function DropZone({
  onFiles,
  accept,
  disabled,
  items = [],
  mode = "image",
}: Props) {
  const inputRef = useRef<HTMLInputElement>(null);
  const [isDragging, setIsDragging] = useState(false);
  const [previews, setPreviews] = useState<Preview[]>([]);

  // Re-generate previews only when the file set changes (not on status changes)
  const fileKeys = items
    .map((i) => `${i.file.name}-${i.file.size}-${i.file.lastModified}`)
    .join("|");

  useEffect(() => {
    const created: Preview[] = items.map((item) => {
      const key = `${item.file.name}-${item.file.size}-${item.file.lastModified}`;
      const url = canPreview(item.file) ? URL.createObjectURL(item.file) : null;
      return { key, name: item.file.name, url };
    });
    setPreviews(created);
    return () => {
      created.forEach((p) => { if (p.url) URL.revokeObjectURL(p.url); });
    };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [fileKeys]);

  function handleDrop(e: DragEvent) {
    e.preventDefault();
    setIsDragging(false);
    if (disabled) return;
    const files = Array.from(e.dataTransfer.files);
    if (files.length) onFiles(files);
  }

  function handleChange(e: ChangeEvent<HTMLInputElement>) {
    const files = Array.from(e.target.files ?? []);
    if (files.length) onFiles(files);
    e.target.value = "";
  }

  const borderClass = isDragging
    ? "border-emerald-400 bg-emerald-50"
    : "border-gray-200 bg-white";

  return (
    <div
      onDragOver={(e) => { e.preventDefault(); if (!disabled) setIsDragging(true); }}
      onDragLeave={() => setIsDragging(false)}
      onDrop={handleDrop}
      className={`rounded-2xl border-2 border-dashed transition-colors ${borderClass} ${disabled ? "opacity-50" : ""}`}
    >
      {items.length > 0 ? (
        /* サムネイルグリッド */
        <div className="p-4">
          <div className="flex flex-wrap gap-3">
            {previews.map((p) => (
              <div key={p.key} className="flex flex-col items-center gap-1" style={{ width: 72 }}>
                <div className="w-[72px] h-[72px] rounded-xl overflow-hidden bg-gray-100 flex items-center justify-center border border-gray-200 shrink-0">
                  {p.url ? (
                    <img src={p.url} alt={p.name} className="w-full h-full object-cover" />
                  ) : (
                    <span className="text-2xl">{getFileIcon(p.name)}</span>
                  )}
                </div>
                <p className="text-[10px] text-gray-500 truncate w-full text-center leading-tight">
                  {p.name.replace(/\.[^.]+$/, "")}
                </p>
              </div>
            ))}

            {/* さらに追加ボタン */}
            <button
              onClick={() => !disabled && inputRef.current?.click()}
              disabled={disabled}
              className="w-[72px] h-[72px] rounded-xl border-2 border-dashed border-gray-200 flex flex-col items-center justify-center gap-0.5 text-gray-400 hover:border-emerald-400 hover:text-emerald-500 hover:bg-emerald-50 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
            >
              <span className="text-xl leading-none">＋</span>
              <span className="text-[10px]">追加</span>
            </button>
          </div>
        </div>
      ) : (
        /* 初期ドロップUI */
        <div
          onClick={() => !disabled && inputRef.current?.click()}
          className="flex flex-col items-center justify-center gap-3 px-6 py-12 cursor-pointer select-none"
        >
          <span className="text-4xl">📂</span>
          <div className="text-center">
            <p className="font-semibold text-gray-800">ファイルをドロップ</p>
            <p className="text-sm text-gray-400 mt-0.5">またはクリックして選択</p>
          </div>
          <p className="text-xs text-gray-400">{ACCEPT_TEXT[mode]}</p>
        </div>
      )}

      <input
        ref={inputRef}
        type="file"
        multiple
        accept={accept}
        onChange={handleChange}
        className="hidden"
      />
    </div>
  );
}
