#!/usr/bin/env node

import { spawn } from "child_process";
import { join, dirname } from "path";
import { existsSync } from "fs";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

function getPlatformBinaryName() {
  const platform = process.platform;
  const arch = process.arch;

  const platformMap = {
    darwin: "macos",
    linux: "linux",
    win32: "windows",
  };

  const archMap = {
    x64: "x86_64",
    arm64: "aarch64",
  };

  const platformName = platformMap[platform];
  const archName = archMap[arch];

  if (!platformName || !archName) {
    console.error(`Unsupported platform: ${platform}-${arch}`);
    process.exit(1);
  }

  const ext = platform === "win32" ? ".exe" : "";
  return `themify-${platformName}-${archName}${ext}`;
}

function findBinary() {
  const binaryName = getPlatformBinaryName();
  const binariesDir = join(__dirname, "..", "binaries");
  const binaryPath = join(binariesDir, binaryName);

  if (existsSync(binaryPath)) {
    return binaryPath;
  }

  console.error(`Binary not found: ${binaryPath}`);
  console.error("");
  console.error("This could mean:");
  console.error(
    `  1. Your platform (${process.platform}-${process.arch}) is not supported`,
  );
  console.error("  2. The package was not installed correctly");
  console.error("");
  console.error("You can build from source if you have Zig installed:");
  console.error(
    "  git clone https://github.com/BeratHundurel/palette-themify-tui",
  );
  console.error("  cd palette-themify");
  console.error("  zig build -Doptimize=ReleaseFast");
  process.exit(1);
}

function main() {
  const binaryPath = findBinary();

  const child = spawn(binaryPath, process.argv.slice(2), {
    stdio: "inherit",
    windowsHide: false,
  });

  child.on("error", (err) => {
    console.error(`Failed to start themify: ${err.message}`);
    process.exit(1);
  });

  child.on("close", (code) => {
    process.exit(code ?? 0);
  });
}

main();
