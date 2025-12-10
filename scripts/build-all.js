import { execSync } from "child_process";
import { existsSync, mkdirSync, copyFileSync } from "fs";
import { join, dirname } from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const targets = [
  { platform: "linux", arch: "x86_64", zigTarget: "x86_64-linux" },
  { platform: "linux", arch: "aarch64", zigTarget: "aarch64-linux" },
  { platform: "macos", arch: "x86_64", zigTarget: "x86_64-macos" },
  { platform: "macos", arch: "aarch64", zigTarget: "aarch64-macos" },
  { platform: "windows", arch: "x86_64", zigTarget: "x86_64-windows" },
  { platform: "windows", arch: "aarch64", zigTarget: "aarch64-windows" },
];

const rootDir = join(__dirname, "..");
const binariesDir = join(rootDir, "binaries");

if (!existsSync(binariesDir)) {
  mkdirSync(binariesDir, { recursive: true });
}

function buildTarget(target) {
  const ext = target.platform === "windows" ? ".exe" : "";
  const outputName = `themify-${target.platform}-${target.arch}${ext}`;
  const outputPath = join(binariesDir, outputName);

  console.log(`Building for ${target.platform}-${target.arch}...`);

  try {
    execSync(`zig build -Doptimize=ReleaseFast -Dtarget=${target.zigTarget}`, {
      cwd: rootDir,
      stdio: "inherit",
    });

    const builtBinary = join(rootDir, "zig-out", "bin", `themify${ext}`);
    if (existsSync(builtBinary)) {
      copyFileSync(builtBinary, outputPath);
      console.log(`  -> ${outputName}`);
    } else {
      console.error(`  Error: Built binary not found at ${builtBinary}`);
      return false;
    }

    return true;
  } catch (err) {
    console.error(
      `  Error building for ${target.platform}-${target.arch}:`,
      err.message,
    );
    return false;
  }
}

function main() {
  console.log("Building themify for all platforms...\n");

  const results = { success: [], failed: [] };

  for (const target of targets) {
    if (buildTarget(target)) {
      results.success.push(`${target.platform}-${target.arch}`);
    } else {
      results.failed.push(`${target.platform}-${target.arch}`);
    }
    console.log("");
  }

  console.log("Build Summary:");
  console.log(`  Success: ${results.success.length}/${targets.length}`);
  if (results.success.length > 0) {
    console.log(`    - ${results.success.join("\n    - ")}`);
  }
  if (results.failed.length > 0) {
    console.log(`  Failed: ${results.failed.length}/${targets.length}`);
    console.log(`    - ${results.failed.join("\n    - ")}`);
  }

  console.log(`\nBinaries are in: ${binariesDir}`);
}

main();
