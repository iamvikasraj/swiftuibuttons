import SwiftUI

// MARK: - Custom Colors
extension Color {
    static let steelBackground1 = Color(red: 67/255, green: 80/255, blue: 89/255)
    static let steelBackground2 = Color(red: 93/255, green: 106/255, blue: 114/255)
    static let steelBackground3 = Color(red: 120/255, green: 133/255, blue: 141/255)
    static let steelBackground4 = Color(red: 116/255, green: 123/255, blue: 129/255)
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
}

// MARK: - Haptics helper
enum HapticsHelper {
    static func impactMedium() {
        #if canImport(UIKit)
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
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
    
    private var isRunningInPreviews: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

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
            .buttonStyle(.plain)
            .padding()
        }
        // PreviewShell can crash while traversing complex accessibility trees.
        // We keep accessibility for the real app, but hide it in previews.
        .accessibilityHidden(isRunningInPreviews)
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
