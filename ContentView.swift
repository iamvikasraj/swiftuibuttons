import SwiftUI

// MARK: - Constants
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

// MARK: - Custom Colors
extension Color {
    static let steelBackground1 = Color(red: 67/255, green: 80/255, blue: 89/255)
    static let steelBackground2 = Color(red: 93/255, green: 106/255, blue: 114/255)
    static let steelBackground3 = Color(red: 120/255, green: 133/255, blue: 141/255)
    static let steelBackground4 = Color(red: 116/255, green: 123/255, blue: 129/255)

    static let buttonFill = Color(red: 120/255, green: 133/255, blue: 141/255)
}

private extension LinearGradient {
    static var appBackground: LinearGradient {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: .steelBackground1, location: 0.0),
                .init(color: .steelBackground2, location: 0.30),
                .init(color: .steelBackground3, location: 0.59),
                .init(color: .steelBackground4, location: 1.0)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var reflectionFill: LinearGradient {
        LinearGradient(
            stops: [
                Gradient.Stop(color: Color(red: 0.48, green: 0.52, blue: 0.55), location: 0.00),
                Gradient.Stop(color: Color(red: 0.64, green: 0.67, blue: 0.70), location: 1.00),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Haptics helper
enum HapticsHelper {
    static func impactMedium() {
        #if canImport(UIKit)
        // Skip in SwiftUI previews to avoid canvas issues
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
    }
}

// MARK: - Stroke Overlay Modifier
private struct CircularSteelStrokeOverlay: ViewModifier {
    func body(content: Content) -> some View {
        content.overlay(strokeLayer)
    }

    private var strokeLayer: some View {
        ZStack {
            // Stroke 1
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .black.opacity(0.4), location: 0.0),
                            .init(color: .black.opacity(0.0), location: 0.1)
                        ]),
                        startPoint: .leading,
                        endPoint: .topTrailing
                    ),
                    lineWidth: ArrowButtonMetrics.strokeLineWidth
                )
                .blendMode(.darken)

            // Stroke 2
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .black.opacity(0.4), location: 0.0),
                            .init(color: .black.opacity(0.0), location: 0.1)
                        ]),
                        startPoint: .trailing,
                        endPoint: .topLeading
                    ),
                    lineWidth: ArrowButtonMetrics.strokeLineWidth
                )
                .blendMode(.darken)

            // Stroke 3
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .white.opacity(0.8), location: 0.1),
                            .init(color: .white.opacity(0.0), location: 0.4)
                        ]),
                        startPoint: .bottom,
                        endPoint: .top
                    ),
                    lineWidth: ArrowButtonMetrics.strokeLineWidth
                )
                .blendMode(.overlay)

            // Stroke 4
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .white.opacity(0.8), location: 0.0),
                            .init(color: .white.opacity(0.0), location: 0.3)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: ArrowButtonMetrics.strokeLineWidth
                )
                .blendMode(.normal)
        }
        .compositingGroup() // render as a single overlay group
    }
}

private extension View {
    func circularSteelStrokeOverlay() -> some View {
        modifier(CircularSteelStrokeOverlay())
    }
}

// MARK: - Arrow Button View
struct ArrowButton: View {
    var rotation: Angle = .zero

    var body: some View {
        ZStack {
            // Base Fill Circle + Stroke Overlays
            Circle()
                .fill(Color.buttonFill)
                .frame(width: ArrowButtonMetrics.buttonSize, height: ArrowButtonMetrics.buttonSize)
                .circularSteelStrokeOverlay()

            // Blurred Reflection Layer Behind
            RoundedRectangle(cornerRadius: ArrowButtonMetrics.reflectionCornerRadius, style: .continuous)
                .fill(LinearGradient.reflectionFill)
                .frame(width: ArrowButtonMetrics.reflectionSize.width, height: ArrowButtonMetrics.reflectionSize.height)
                .blur(radius: ArrowButtonMetrics.reflectionBlur)
                .offset(y: ArrowButtonMetrics.reflectionYOffset)

            // Arrow Image
            Image("arrow")
                .rotationEffect(rotation)
                .shadow(color: .black.opacity(ArrowButtonMetrics.arrowShadowOpacity),
                        radius: ArrowButtonMetrics.arrowShadowRadius,
                        y: ArrowButtonMetrics.arrowShadowYOffset)
                .accessibilityHidden(true)
        }
        .contentShape(Circle())
        .accessibilityLabel("Arrow button")
    }
}

// MARK: - ArrowDateSelectorView
struct ArrowDateSelectorView: View {
    @State private var currentDate = Date()
    private let calendar = Calendar.current
    private let monthDayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.setLocalizedDateFormatFromTemplate("MMMMd")
        return f
    }()

    var body: some View {
        ZStack {
            LinearGradient.appBackground
                .ignoresSafeArea()

            HStack(spacing: -30) {
                // Decrement Button (Previous Day)
                Button(action: {
                    currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
                    HapticsHelper.impactMedium()
                }) {
                    ArrowButton(rotation: .degrees(180))
                        .scaleEffect(0.4)
                }
                .accessibilityLabel("Previous day")

                // Date Display
                VStack(spacing: 4) {
                    // Top Label: "Today", "Tomorrow", "Yesterday", or Date
                    Text(formattedLabel)
                        .font(.system(size: 24, weight: .regular))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.white.opacity(0.8), Color.white.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.25, dampingFraction: 0.5), value: formattedLabel)

                    // Bottom Label: Visible only for Today, Tomorrow, Yesterday
                    if showsDetailedDate {
                        Text(currentDate.formatted(.dateTime.weekday().month().day()))
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(.white.opacity(0.6))
                            .contentTransition(.numericText())
                            .animation(.spring(response: 0.25, dampingFraction: 0.5), value: formattedLabel)
                            .accessibilityHidden(true)
                    }
                }
                .frame(width: 120)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(formattedLabel)")

                // Increment Button (Next Day)
                Button(action: {
                    currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
                    HapticsHelper.impactMedium()
                }) {
                    ArrowButton(rotation: .degrees(0))
                        .scaleEffect(0.4)
                }
                .accessibilityLabel("Next day")
            }
            .padding()
        }
    }

    // Top Label Logic
    private var formattedLabel: String {
        if calendar.isDateInToday(currentDate) {
            return "Today"
        } else if calendar.isDateInTomorrow(currentDate) {
            return "Tomorrow"
        } else if calendar.isDateInYesterday(currentDate) {
            return "Yesterday"
        } else {
            return monthDayFormatter.string(from: currentDate)
        }
    }

    // Should we show the detailed label below?
    private var showsDetailedDate: Bool {
        calendar.isDateInToday(currentDate)
        || calendar.isDateInTomorrow(currentDate)
        || calendar.isDateInYesterday(currentDate)
    }
}

// MARK: - AnimatedCounterText
struct AnimatedCounterText: View {
    let number: Int
    @State private var animate = false

    var body: some View {
        Text(String(number))
            .font(.system(size: 60, weight: .regular, design: .default))
            .contentTransition(.numericText())
            .animation(.spring(response: 0.25, dampingFraction: 0.5), value: animate)
    }
}

#Preview("Date selector") {
    ArrowDateSelectorView()
        .preferredColorScheme(.dark)
}
