"use client";

import { useState } from "react";
import DropZone from "@/components/DropZone";
import FormatPicker from "@/components/FormatPicker";
import VideoFormatPicker, { VideoConvertOptions } from "@/components/VideoFormatPicker";
import ConvertPanel from "@/components/ConvertPanel";
import { convertImage, OutputFormat } from "@/lib/tools/image-convert";
import { convertVideo, preloadFFmpeg } from "@/lib/tools/video-convert";
import { checkBrowserCompat } from "@/lib/browser-compat";
import BrowserWarning from "@/components/BrowserWarning";
import AuthButton from "@mankai/auth/button";

type Mode = "image" | "video";

interface FileItem {
  file: File;
  status: "waiting" | "converting" | "done" | "error";
  result?: { blob: Blob; filename: string };
  error?: string;
  progress?: number;
}

const IMAGE_ACCEPT = ".jpg,.jpeg,.png,.webp,.heic,.heif,image/jpeg,image/png,image/webp,image/heic,image/heif";
const VIDEO_ACCEPT = ".mp4,.mov,.avi,.mkv,video/mp4,video/quicktime,video/x-msvideo,video/x-matroska";

const DEFAULT_VIDEO_OPTIONS: VideoConvertOptions = {
  outputFormat: "mp4",
  videoBitrate: "1500k",
  maxWidth: "1280",
  fps: "15",
};

