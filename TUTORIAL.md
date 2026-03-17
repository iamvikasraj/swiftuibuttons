# Tutorial: Building the ArrowDateSelector ContentView in SwiftUI

A step-by-step walkthrough of the **ArrowDateSelector** app’s main screen: a date picker with steel-style arrow buttons, gradients, and smooth animations.  
Perfect for design-minded engineers and SwiftUI learners.

---

## What We’re Building

- A **date selector** that steps forward/backward one day at a time.
- **Steel/glass-style circular buttons** with a soft reflection and gradient strokes.
- **Smart labels**: “Today”, “Tomorrow”, “Yesterday”, or a localized date (e.g. “March 15”).
- **Haptics** and **accessibility** so it feels and works well on device.
- A single **ContentView** file that holds design tokens, the button, and the main view.

**Requirements:** Xcode 15+, iOS 17+, SwiftUI.

---

## Step 1: Design Tokens (Metrics & Colors)

Keep layout and look consistent by centralizing numbers and colors.

### 1.1 Button metrics

Use a private enum so all button dimensions live in one place:

```swift
private enum ArrowButtonMetrics {
    static let buttonSize: CGFloat = 125
    static let reflectionSize: CGSize = .init(width: 90, height: 90)
    static let reflectionCornerRadius: CGFloat = 30
    static let reflectionBlur: CGFloat = 8
    static let reflectionYOffset: CGFloat = 14
    static let strokeLineWidth: CGFloat = 3
    static let arrowShadowOpacity: CGFloat = 0.1
    static let arrowShadowRadius: CGFloat = 1
    static let arrowShadowYOffset: CGFloat = 1
}
```

Tweak these to change the button size, reflection strength, and stroke weight without hunting through the view code.

### 1.2 Custom colors

Extend `Color` with your palette. Here we use a steel gray range for background and button:

```swift
extension Color {
    static let steelBackground1 = Color(red: 67/255, green: 80/255, blue: 89/255)
    static let steelBackground2 = Color(red: 93/255, green: 106/255, blue: 114/255)
    static let steelBackground3 = Color(red: 120/255, green: 133/255, blue: 141/255)
    static let steelBackground4 = Color(red: 116/255, green: 123/255, blue: 129/255)
    static let buttonFill = Color(red: 120/255, green: 133/255, blue: 141/255)
}
```

### 1.3 Gradients

Two gradients matter: the **screen background** and the **button reflection**. Define them as static properties on `LinearGradient` (or in a small helper):

- **App background:** diagonal, topLeading → bottomTrailing, using the four steel colors at specific stops (0, 0.30, 0.59, 1.0).
- **Reflection fill:** vertical, subtle gray gradient for the soft “glow” behind the button.

Using `startPoint`/`endPoint` and `Gradient.Stop(color:location:)` gives you full control over the steel look.

---

## Step 2: The Steel Ring (Stroke Overlay)

The metallic edge on the button is **four stroked circles** with gradients and blend modes, applied as a **ViewModifier**.

### 2.1 Modifier structure

```swift
private struct CircularSteelStrokeOverlay: ViewModifier {
    func body(content: Content) -> some View {
        content.overlay(strokeLayer)
    }
    private var strokeLayer: some View { ... }
}
```

`strokeLayer` is a `ZStack` of four `Circle().stroke(...)` layers.

### 2.2 The four strokes

1. **Darken (top-left):** Black gradient, leading → topTrailing, `.blendMode(.darken)` — shadows the top-left.
2. **Darken (top-right):** Same idea, trailing → topLeading — shadows the top-right.
3. **Highlight (bottom):** White gradient, bottom → top, `.blendMode(.overlay)` — light along the bottom.
4. **Highlight (top):** White gradient, top → bottom, `.blendMode(.normal)` — soft top edge.

Use `lineWidth: ArrowButtonMetrics.strokeLineWidth` on all so the ring stays consistent. End with `.compositingGroup()` so the overlay is drawn as one layer.

### 2.3 Convenience extension

```swift
private extension View {
    func circularSteelStrokeOverlay() -> some View {
        modifier(CircularSteelStrokeOverlay())
    }
}
```

Then any view can get the steel ring with `.circularSteelStrokeOverlay()`.

---

## Step 3: The Arrow Button

The tappable control is a **ZStack** of three things: fill + stroke, reflection, and icon.

### 3.1 Layers (bottom to top)

1. **Reflection:** A `RoundedRectangle` with `reflectionFill` gradient, blurred and offset downward. Sits *behind* the circle to suggest depth.
2. **Circle + steel ring:** `Circle().fill(Color.buttonFill).frame(...).circularSteelStrokeOverlay()`.
3. **Arrow:** `Image("arrow")` with `.rotationEffect(rotation)` so the same asset works for “previous” (180°) and “next” (0°).

