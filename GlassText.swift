import SwiftUI

// MARK: - OverlayStyle
/// Describes one stroke layer around the button.
struct OverlayStyle {
    let gradient: LinearGradient
    let lineWidth: CGFloat
    let cornerRadius: CGFloat
}

// MARK: - RedGlassTextButton
struct RedGlassTextButton: View {
    let text: String
    let action: () -> Void
    var overlays: [OverlayStyle] = []

    private let buttonGradient = LinearGradient(
        stops: [
            .init(color: Color(red: 0.52, green: 0.06, blue: 0.07), location: 0.07),
            .init(color: Color(red: 0.90, green: 0.16, blue: 0.22), location: 1.00),
        ],
        startPoint: UnitPoint(x: 0.95, y: 0),
        endPoint: UnitPoint(x: 0, y: 1)
    )

    @State private var isPressed = false

    private var defaultOverlays: [OverlayStyle] {
        [
            OverlayStyle(
                gradient: .init(colors: [.white.opacity(1.0), .black.opacity(0.01)],
                                startPoint: .top, endPoint: .bottom),
                lineWidth: 1.2, cornerRadius: 25
            ),
            OverlayStyle(
                gradient: .init(colors: [.white.opacity(0.10), .black.opacity(0.10)],
                                startPoint: .bottom, endPoint: .top),
                lineWidth: 1.2, cornerRadius: 25
            ),
            OverlayStyle(
                gradient: .init(colors: [.white.opacity(1.0), .black.opacity(0.10)],
                                startPoint: .leading, endPoint: .trailing),
                lineWidth: 1.2, cornerRadius: 25
            ),
            OverlayStyle(
                gradient: .init(colors: [.white.opacity(0.08), .black.opacity(0.10)],
                                startPoint: .trailing, endPoint: .leading),
                lineWidth: 1.2, cornerRadius: 25
            ),
            OverlayStyle(
                gradient: .init(colors: [.white.opacity(0.06)],
                                startPoint: .top, endPoint: .bottom),
                lineWidth: 2, cornerRadius: 25
            )
        ]
    }

    var body: some View {
        Button {
            action()
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            withAnimation(.spring(duration: 0.3)) { isPressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(duration: 0.3)) { isPressed = false }
            }
        } label: {
            ZStack {
                // Background gradient
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(buttonGradient)

                // Shadow/glow effect
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(buttonGradient)
                    .frame(width: 120, height: 60)
                    .blur(radius: 5.5)
                    .offset(y: 8)

                // Text
                Text(text)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
            }
            .frame(width: 200, height: 70)
            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
            .applyOverlayStyles(overlays.isEmpty ? defaultOverlays : overlays)
            .shadow(color: .black.opacity(isPressed ? 0.1 : 0.3), radius: isPressed ? 3 : 8, y: isPressed ? 2 : 8)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .animation(.spring(duration: 0.3), value: isPressed)
        .accessibilityLabel("Red glass text button")
    }
}

// MARK: - Glass Overlay Extension
extension View {
    func applyOverlayStyles(_ styles: [OverlayStyle]) -> some View {
        // Build a single overlay stack to blend as a whole with the background.
        let overlayStack = ZStack {
            ForEach(0..<styles.count, id: \.self) { index in
                let style = styles[index]
                RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous)
                    .inset(by: style.lineWidth / 2) // keep entire stroke inside
                    .stroke(style.gradient, lineWidth: style.lineWidth)
                    // Per-layer subtlety; most layers overlay, one uses softLight for softer mix
                    .blendMode(index == 2 ? .softLight : .overlay)
                    .opacity(index == styles.count - 1 ? 0.6 : 0.9)
            }
        }
        .compositingGroup()
        .blendMode(.overlay)
        // Keep this static so it doesn't animate or look like a fade on press
        .opacity(1)

        return self.overlay(overlayStack)
    }
}

// MARK: - RedGlassTextButton Demo
struct RedGlassTextDemo: View {
    var body: some View {
        ZStack {
            LinearGradient(
                stops: [
                    .init(color: Color(red: 0.52, green: 0.06, blue: 0.07), location: 0.07),
                    .init(color: Color(red: 0.90, green: 0.16, blue: 0.22), location: 1.00),
                ],
                startPoint: UnitPoint(x: 0.95, y: 0),
                endPoint: UnitPoint(x: 0, y: 1)
            )
            .ignoresSafeArea()

            RedGlassTextButton(text: "Launch") {
                print("RedGlassTextButton tapped")
            }
        }
    }
}

// MARK: - Steel Glass Button Preset
struct SteelColorPreset {
    let background: Color
    let gradientTop: Color
    let gradientBottom: Color
    let stroke: Color
    let overlayTint: Color
    let overlayGloss: Color
    let fullBackgroundTop: Color
    let fullBackgroundBottom: Color
}

let defaultSteelPreset = SteelColorPreset(
    background: Color(red: 0.47, green: 0.52, blue: 0.55),
    gradientTop: Color(red: 0.48, green: 0.52, blue: 0.55),
    gradientBottom: Color(red: 0.64, green: 0.67, blue: 0.70),
    stroke: Color(red: 0.37, green: 0.42, blue: 0.44),
    overlayTint: Color(red: 0.32, green: 0.36, blue: 0.40),
    overlayGloss: .gray.opacity(0.6),
    fullBackgroundTop: Color(red: 0.26, green: 0.31, blue: 0.35),
    fullBackgroundBottom: Color(red: 0.45, green: 0.48, blue: 0.51)
)

// MARK: - SteelGlassButton
struct SteelGlassButton: View {
    let preset: SteelColorPreset
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button {
            action()
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            withAnimation(.spring(duration: 0.3)) { isPressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(duration: 0.3)) { isPressed = false }
            }
        } label: {
            ZStack {
                // Background
                Circle().fill(preset.background)

                // Shadow/glow effect
                Circle()
                    .fill(
                        LinearGradient(colors: [preset.gradientTop, preset.gradientBottom], startPoint: .top, endPoint: .bottom)
                    )
                    .frame(width: 100, height: 100)
                    .blur(radius: 5.5)
                    .offset(y: 10)

                // Icon (assuming you have an arrow image)
                Image(systemName: "arrow.right")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 8, y: 8)
            }
            .frame(width: 125, height: 125)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(preset.stroke, lineWidth: 1.75)
            )
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(colors: [.clear, preset.overlayTint], startPoint: .topTrailing, endPoint: .bottomLeading),
                        lineWidth: 2
                    )
                    .blendMode(.overlay)
            )
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(colors: [.clear, preset.overlayTint], startPoint: .bottomLeading, endPoint: .topTrailing),
                        lineWidth: 1
                    )
            )
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(colors: [.white.opacity(0.9), preset.overlayGloss], startPoint: .top, endPoint: .bottom),
                        lineWidth: 3
                    )
                    .blendMode(.darken)
            )
            .shadow(color: .black.opacity(isPressed ? 0.1 : 0.3), radius: isPressed ? 3 : 8, y: isPressed ? 2 : 8)
            .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .animation(.spring(duration: 0.3), value: isPressed)
        .accessibilityLabel("Steel glass button")
    }
}

// MARK: - SteelGlassButton Demo
struct SteelGlassDemo: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [defaultSteelPreset.fullBackgroundTop, defaultSteelPreset.fullBackgroundBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            SteelGlassButton(preset: defaultSteelPreset) {
                print("Tapped Steel Button")
            }
        }
    }
}

// MARK: - Final Preview
#Preview {
    VStack(spacing: 40) {
        RedGlassTextDemo()
    }
}
