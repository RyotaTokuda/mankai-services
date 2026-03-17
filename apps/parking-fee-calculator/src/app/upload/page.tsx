"use client";

import { useRef, useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import Image from "next/image";
import { ParkingRules } from "@mankai/parking-shared";

type AnalyzeState = "idle" | "loading" | "error";

export default function UploadPage() {
  const router = useRouter();
  const cameraInputRef = useRef<HTMLInputElement>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);
  const [imageFile, setImageFile] = useState<File | null>(null);
  const [pasteError, setPasteError] = useState<string | null>(null);
  const [analyzeState, setAnalyzeState] = useState<AnalyzeState>("idle");
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  // クライアント側でも上限チェック（サーバー側と同じ 10MB）
  const MAX_FILE_BYTES = 10 * 1024 * 1024;

  function setImage(url: string, file?: File) {
    if (file && file.size > MAX_FILE_BYTES) {
      setPasteError(`画像サイズが大きすぎます（上限10MB、現在約${Math.round(file.size / 1024 / 1024)}MB）`);
      return;
    }
    setPreviewUrl(url);
    setImageFile(file ?? null);
    setPasteError(null);
    setAnalyzeState("idle");
    setErrorMessage(null);
    // result ページに画像を渡すために sessionStorage に保存
    sessionStorage.setItem("uploadedImageUrl", url);
  }

  function handleFileChange(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file) return;
    setImage(URL.createObjectURL(file), file);
    // 同じファイルを再選択できるよう value をリセット
    e.target.value = "";
  }

  async function handlePasteButton() {
    try {
      const items = await navigator.clipboard.read();
      for (const item of items) {
        const imageType = item.types.find((t) => t.startsWith("image/"));
        if (imageType) {
          const blob = await item.getType(imageType);
          const file = new File([blob], "paste.png", { type: blob.type });
          setImage(URL.createObjectURL(blob), file);
          return;
        }
      }
      setPasteError("クリップボードに画像がありません");
    } catch {
      // HTTP 環境などで clipboard API が使えない場合
      setPasteError("ペーストできませんでした。Cmd+V をお試しください");
    }
  }

  // デスクトップ: Cmd+V でペースト
  useEffect(() => {
    function handlePaste(e: ClipboardEvent) {
      const items = e.clipboardData?.items;
      if (!items) return;
      for (const item of Array.from(items)) {
        if (item.type.startsWith("image/")) {
          const file = item.getAsFile();
          if (file) setImage(URL.createObjectURL(file), file);
          break;
        }
      }
    }
    document.addEventListener("paste", handlePaste);
    return () => document.removeEventListener("paste", handlePaste);
  }, []);

  async function handleAnalyze() {
    if (!imageFile && !previewUrl) return;

    setAnalyzeState("loading");
    setErrorMessage(null);

    try {
      let base64: string;
      let mimeType: string;

      if (imageFile) {
        // File オブジェクトがある場合（カメラ・ライブラリ・ペースト経由）
        mimeType = imageFile.type || "image/jpeg";
        base64 = await fileToBase64(imageFile);
      } else {
        // sessionStorage の URL（objectURL）からは再取得できないため、
        // ここには到達しないはずだがフォールバック
        setAnalyzeState("error");
        setErrorMessage("画像の取得に失敗しました。もう一度選択してください。");
        return;
      }

      const res = await fetch("/api/analyze", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ imageBase64: base64, mimeType }),
      });

      const data = await res.json();

      if (!res.ok || !data.rules) {
        setAnalyzeState("error");
        setErrorMessage(data.error ?? "解析に失敗しました");
        return;
      }

      // 解析結果を sessionStorage に保存して result ページへ
      const rules: ParkingRules = data.rules;
      sessionStorage.setItem("parkingRules", JSON.stringify(rules));
      router.push("/result");
    } catch {
      setAnalyzeState("error");
      setErrorMessage("ネットワークエラーが発生しました");
    }
  }

  function fileToBase64(file: File): Promise<string> {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = () => {
        const result = reader.result as string;
        // "data:image/jpeg;base64,..." の base64 部分のみ取り出す
        const base64 = result.split(",")[1];
        resolve(base64);
      };
      reader.onerror = reject;
      reader.readAsDataURL(file);
    });
  }

  return (
    <main className="flex min-h-screen flex-col items-center bg-gray-50 px-4 py-8">
      <div className="w-full max-w-md">
        <h1 className="mb-6 text-xl font-bold text-gray-900">看板を読み取る</h1>

        {/* プレビューエリア */}
        <div className="mb-5">
          {previewUrl ? (
            <>
              <Image
                src={previewUrl}
                alt="選択した看板画像"
                width={400}
                height={300}
                className="w-full rounded-2xl border border-gray-200 bg-white object-contain"
              />
              <button
                type="button"
                onClick={() => {
                  setPreviewUrl(null);
                  setImageFile(null);
                  setAnalyzeState("idle");
                  setErrorMessage(null);
                }}
                className="mt-2 text-sm text-gray-400 underline"
              >
                選び直す
              </button>
            </>
          ) : (
            <div className="flex h-44 w-full items-center justify-center rounded-2xl border-2 border-dashed border-gray-300 bg-white text-sm text-gray-400">
              ここに画像が表示されます
            </div>
          )}
        </div>

        {/* 3つの入力方法 */}
        <div className="space-y-3">
          <button
            type="button"
            onClick={() => cameraInputRef.current?.click()}
            className="flex h-14 w-full items-center gap-4 rounded-2xl border border-gray-200 bg-white px-5 text-base font-medium text-gray-800 active:bg-gray-50"
          >
            <span className="text-2xl">📷</span>
            <span>カメラで撮影する</span>
          </button>

          <button
            type="button"
            onClick={() => fileInputRef.current?.click()}
            className="flex h-14 w-full items-center gap-4 rounded-2xl border border-gray-200 bg-white px-5 text-base font-medium text-gray-800 active:bg-gray-50"
          >
            <span className="text-2xl">🖼️</span>
            <span>写真ライブラリから選ぶ</span>
          </button>

          <button
            type="button"
            onClick={handlePasteButton}
            className="flex h-14 w-full items-center gap-4 rounded-2xl border border-gray-200 bg-white px-5 text-base font-medium text-gray-800 active:bg-gray-50"
          >
            <span className="text-2xl">📋</span>
            <span>クリップボードからペースト</span>
          </button>

          {pasteError && (
            <p className="text-center text-sm text-red-500">{pasteError}</p>
          )}
        </div>

        {/* hidden inputs */}
        <input
          ref={cameraInputRef}
          type="file"
          accept="image/*"
          capture="environment"
          className="hidden"
          onChange={handleFileChange}
        />
        <input
          ref={fileInputRef}
          type="file"
          accept="image/*"
          className="hidden"
          onChange={handleFileChange}
        />

        {/* エラー表示 */}
        {analyzeState === "error" && errorMessage && (
          <div className="mt-4 rounded-xl bg-red-50 border border-red-200 px-4 py-3 text-sm text-red-800">
            {errorMessage}
          </div>
        )}

        {/* 解析ボタン */}
        <button
          type="button"
          onClick={handleAnalyze}
          disabled={!previewUrl || analyzeState === "loading"}
          className="mt-8 flex h-14 w-full items-center justify-center rounded-2xl bg-blue-600 text-lg font-semibold text-white disabled:opacity-40 active:bg-blue-700"
        >
          {analyzeState === "loading" ? (
            <span className="flex items-center gap-2">
              <svg className="animate-spin h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
              </svg>
              解析中...
            </span>
          ) : (
            "解析する"
          )}
        </button>
      </div>
    </main>
  );
}