Add a light shadow on the arrow and use `contentShape(Circle())` so the whole circle is tappable.

### 3.2 API

```swift
struct ArrowButton: View {
    var rotation: Angle = .zero
    var body: some View { ... }
}
```

The parent passes `.degrees(180)` for previous and `.degrees(0)` for next. Keep the button reusable and stateless.

---

## Step 4: Date State and Labels

The main view owns the current date and decides what text to show.

### 4.1 State and helpers

```swift
@State private var currentDate = Date()
private let calendar = Calendar.current
private let monthDayFormatter: DateFormatter = { ... }()
```

- **formattedLabel:**  
  - If `calendar.isDateInToday(currentDate)` → `"Today"`.  
  - Else if tomorrow → `"Tomorrow"`.  
  - Else if yesterday → `"Yesterday"`.  
  - Else → `monthDayFormatter.string(from: currentDate)` (e.g. “March 15”).
- **showsDetailedDate:** `true` only for today, tomorrow, or yesterday. When true, show an extra line with weekday + full date.

Use a computed property for `formattedLabel` and another for `showsDetailedDate` so the view stays readable.

### 4.2 Changing the date

- **Previous:** `currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate`
- **Next:** same with `value: 1`.

That’s the only place you mutate `currentDate`; SwiftUI will re-render the labels automatically.

---

## Step 5: Laying Out the Main View

Structure: full-screen gradient, then a horizontal row: **previous button | date label | next button**.

### 5.1 Background

```swift
ZStack {
    LinearGradient.appBackground
        .ignoresSafeArea()
    // content on top
}
```

### 5.2 HStack

- **Spacing:** Use a negative value (e.g. `-30`) so the scaled-down buttons overlap the center slightly and feel connected to the label.
- **Previous:** `Button { ... } label: { ArrowButton(rotation: .degrees(180)).scaleEffect(0.4) }`.
- **Center:** A `VStack` with:
  - Main label: `Text(formattedLabel)` with gradient foreground and `.contentTransition(.numericText())` plus `.animation(.spring(...), value: formattedLabel)`.
  - Optional second line: only when `showsDetailedDate`, e.g. `currentDate.formatted(.dateTime.weekday().month().day())`.
- **Next:** Same as previous but `ArrowButton(rotation: .degrees(0)).scaleEffect(0.4)`.

Give the label stack a fixed width (e.g. 120) so the layout stays stable when the text changes.

---

## Step 6: Haptics and Preview

### 6.1 Haptics

On tap, call a small helper that triggers `UIImpactFeedbackGenerator(style: .medium).impactOccurred()`. Guard so it doesn’t run in the SwiftUI preview (e.g. check `ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"` and return early). That keeps the canvas stable.

### 6.2 Accessibility

- Buttons: `.accessibilityLabel("Previous day")` / `"Next day")`.
- Date: `.accessibilityElement(children: .combine)` and one `.accessibilityLabel("\(formattedLabel)")` so VoiceOver reads a single, clear phrase.
- Decorative arrow graphic: `.accessibilityHidden(true)` so the icon isn’t announced twice.

---

## Step 7: Preview

At the bottom of the file:

```swift
#Preview("Date selector") {
    ArrowDateSelectorView()
        .preferredColorScheme(.dark)
}
```

Dark mode makes the steel gradient and text stand out; you can duplicate the preview with `.preferredColorScheme(.light)` if you want both.

---

## File Structure at a Glance

| Section              | Purpose                                      |
|----------------------|----------------------------------------------|
| ArrowButtonMetrics   | Sizes, blur, stroke, shadow numbers         |
| Color + LinearGradient | Palette and gradient definitions         |
| HapticsHelper        | Haptic trigger, skipped in preview          |
| CircularSteelStrokeOverlay | Steel ring ViewModifier              |
| ArrowButton          | Reusable arrow circle (rotation + layers)   |
| ArrowDateSelectorView | Main screen: date state, layout, labels  |
| #Preview             | Canvas preview with dark mode               |

---

## Takeaways

1. **Design tokens** (metrics + colors + gradients) keep the UI consistent and easy to tune.
2. **ViewModifiers** (like the steel overlay) make reusable “effects” you can apply to any view.
3. **Layering** (reflection → fill+stroke → icon) gives depth without a lot of code.
4. **Computed properties** for `formattedLabel` and `showsDetailedDate` keep the view body clean.
5. **contentTransition + animation** make date changes feel smooth.
6. **Haptics + accessibility** improve feel and usability; guarding haptics in preview avoids canvas issues.

You now have a full picture of how the ArrowDateSelector ContentView is built. Clone the repo, open `ContentView.swift`, and tweak metrics or colors to make it your own.

**Repo:** [iamvikasraj/swiftuibuttons](https://github.com/iamvikasraj/swiftuibuttons)
