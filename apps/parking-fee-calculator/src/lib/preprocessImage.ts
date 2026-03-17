// 看板画像の OCR 精度向上のための前処理
// グレースケール化 → コントラスト強調 → シャープ化 を適用する

const MAX_DIMENSION = 1500; // これ以上は縮小（精度を保ちつつ処理を高速化）
const CONTRAST_FACTOR = 1.6; // コントラスト倍率（1.0 = 変化なし）

// 3x3 シャープ化カーネル（合計=1 で明るさを維持）
const SHARPEN_KERNEL = [0, -1, 0, -1, 5, -1, 0, -1, 0];

function applySharpening(pixels: Uint8ClampedArray, width: number, height: number): void {
  const src = new Uint8ClampedArray(pixels); // 元データをコピー

  // 端の1ピクセルはスキップ（境界処理を省略）
  for (let y = 1; y < height - 1; y++) {
    for (let x = 1; x < width - 1; x++) {
      let val = 0;
      for (let ky = -1; ky <= 1; ky++) {
        for (let kx = -1; kx <= 1; kx++) {
          const srcIdx = ((y + ky) * width + (x + kx)) * 4;
          val += src[srcIdx] * SHARPEN_KERNEL[(ky + 1) * 3 + (kx + 1)];
        }
      }
      const outIdx = (y * width + x) * 4;
      const clamped = Math.min(255, Math.max(0, Math.round(val)));
      pixels[outIdx] = clamped;
      pixels[outIdx + 1] = clamped;
      pixels[outIdx + 2] = clamped;
      // alpha はそのまま
    }
  }
}

export function preprocessImage(file: File): Promise<{ base64: string; mimeType: string }> {
  return new Promise((resolve, reject) => {
    const img = new window.Image();
    const url = URL.createObjectURL(file);

    img.onerror = () => {
      URL.revokeObjectURL(url);
      reject(new Error("画像の読み込みに失敗しました"));
    };

    img.onload = () => {
      URL.revokeObjectURL(url);

      // 長辺が MAX_DIMENSION を超えたら縮小
      let { width, height } = img;
      if (width > MAX_DIMENSION || height > MAX_DIMENSION) {
        const scale = MAX_DIMENSION / Math.max(width, height);
        width = Math.round(width * scale);
        height = Math.round(height * scale);
      }

      const canvas = document.createElement("canvas");
      canvas.width = width;
      canvas.height = height;
      const ctx = canvas.getContext("2d");
      if (!ctx) {
        reject(new Error("Canvas が使用できません"));
        return;
      }

      ctx.drawImage(img, 0, 0, width, height);

      // Step 1: グレースケール化 + コントラスト強調
      const imageData = ctx.getImageData(0, 0, width, height);
      const data = imageData.data;
      for (let i = 0; i < data.length; i += 4) {
        // 輝度加重平均でグレースケール
        const gray = 0.299 * data[i] + 0.587 * data[i + 1] + 0.114 * data[i + 2];
        // コントラスト強調（中間値128を基準に伸張）
        const boosted = Math.min(255, Math.max(0, (gray - 128) * CONTRAST_FACTOR + 128));
        data[i] = boosted;
        data[i + 1] = boosted;
        data[i + 2] = boosted;
      }
      ctx.putImageData(imageData, 0, 0);

      // Step 2: シャープ化（カーネル畳み込み）
      const sharpData = ctx.getImageData(0, 0, width, height);
      applySharpening(sharpData.data, width, height);
      ctx.putImageData(sharpData, 0, 0);

      const base64 = canvas.toDataURL("image/jpeg", 0.92).split(",")[1];
      resolve({ base64, mimeType: "image/jpeg" });
    };

    img.src = url;
  });
}
