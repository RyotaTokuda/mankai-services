/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./app/**/*.{js,jsx,ts,tsx}", "./components/**/*.{js,jsx,ts,tsx}"],
  presets: [require("nativewind/preset")],
  theme: {
    extend: {
      colors: {
        primary: "#2563EB",
        "primary-light": "#EFF6FF",
        surface: "#FFFFFF",
        background: "#F8FAFC",
        "text-primary": "#0F172A",
        "text-secondary": "#64748B",
        border: "#E2E8F0",
        error: "#DC2626",
      },
    },
  },
  plugins: [],
};
