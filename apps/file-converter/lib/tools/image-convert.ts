"use client";

export type OutputFormat = "image/jpeg" | "image/png" | "image/webp";

export interface ConvertResult {
  blob: Blob;
  filename: string;
}

const FORMAT_EXT: Record<OutputFormat, string> = {
  "image/jpeg": "jpg",
  "image/png": "png",
  "image/webp": "webp",
};

async function convertViaCanvas(
  file: File,
  outputFormat: OutputFormat,
  quality: number,
  maxWidth?: number,
  maxHeight?: number
): Promise<ConvertResult> {
  const bitmapOptions: ImageBitmapOptions = maxWidth
    ? { resizeWidth: maxWidth, resizeQuality: "medium" }
    : {};

  const bitmap = await createImageBitmap(file, bitmapOptions);

  let w = bitmap.width;
  let h = bitmap.height;

  if (maxHeight && h > maxHeight) {
    w = Math.round((w * maxHeight) / h);
    h = maxHeight;
  }

  const canvas = document.createElement("canvas");
  canvas.width = w;
  canvas.height = h;
  const ctx = canvas.getContext("2d")!;
  ctx.drawImage(bitmap, 0, 0, w, h);
  bitmap.close();

  return new Promise((resolve, reject) => {
    canvas.toBlob(
      (blob) => {
        if (!blob) { reject(new Error("変換に失敗しました")); return; }
        const ext = FORMAT_EXT[outputFormat];
        const baseName = file.name.replace(/\.[^.]+$/, "");
        resolve({ blob, filename: `${baseName}.${ext}` });
      },
      outputFormat,
      quality
    );
  });
}

async function convertHeic(file: File, outputFormat: OutputFormat): Promise<ConvertResult> {
  const heic2any = (await import("heic2any")).default;
  const mimeType = outputFormat === "image/png" ? "image/png" : "image/jpeg";
  const result = await heic2any({ blob: file, toType: mimeType, quality: 0.92 });
  const blob = Array.isArray(result) ? result[0] : result;
  const ext = FORMAT_EXT[outputFormat];
  const baseName = file.name.replace(/\.[^.]+$/, "");
  return { blob, filename: `${baseName}.${ext}` };
}

function isHeic(file: File): boolean {
  return (
    file.type === "image/heic" ||
    file.type === "image/heif" ||
    /\.(heic|heif)$/i.test(file.name)
  );
}

export interface ConvertOptions {
  outputFormat: OutputFormat;
  quality: number;
  maxWidth?: number;
  maxHeight?: number;
}

export async function convertImage(
  file: File,
  options: ConvertOptions
): Promise<ConvertResult> {
  const MAX_SIZE_MB = 100;
  if (file.size > MAX_SIZE_MB * 1024 * 1024) {
    throw new Error(`ファイルサイズが ${MAX_SIZE_MB}MB を超えています`);
  }

  if (isHeic(file)) {
    return convertHeic(file, options.outputFormat);
  }

  return convertViaCanvas(file, options.outputFormat, options.quality, options.maxWidth, options.maxHeight);
}

export function formatBytes(bytes: number): string {
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
  return `${(bytes / 1024 / 1024).toFixed(1)} MB`;
}