export default function Home() {
  const [mode, setMode] = useState<Mode>("image");
  const compat = typeof window !== "undefined" ? checkBrowserCompat() : { imageSupported: true, videoSupported: true };
  const [items, setItems] = useState<FileItem[]>([]);
  const [isConverting, setIsConverting] = useState(false);

  const [outputFormat, setOutputFormat] = useState<OutputFormat>("image/jpeg");
  const [quality, setQuality] = useState(0.85);
  const [maxWidth, setMaxWidth] = useState("");

  const [videoOptions, setVideoOptions] = useState<VideoConvertOptions>(DEFAULT_VIDEO_OPTIONS);

  function handleModeChange(next: Mode) {
    if (next === mode) return;
    setMode(next);
    setItems([]);
    if (next === "video") preloadFFmpeg();
  }

  function handleFiles(files: File[]) {
    const newItems = files.map((file) => {
      if (!isCompatible(file, mode)) {
        return {
          file,
          status: "error" as const,
          error: mode === "image"
            ? "非対応形式です（HEIC / WebP / JPG / PNG のみ対応）"
            : "非対応形式です（MP4 / MOV / AVI / MKV のみ対応）",
        };
      }
      return { file, status: "waiting" as const };
    });
    setItems((prev) => [...prev, ...newItems]);
  }

  function isCompatible(file: File, currentMode: Mode): boolean {
    if (currentMode === "image") {
      return (
        file.type.startsWith("image/") ||
        /\.(jpg|jpeg|png|webp|heic|heif)$/i.test(file.name)
      );
    }
    return (
      file.type.startsWith("video/") ||
      /\.(mp4|mov|avi|mkv)$/i.test(file.name)
    );
  }

  async function handleConvert() {
    setIsConverting(true);

    for (let i = 0; i < items.length; i++) {
      if (items[i].status !== "waiting") continue;

      setItems((prev) =>
        prev.map((item, idx) => idx === i ? { ...item, status: "converting", progress: mode === "video" ? 0 : undefined } : item)
      );

      try {
        let result: { blob: Blob; filename: string };

        if (mode === "image") {
          result = await convertImage(items[i].file, {
            outputFormat,
            quality,
            maxWidth: maxWidth ? Number(maxWidth) : undefined,
          });
        } else {
          result = await convertVideo(
            items[i].file,
            videoOptions,
            (progress) => {
              setItems((prev) =>
                prev.map((item, idx) => idx === i ? { ...item, progress } : item)
              );
            },
          );
        }

        setItems((prev) =>
          prev.map((item, idx) => idx === i ? { ...item, status: "done", result, progress: undefined } : item)
        );
      } catch (err) {
        const message = err instanceof Error ? err.message : "変換に失敗しました";
        setItems((prev) =>
          prev.map((item, idx) => idx === i ? { ...item, status: "error", error: message, progress: undefined } : item)
        );
      }
    }

    setIsConverting(false);
  }

  function handleClear() {
    setItems([]);
  }

  return (
    <div className="min-h-screen flex flex-col">
      <header className="border-b border-gray-200 bg-white px-6 py-4">
        <div className="max-w-2xl mx-auto flex items-center justify-between">
          <div>
            <h1 className="text-base font-bold text-gray-900">🔄 ローカルファイル変換</h1>
            <p className="text-xs text-gray-400">by Mankai Software</p>
          </div>
          <div className="flex items-center gap-2">
            <div className="hidden sm:flex items-center gap-1.5 rounded-full bg-emerald-50 px-3 py-1.5">
              <span className="h-1.5 w-1.5 rounded-full bg-emerald-500"></span>
              <span className="text-xs font-semibold text-emerald-700">完全ローカル処理</span>
            </div>
            <AuthButton />
          </div>
        </div>
      </header>

      <main className="flex-1 px-4 py-8">
        <div className="max-w-2xl mx-auto space-y-4">
          <BrowserWarning />

          <div className="rounded-2xl bg-emerald-50 border border-emerald-100 px-5 py-4">
            <p className="text-sm text-emerald-800 leading-relaxed">
              <strong>ファイルはサーバーに送られません。</strong>
              すべての変換処理はあなたのブラウザ内だけで行われます。
              個人情報や機密ファイルも安心してご利用いただけます。
            </p>
          </div>

          <div className="flex gap-2 rounded-2xl bg-gray-100 p-1">
            <button
              onClick={() => handleModeChange("image")}
              className={`flex-1 rounded-xl py-2 text-sm font-semibold transition-colors ${
                mode === "image"
                  ? "bg-white text-gray-900 shadow-sm"
                  : "text-gray-500 hover:text-gray-700"
              }`}
            >
              🖼 画像変換
            </button>
            <button
              onClick={() => compat.videoSupported && handleModeChange("video")}
              disabled={!compat.videoSupported}
              title={!compat.videoSupported ? "このブラウザは動画変換に対応していません" : undefined}
              className={`flex-1 rounded-xl py-2 text-sm font-semibold transition-colors ${
                mode === "video"
                  ? "bg-white text-gray-900 shadow-sm"
                  : compat.videoSupported
                  ? "text-gray-500 hover:text-gray-700"
                  : "text-gray-300 cursor-not-allowed"
              }`}
            >
              🎬 動画変換
              {!compat.videoSupported && (
                <span className="block text-[10px] font-normal">非対応</span>
              )}
            </button>
          </div>

          <DropZone
            onFiles={handleFiles}
            accept={mode === "image" ? IMAGE_ACCEPT : VIDEO_ACCEPT}
            disabled={isConverting}
            items={items}
            mode={mode}
          />

          {mode === "image" ? (
            <FormatPicker
              outputFormat={outputFormat}
              quality={quality}
              maxWidth={maxWidth}
              onOutputFormat={setOutputFormat}
              onQuality={setQuality}
              onMaxWidth={setMaxWidth}
            />
          ) : (
            <VideoFormatPicker options={videoOptions} onChange={setVideoOptions} />
          )}

          <ConvertPanel
            items={items}
            onConvert={handleConvert}
            onClear={handleClear}
            isConverting={isConverting}
          />
        </div>
      </main>

      <footer className="border-t border-gray-100 px-6 py-6 text-center text-xs text-gray-400">
        <a href="https://mankai-software.vercel.app" className="hover:text-gray-600">
          © {new Date().getFullYear()} Mankai Software
        </a>
        {" · "}
        <a href="https://mankai-software.vercel.app/privacy" className="hover:text-gray-600">
          プライバシーポリシー
        </a>
        {" · "}
        <a href="https://mankai-software.vercel.app/terms" className="hover:text-gray-600">
          利用規約
        </a>
      </footer>
    </div>
  );
}
