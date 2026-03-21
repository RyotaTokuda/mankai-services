import { FFmpeg } from "@ffmpeg/ffmpeg";
import { fetchFile, toBlobURL } from "@ffmpeg/util";
import { formatBytes } from "./image-convert";

export { formatBytes };

export type VideoOutputFormat = "mp4" | "gif";

export interface VideoConvertOptions {
  outputFormat: VideoOutputFormat;
  videoBitrate: string;
  maxWidth: string;
  fps: string;
}

export interface VideoConvertResult {
  blob: Blob;
  filename: string;
}

let ffmpegInstance: FFmpeg | null = null;
let loadPromise: Promise<void> | null = null;

async function getFFmpeg(): Promise<FFmpeg> {
  if (!ffmpegInstance) {
    ffmpegInstance = new FFmpeg();
  }
  if (!loadPromise) {
    loadPromise = (async () => {
      const baseURL = "https://unpkg.com/@ffmpeg/core@0.12.6/dist/esm";
      await ffmpegInstance!.load({
        coreURL: await toBlobURL(`${baseURL}/ffmpeg-core.js`, "text/javascript"),
        wasmURL: await toBlobURL(`${baseURL}/ffmpeg-core.wasm`, "application/wasm"),
      });
    })().catch((err) => {
      loadPromise = null;
      throw err;
    });
  }
  await loadPromise;
  return ffmpegInstance!;
}

export function preloadFFmpeg(): void {
  getFFmpeg().catch(() => {});
}

export async function convertVideo(
  file: File,
  options: VideoConvertOptions,
  onProgress?: (p: number) => void,
): Promise<VideoConvertResult> {
  if (file.size > 500 * 1024 * 1024) {
    throw new Error("ファイルサイズが大きすぎます（上限500MB）");
  }

  const ff = await getFFmpeg();

  const progressHandler = onProgress
    ? ({ progress }: { progress: number }) => {
        onProgress(Math.min(99, Math.round(progress * 100)));
      }
    : null;

  if (progressHandler) ff.on("progress", progressHandler);

  try {
    const inExt = (file.name.split(".").pop() ?? "mp4").toLowerCase();
    const inputName = `input.${inExt}`;
    const outExt = options.outputFormat === "gif" ? "gif" : "mp4";
    const outputName = `output.${outExt}`;

    await ff.writeFile(inputName, await fetchFile(file));
    await ff.exec(buildArgs(inputName, outputName, options));

    const data = await ff.readFile(outputName);
    const rawBytes = typeof data === "string"
      ? new TextEncoder().encode(data)
      : new Uint8Array(data);
    const buffer = rawBytes.buffer.slice(rawBytes.byteOffset, rawBytes.byteOffset + rawBytes.byteLength) as ArrayBuffer;
    await ff.deleteFile(inputName).catch(() => {});
    await ff.deleteFile(outputName).catch(() => {});

    const mimeType = outExt === "gif" ? "image/gif" : "video/mp4";
    const blob = new Blob([buffer], { type: mimeType });
    const baseName = file.name.replace(/\.[^.]+$/, "");

    if (onProgress) onProgress(100);

    return { blob, filename: `${baseName}.${outExt}` };
  } finally {
    if (progressHandler) ff.off("progress", progressHandler);
  }
}

function buildArgs(
  input: string,
  output: string,
  opts: VideoConvertOptions,
): string[] {
  const { outputFormat, videoBitrate, maxWidth, fps } = opts;
  const w = maxWidth ? parseInt(maxWidth, 10) : null;

  if (outputFormat === "gif") {
    const f = fps || "15";
    const scaleFilter = w ? `,scale=${w}:-1:flags=lanczos` : "";
    return [
      "-i", input,
      "-vf", `fps=${f}${scaleFilter},split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse`,
      "-loop", "0",
      output,
    ];
  }

  const args: string[] = ["-i", input];
  if (w) args.push("-vf", `scale='min(${w},iw)':-2`);
  args.push("-c:v", "libx264");
  if (videoBitrate) {
    args.push("-b:v", videoBitrate);
  } else {
    args.push("-crf", "23");
  }
  args.push("-preset", "ultrafast", "-threads", "0", "-c:a", "aac", "-movflags", "+faststart");
  args.push(output);
  return args;
}
