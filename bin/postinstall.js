import { existsSync, chmodSync } from "fs";
import { join, dirname } from "path";
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
    return null;
  }

  const ext = platform === "win32" ? ".exe" : "";
  return `themify-${platformName}-${archName}${ext}`;
}

function main() {
  const binaryName = getPlatformBinaryName();
  if (!binaryName) {
    console.log("Unsupported platform, skipping postinstall");
    return;
  }

  const binariesDir = join(__dirname, "..", "binaries");
  const binaryPath = join(binariesDir, binaryName);

  if (!existsSync(binaryPath)) {
    return;
  }

  if (process.platform !== "win32") {
    try {
      chmodSync(binaryPath, 0o755);
      console.log(`Made ${binaryName} executable`);
    } catch (err) {
      console.warn(`Warning: Could not make binary executable: ${err.message}`);
    }
  }
}

main();
