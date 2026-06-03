import SwiftUI

// MARK: - Constants
private enum ArrowButtonMetrics {
    static let buttonSize: CGFloat = 125
    static let reflectionDiameter: CGFloat = 90
    static let reflectionBlur: CGFloat = 8
    static let reflectionYOffset: CGFloat = 14
    static let strokeLineWidth: CGFloat = 3
    static let arrowShadowOpacity: CGFloat = 0.1
    static let arrowShadowRadius: CGFloat = 1
    static let arrowShadowYOffset: CGFloat = 1
}

// MARK: - Colors
private extension Color {
    static let buttonFill = Color(red: 120/255, green: 133/255, blue: 141/255)
}

private extension LinearGradient {
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

// MARK: - Stroke Overlay
private struct CircularSteelStrokeOverlay: ViewModifier {
    /// How many of the four steel strokes are visible (0–4).
    var visibleStrokeCount: Int

    func body(content: Content) -> some View {
        content.overlay(strokeLayer)
    }

    private var strokeLayer: some View {
        ZStack {
            if visibleStrokeCount >= 1 {
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
            }

            if visibleStrokeCount >= 2 {
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
            }

            if visibleStrokeCount >= 3 {
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
            }

            if visibleStrokeCount >= 4 {
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
        }
        .compositingGroup()
    }
}

private extension View {
    func circularSteelStrokeOverlay(visibleStrokeCount: Int = 4) -> some View {
        modifier(CircularSteelStrokeOverlay(visibleStrokeCount: visibleStrokeCount))
    }
}

// MARK: - Build Steps (matches design breakdown progression)
enum ArrowButtonStep: Int, CaseIterable, Comparable {
    case base = 1
    case strokeDarkLeading = 2
    case strokeDarkTrailing = 3
    case strokeHighlightBottom = 4
    case strokeHighlightTop = 5
    case reflection = 6
    case reflectionBlur = 7
    case arrow = 8
    case complete = 9

    static func < (lhs: ArrowButtonStep, rhs: ArrowButtonStep) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var title: String {
        switch self {
        case .base: "Base Circle"
        case .strokeDarkLeading: "Dark Edge I"
        case .strokeDarkTrailing: "Dark Edge II"
        case .strokeHighlightBottom: "Light Edge I"
        case .strokeHighlightTop: "Light Edge II"
        case .reflection: "Reflection"
        case .reflectionBlur: "Frosted Blur"
        case .arrow: "Arrow Icon"
        case .complete: "Complete"
        }
    }

    var visibleStrokeCount: Int {
        switch self {
        case .base: 0
        case .strokeDarkLeading: 1
        case .strokeDarkTrailing: 2
        case .strokeHighlightBottom: 3
        case .strokeHighlightTop, .reflection, .reflectionBlur, .arrow, .complete: 4
        }
    }

    var reflectionBlurRadius: CGFloat {
        switch self {
        case .reflection: 0
        case .reflectionBlur, .arrow, .complete: ArrowButtonMetrics.reflectionBlur
        default: 0
        }
    }

    var showsReflection: Bool {
        rawValue >= ArrowButtonStep.reflection.rawValue
    }

    var showsArrow: Bool {
        self == .arrow || self == .complete
    }
}

// MARK: - Arrow Button
struct ArrowButton: View {
    var rotation: Angle = .zero
    var step: ArrowButtonStep = .complete

    var body: some View {
        ZStack {
            buttonFace

            if step.showsArrow {
                Image("arrow")
                    .rotationEffect(rotation)
                    .shadow(color: .black.opacity(ArrowButtonMetrics.arrowShadowOpacity),
                            radius: ArrowButtonMetrics.arrowShadowRadius,
                            y: ArrowButtonMetrics.arrowShadowYOffset)
                    .accessibilityHidden(true)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: step)
        .contentShape(Circle())
        .accessibilityLabel("Arrow button")
    }

    private var buttonFace: some View {
        ZStack {
            Circle()
                .fill(Color.buttonFill)

            reflectionLayer
        }
        .frame(width: ArrowButtonMetrics.buttonSize, height: ArrowButtonMetrics.buttonSize)
        .clipShape(Circle())
        .circularSteelStrokeOverlay(visibleStrokeCount: step.visibleStrokeCount)
    }

    @ViewBuilder
    private var reflectionLayer: some View {
        if step.showsReflection {
            Circle()
                .fill(LinearGradient.reflectionFill)
                .frame(
                    width: ArrowButtonMetrics.reflectionDiameter,
                    height: ArrowButtonMetrics.reflectionDiameter
                )
                .offset(y: ArrowButtonMetrics.reflectionYOffset)
                .blur(radius: step.reflectionBlurRadius)
                .allowsHitTesting(false)
                .transition(.opacity)
        }
    }
}

// MARK: - Tutorial
private struct ArrowButtonPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct ArrowButtonTutorial: View {
    var onOpenDateSelector: (() -> Void)? = nil
    @State private var currentStep: ArrowButtonStep = .base

    var body: some View {
        ZStack {
            Color(red: 93/255, green: 106/255, blue: 114/255)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Group {
                    if currentStep != .complete {
                        Text(currentStep.title)
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(.white)
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 0.2), value: currentStep)
                    } else {
                        Color.clear
                    }
                }
                .frame(height: 28)
                .padding(.top, 72)

                Spacer()

                Group {
                    if currentStep == .complete {
                        Button {
                            HapticsHelper.impactMedium()
                            onOpenDateSelector?()
                        } label: {
                            ArrowButton(step: .complete)
                        }
                        .buttonStyle(ArrowButtonPressStyle())
                        .accessibilityLabel("Arrow button")
                    } else {
                        ArrowButton(step: currentStep)
                            .allowsHitTesting(false)
                    }
                }

                Spacer()

                HStack(spacing: 48) {
                    Button {
                        if let previous = ArrowButtonStep(rawValue: currentStep.rawValue - 1) {
                            currentStep = previous
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(.white.opacity(currentStep == .base ? 0.08 : 0.2)))
                            .foregroundStyle(.white.opacity(currentStep == .base ? 0.3 : 1))
                    }
                    .buttonStyle(.plain)
                    .disabled(currentStep == .base)

                    Button {
                        if let next = ArrowButtonStep(rawValue: currentStep.rawValue + 1) {
                            currentStep = next
                        }
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 18, weight: .semibold))
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(.white.opacity(currentStep == .complete ? 0.08 : 0.2)))
                            .foregroundStyle(.white.opacity(currentStep == .complete ? 0.3 : 1))
                    }
                    .buttonStyle(.plain)
                    .disabled(currentStep == .complete)
                }
                .padding(.bottom, 60)
            }
        }
    }
}

#Preview("Tutorial") {
    ArrowButtonTutorial()
        .accessibilityHidden(true)
}
