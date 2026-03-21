const { getDefaultConfig } = require("expo/metro-config");
const { withNativeWind } = require("nativewind/metro");
const {
  getRewriteRequestUrl,
} = require("@expo/metro-config/build/rewriteRequestUrl");
const path = require("path");

const projectRoot = __dirname;
const workspaceRoot = path.resolve(projectRoot, "../..");

const config = getDefaultConfig(projectRoot);

// モノレポ対応: ルートの node_modules も watchFolders に追加
config.watchFolders = [workspaceRoot];

// モジュール解決の優先順位: apps/mobile/node_modules → root/node_modules
config.resolver.nodeModulesPaths = [
  path.resolve(projectRoot, "node_modules"),
  path.resolve(workspaceRoot, "node_modules"),
];

// モノレポ対応: serverRoot がモノレポルートになるため、
// rewriteRequestUrl を projectRoot ベースで再設定
config.server.rewriteRequestUrl = getRewriteRequestUrl(projectRoot);

module.exports = withNativeWind(config, { input: "./global.css" });
