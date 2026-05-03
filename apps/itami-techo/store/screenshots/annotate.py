#!/usr/bin/env python3
"""
App Store スクリーンショット注釈スクリプト
各スクリーンショットにキャプションを付けて annotated/ フォルダに保存する
"""

from PIL import Image, ImageDraw, ImageFont
import os, sys

RAW_DIR = os.path.join(os.path.dirname(__file__), "raw")
OUT_DIR = os.path.join(os.path.dirname(__file__), "annotated")
os.makedirs(OUT_DIR, exist_ok=True)

# App Store recommended size: 1290 x 2796 (iPhone 6.7")
# Our screenshots are 1320 x 2868 (iPhone 17 Pro Max native)
TARGET_W, TARGET_H = 1320, 2868

# Color palette
BLUE = (0, 122, 255)
DARK_BLUE = (0, 70, 160)
WHITE = (255, 255, 255)
BLACK = (0, 0, 0)
LIGHT_GRAY = (245, 245, 245)

def find_system_font(size):
    """Find a Japanese-capable font."""
    # Try Hiragino (macOS Japanese font)
    candidates = [
        "/System/Library/Fonts/ヒラギノ角ゴシック W6.ttc",
        "/System/Library/Fonts/Hiragino Sans GB.ttc",
        "/Library/Fonts/ヒラギノ角ゴ ProN W6.otf",
        "/System/Library/Fonts/AppleSDGothicNeo.ttc",
    ]
    for path in candidates:
        if os.path.exists(path):
            try:
                return ImageFont.truetype(path, size)
            except Exception:
                continue
    # Fall back to default
    return ImageFont.load_default()

def add_caption(img_path, out_path, top_text_ja, top_text_sub=None, accent_color=BLUE):
    """
    スクリーンショットの上部にキャプションバーを追加する。
    top_text_ja: メインキャプション（大きいテキスト）
    top_text_sub: サブテキスト（小さいテキスト）
    """
    try:
        img = Image.open(img_path).convert("RGBA")
    except FileNotFoundError:
        print(f"  SKIP (not found): {img_path}")
        return

    # Resize if needed
    if img.size != (TARGET_W, TARGET_H):
        img = img.resize((TARGET_W, TARGET_H), Image.LANCZOS)

    # Create canvas (same size + top banner)
    BANNER_H = 280  # pixels for the top caption area
    canvas = Image.new("RGBA", (TARGET_W, TARGET_H + BANNER_H), WHITE)

    # Draw gradient banner at top
    banner = Image.new("RGBA", (TARGET_W, BANNER_H), accent_color)
    draw_banner = ImageDraw.Draw(banner)

    # Gradient from dark to light
    for y in range(BANNER_H):
        alpha = int(255 * (1 - y / BANNER_H * 0.3))
        r = int(accent_color[0] * 0.7 + (DARK_BLUE[0] * (1 - y/BANNER_H)))
        g = int(accent_color[1] * 0.7)
        b = int(accent_color[2])
        draw_banner.line([(0, y), (TARGET_W, y)], fill=(r, g, b, alpha))

    canvas.paste(banner, (0, 0))

    # Add main text
    font_main = find_system_font(72)
    font_sub = find_system_font(42)

    draw = ImageDraw.Draw(canvas)

    # Main caption
    text_y = 60
    draw.text((TARGET_W // 2, text_y), top_text_ja,
              font=font_main, fill=WHITE, anchor="mm")

    # Sub caption
    if top_text_sub:
        draw.text((TARGET_W // 2, text_y + 100), top_text_sub,
                  font=font_sub, fill=(220, 235, 255), anchor="mm")

    # Paste screenshot below banner
    canvas.paste(img, (0, BANNER_H))

    # Crop back to TARGET_H (remove bottom overflow)
    result = canvas.crop((0, 0, TARGET_W, TARGET_H))
    result.convert("RGB").save(out_path, "PNG", optimize=True)
    print(f"  Saved: {os.path.basename(out_path)}")


def add_top_caption_only(img_path, out_path, title, subtitle=None, bg_color=BLUE):
    """
    スクリーンショットの上部 300px をキャプションで上書きする。
    (ビューのコンテンツが上部にある場合に使用)
    """
    try:
        img = Image.open(img_path).convert("RGBA")
    except FileNotFoundError:
        print(f"  SKIP (not found): {img_path}")
        return

    if img.size != (TARGET_W, TARGET_H):
        img = img.resize((TARGET_W, TARGET_H), Image.LANCZOS)

    # Composite: keep the image but draw a colored rect at top
    overlay = img.copy()
    draw = ImageDraw.Draw(overlay)

    CAP_H = 350
    # Draw rounded-ish rect at top (just a solid rect for simplicity)
    draw.rectangle([(0, 0), (TARGET_W, CAP_H)], fill=(*bg_color, 230))

    font_main = find_system_font(68)
    font_sub = find_system_font(40)

    draw.text((TARGET_W // 2, 130), title, font=font_main, fill=WHITE, anchor="mm")
    if subtitle:
        draw.text((TARGET_W // 2, 240), subtitle, font=font_sub, fill=(210, 230, 255), anchor="mm")

    overlay.convert("RGB").save(out_path, "PNG", optimize=True)
    print(f"  Saved: {os.path.basename(out_path)}")


print("Annotating screenshots...")

# Screen 1: Record (症状選択)
add_top_caption_only(
    f"{RAW_DIR}/01_launch.png",
    f"{OUT_DIR}/01_record.png",
    "しんどい瞬間をすぐ記録",
    "Apple Watch でも iPhone でも",
    BLUE,
)

# Screen 2: History (履歴)
add_top_caption_only(
    f"{RAW_DIR}/02_history.png",
    f"{OUT_DIR}/02_history.png",
    "いつ・どのくらいかを一覧で",
    "服薬記録・落ち着いた時刻も管理",
    (52, 120, 246),
)

# Screen 3: Trends (傾向)
add_top_caption_only(
    f"{RAW_DIR}/03_trends.png",
    f"{OUT_DIR}/03_trends.png",
    "自分の傾向が一目でわかる",
    "症状別・時間帯別・気圧変化との関係",
    (88, 86, 214),
)

# Screen 4: Settings (設定 / プレミアム導線)
add_top_caption_only(
    f"{RAW_DIR}/04_settings.png",
    f"{OUT_DIR}/04_settings.png",
    "通院向けレポートをまとめる",
    "PDF / CSV で医師に見せやすい形に",
    (0, 150, 100),
)

print("Done. Annotated screenshots saved to:", OUT_DIR)
