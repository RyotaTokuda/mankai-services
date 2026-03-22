import { defineConfig, globalIgnores } from "eslint/config";
import nextVitals from "eslint-config-next/core-web-vitals";
import nextTs from "eslint-config-next/typescript";
import kuiA11y from "@mankai/ui/a11y/eslint-config";

// kuiA11y の plugins は nextVitals と重複するので rules のみ取り出す
const a11yRulesOnly = { rules: kuiA11y.rules };

const eslintConfig = defineConfig([
  ...nextVitals,
  ...nextTs,
  a11yRulesOnly,
  globalIgnores([
    ".next/**",
    "out/**",
    "build/**",
    "next-env.d.ts",
  ]),
]);

export default eslintConfig;
