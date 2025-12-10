# 🎨 Palette Themify

A terminal-based application that extracts colors from any image and generates beautiful, ready-to-use themes for VS Code and Zed editors.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey)

## ✨ Features

- **🖼️ Image Color Extraction** - Extracts the most prominent colors from any image (PNG, JPG, etc.)
- **🎯 Smart Color Selection** - Uses color theory algorithms to select diverse, harmonious colors
- **🔧 Auto Installation** - Themes are automatically installed to the correct editor directory

## 📦 Installation

### Via npm (Recommended)

```bash
npm install -g palette-themify-tui
```

### Alternative: Local Installation

```bash
npm install palette-themify-tui
npx themify
```

### Building from Source

Requires [Zig](https://ziglang.org/download/) version 0.15.2 or later.

```bash
git clone https://github.com/BeratHundurel/palette-themify
cd palette-themify
zig build -Doptimize=ReleaseFast
```

The binary will be available at `zig-out/bin/themify`.

## 🚀 Usage

Simply run:

```bash
themify
```

### Step-by-Step Guide

1. **Enter Image Path**
   - Type or paste the path to your image
   - Supports PNG, JPG, and other common formats
   - Press `Enter` to analyze the image

2. **Preview Color Palette**
   - View the extracted colors displayed in your terminal
   - The top 20 most prominent colors are shown

3. **Select Editor**
   - Choose between VS Code or Zed
   - Use `↑`/`↓` to navigate, `Enter` to select

4. **Name Your Theme**
   - Enter a custom name for your theme
   - Press `Enter` to generate and install

5. **Activate Your Theme**
   - **VS Code:** Open Command Palette (`Ctrl+Shift+P`) → "Preferences: Color Theme" → Select your theme
   - **Zed:** Open Settings → Select Theme → Choose your theme

## 🎨 How It Works

1. **Color Extraction** - Analyzes every pixel in the image and groups similar colors together
2. **Color Sorting** - Ranks colors by frequency to find the most dominant ones
3. **Diversity Selection** - Uses LAB color space to select visually distinct colors
4. **Contrast Optimization** - Ensures text remains readable with proper contrast ratios
5. **Theme Generation** - Maps colors to editor UI elements and syntax tokens
6. **Auto Installation** - Places theme files in the correct editor extensions directory

## 📁 Theme Installation Paths

### VS Code

- **Windows:** `%USERPROFILE%\.vscode\extensions\`
- **macOS:** `~/.vscode/extensions/`
- **Linux:** `~/.vscode/extensions/`

### Zed

- **Windows:** `%APPDATA%\Zed\themes\`
- **macOS:** `~/.config/zed/themes/`
- **Linux:** `~/.config/zed/themes/`

## 🖥️ Supported Platforms

| Platform | Architecture     | Status |
| -------- | ---------------- | ------ |
| Windows  | x64              | ✅     |
| Windows  | arm64            | ✅     |
| macOS    | x64 (Intel)      | ✅     |
| macOS    | arm64 (M1/M2/M3) | ✅     |
| Linux    | x64              | ✅     |
| Linux    | arm64            | ✅     |

## 🛠️ Technical Details

- **Language:** Zig 0.15.2
- **Image Processing:** [zigimg](https://github.com/zigimg/zigimg)
- **Terminal UI:** [libvaxis](https://github.com/rockorager/libvaxis)
- **Color Algorithms:** Custom implementation using LAB color space for perceptual accuracy

## 🤝 Contributing

Contributions are welcome! Feel free to:

- Report bugs
- Suggest features
- Submit pull requests

## 👤 Author

**Berat Hundurel**

- GitHub: [@BeratHundurel](https://github.com/BeratHundurel)

---
