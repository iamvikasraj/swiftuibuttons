
<div align="right">
  <details>
    <summary >🌐 Language</summary>
    <div>
      <div align="center">
        <a href="https://openaitx.github.io/view.html?user=iamvikasraj&project=swiftuibuttons&lang=en">English</a>
        | <a href="https://openaitx.github.io/view.html?user=iamvikasraj&project=swiftuibuttons&lang=zh-CN">简体中文</a>
        | <a href="https://openaitx.github.io/view.html?user=iamvikasraj&project=swiftuibuttons&lang=zh-TW">繁體中文</a>
        | <a href="https://openaitx.github.io/view.html?user=iamvikasraj&project=swiftuibuttons&lang=ja">日本語</a>
        | <a href="https://openaitx.github.io/view.html?user=iamvikasraj&project=swiftuibuttons&lang=ko">한국어</a>
        | <a href="https://openaitx.github.io/view.html?user=iamvikasraj&project=swiftuibuttons&lang=hi">हिन्दी</a>
        | <a href="https://openaitx.github.io/view.html?user=iamvikasraj&project=swiftuibuttons&lang=th">ไทย</a>
        | <a href="https://openaitx.github.io/view.html?user=iamvikasraj&project=swiftuibuttons&lang=fr">Français</a>
        | <a href="https://openaitx.github.io/view.html?user=iamvikasraj&project=swiftuibuttons&lang=de">Deutsch</a>
        | <a href="https://openaitx.github.io/view.html?user=iamvikasraj&project=swiftuibuttons&lang=es">Español</a>
        | <a href="https://openaitx.github.io/view.html?user=iamvikasraj&project=swiftuibuttons&lang=it">Italiano</a>
        | <a href="https://openaitx.github.io/view.html?user=iamvikasraj&project=swiftuibuttons&lang=ru">Русский</a>
        | <a href="https://openaitx.github.io/view.html?user=iamvikasraj&project=swiftuibuttons&lang=pt">Português</a>
        | <a href="https://openaitx.github.io/view.html?user=iamvikasraj&project=swiftuibuttons&lang=nl">Nederlands</a>
        | <a href="https://openaitx.github.io/view.html?user=iamvikasraj&project=swiftuibuttons&lang=pl">Polski</a>
        | <a href="https://openaitx.github.io/view.html?user=iamvikasraj&project=swiftuibuttons&lang=ar">العربية</a>
        | <a href="https://openaitx.github.io/view.html?user=iamvikasraj&project=swiftuibuttons&lang=fa">فارسی</a>
        | <a href="https://openaitx.github.io/view.html?user=iamvikasraj&project=swiftuibuttons&lang=tr">Türkçe</a>
        | <a href="https://openaitx.github.io/view.html?user=iamvikasraj&project=swiftuibuttons&lang=vi">Tiếng Việt</a>
        | <a href="https://openaitx.github.io/view.html?user=iamvikasraj&project=swiftuibuttons&lang=id">Bahasa Indonesia</a>
        | <a href="https://openaitx.github.io/view.html?user=iamvikasraj&project=swiftuibuttons&lang=as">অসমীয়া</
      </div>
    </div>
  </details>
</div>

# jordansingerbutton

A beautiful, interactive counter component for SwiftUI featuring glassmorphic arrow buttons and smooth animations.

## 📱 Demo



## 🌿 Branches

### `main` - Full App
The complete jordansingerbutton app with counter functionality.

### `tutorial` - Arrow Button Component
A clean, standalone version focusing just on the beautiful arrow button component. Perfect for learning and sharing!

**To view the tutorial version:**
```bash
git checkout tutorial
```

## 🚀 Quick Start

### Using the Arrow Button Component

The `ArrowButton` is a reusable SwiftUI component that creates a beautiful glassmorphic button with:
- Metallic steel appearance with multi-layer strokes
- Blurred reflection effect
- Smooth animations
- Customizable rotation

```swift
import SwiftUI

ArrowButton(rotation: .degrees(0))  // Pointing down
ArrowButton(rotation: .degrees(180)) // Pointing up
ArrowButton(rotation: .degrees(90))  // Pointing left
ArrowButton(rotation: .degrees(270)) // Pointing right
```

### Full App Usage

The complete app includes date navigation with "Today", "Tomorrow", "Yesterday" labels and smooth date transitions.

## 📁 Project Structure

```
jordansingerbutton/
├── CounterView.swift          # Counter with arrow buttons (includes ArrowButton)
├── JordanSingerButtonApp.swift  # App entry point
└── Assets.xcassets/            # Arrow image asset
```

## 🎨 Features

- **Glassmorphic Design**: Beautiful metallic steel appearance
- **Smooth Animations**: Spring-based animations for interactions
- **Accessibility**: Full VoiceOver support
- **Customizable**: Easy to modify colors, sizes, and rotations

## 📝 License

Free to use and modify for your projects!
