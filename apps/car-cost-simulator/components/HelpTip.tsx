"use client";

import { useState, useRef, useEffect, useCallback } from "react";
import { createPortal } from "react-dom";

interface Props {
  text: string;
}

export default function HelpTip({ text }: Props) {
  const [open, setOpen] = useState(false);
  const [positioned, setPositioned] = useState(false);
  const btnRef = useRef<HTMLButtonElement>(null);
  const popRef = useRef<HTMLDivElement>(null);
  const [pos, setPos] = useState<{ top: number; left: number }>({
    top: 0,
    left: 0,
  });

  const updatePosition = useCallback(() => {
    if (!btnRef.current) return;
    const rect = btnRef.current.getBoundingClientRect();
    const popWidth = 272;
    const margin = 8;

    let left = rect.right + margin;
    let top = rect.top - 4;

    if (left + popWidth > window.innerWidth - margin) {
      left = rect.left - popWidth - margin;
    }
    if (left < margin) {
      left = Math.max(margin, (window.innerWidth - popWidth) / 2);
    }
    if (top < margin) {
      top = margin;
    }

    setPos({ top, left });
    setPositioned(true);
  }, []);

  useEffect(() => {
    if (!open) return;
    // requestAnimationFrame で確実にレイアウト後に位置計算
    requestAnimationFrame(() => {
      updatePosition();
    });
    function handleClick(e: MouseEvent) {
      if (
        btnRef.current?.contains(e.target as Node) ||
        popRef.current?.contains(e.target as Node)
      )
        return;
      setOpen(false);
      setPositioned(false);
    }
    function handleScroll() {
      updatePosition();
    }
    document.addEventListener("mousedown", handleClick);
    window.addEventListener("scroll", handleScroll, true);
    window.addEventListener("resize", updatePosition);
    return () => {
      document.removeEventListener("mousedown", handleClick);
      window.removeEventListener("scroll", handleScroll, true);
      window.removeEventListener("resize", updatePosition);
    };
  }, [open, updatePosition]);

  return (
    <>
      <button
        ref={btnRef}
        type="button"
        onClick={() => {
          setOpen((v) => {
            if (v) setPositioned(false);
            return !v;
          });
        }}
        className="inline-flex items-center justify-center w-4 h-4 rounded-full bg-slate-200 dark:bg-slate-700 text-[10px] font-bold text-slate-500 dark:text-slate-400 hover:bg-blue-100 hover:text-blue-600 dark:hover:bg-blue-900 dark:hover:text-blue-400 transition-colors shrink-0"
        aria-label="ヘルプ"
      >
        ?
      </button>
      {open &&
        createPortal(
          <div
            ref={popRef}
            style={{
              top: pos.top,
              left: pos.left,
              visibility: positioned ? "visible" : "hidden",
            }}
            className="fixed z-[9999] w-68 rounded-lg border border-slate-200 dark:border-slate-600 bg-white dark:bg-slate-800 p-3 text-xs text-slate-600 dark:text-slate-300 shadow-xl leading-relaxed"
          >
            {text}
          </div>,
          document.body
        )}
    </>
  );
}
