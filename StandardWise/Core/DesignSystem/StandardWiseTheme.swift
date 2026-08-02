import SwiftUI
import UIKit

enum StandardWiseTheme {
    // MARK: Brand colors

    /// Primary brand accent used for student-facing controls and highlights.
    /// Matches the app icon's navy badge (question mark + checkmark mark).
    static let accent = Color(red: 30.0 / 255.0, green: 33.0 / 255.0, blue: 78.0 / 255.0)
    static let accentSoft = Color(red: 30.0 / 255.0, green: 33.0 / 255.0, blue: 78.0 / 255.0).opacity(0.12)
    /// Gold checkmark accent from the app icon, for small highlights that want to echo the icon.
    static let iconGold = Color(red: 215.0 / 255.0, green: 158.0 / 255.0, blue: 56.0 / 255.0)
    static let success = Color(red: 0.11, green: 0.62, blue: 0.46)
    static let successSoft = Color(red: 0.11, green: 0.62, blue: 0.46).opacity(0.14)
    static let danger = Color(red: 0.85, green: 0.29, blue: 0.29)
    static let dangerSoft = Color(red: 0.85, green: 0.29, blue: 0.29).opacity(0.12)
    static let warning = Color(red: 0.91, green: 0.58, blue: 0.16)
    static let warningSoft = Color(red: 0.91, green: 0.58, blue: 0.16).opacity(0.14)

    // MARK: Adaptive surfaces

    static let pageBackground = Color(.systemGroupedBackground)
    static let cardBackground = Color(.secondarySystemGroupedBackground)
    static let raisedCardBackground = Color(.systemBackground)
    static let subtleBorder = Color(.separator).opacity(0.55)

    // MARK: Shape and elevation

    static let cardCornerRadius: CGFloat = 12
    static let controlCornerRadius: CGFloat = 12
    static let cardShadowColor = Color.black.opacity(0.08)
    static let cardShadowRadius: CGFloat = 10
    static let cardShadowYOffset: CGFloat = 4

    // MARK: Motion

    static let spring = Animation.spring(response: 0.35, dampingFraction: 0.75)
}

// MARK: - Shared student-facing styles

/// Full-width brand button used for primary student actions.
struct StandardWisePrimaryButtonStyle: ButtonStyle {
    var background: Color = StandardWiseTheme.accent

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(background.opacity(configuration.isPressed ? 0.85 : 1))
            .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.controlCornerRadius))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// Rounded input container used for auth and typed-answer fields.
struct StandardWiseFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(StandardWiseTheme.raisedCardBackground)
            .overlay {
                RoundedRectangle(cornerRadius: StandardWiseTheme.controlCornerRadius)
                    .stroke(StandardWiseTheme.subtleBorder, lineWidth: 0.5)
            }
            .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.controlCornerRadius))
    }
}

/// Shared question-and-check brand mark matching the app icon design.
/// Used on the login screen so the brand looks consistent at launch.
struct StandardWiseLogoMark: View {
    var size: CGFloat = 44
    var cornerRadius: CGFloat? = nil

    private var radius: CGFloat { cornerRadius ?? size * 0.28 }

    var body: some View {
        Image("LogoMark")
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .accessibilityHidden(true)
    }
}

/// Just the question-mark-and-checkmark glyph from the app icon, with no
/// background badge. Used inline next to text (e.g. the practice home
/// greeting card) where a boxed logo mark would be too heavy.
struct StandardWiseGlyphMark: View {
    var size: CGFloat = 34

    var body: some View {
        ZStack {
            StandardWiseHookShape()
                .stroke(StandardWiseTheme.accent, style: StrokeStyle(lineWidth: size * 0.11, lineCap: .round, lineJoin: .round))

            Circle()
                .fill(StandardWiseTheme.accent)
                .frame(width: size * 0.11, height: size * 0.11)
                .position(x: size * 0.28, y: size * 0.34)

            StandardWiseCheckShape()
                .stroke(StandardWiseTheme.iconGold, style: StrokeStyle(lineWidth: size * 0.11, lineCap: .round, lineJoin: .round))
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

private struct StandardWiseHookShape: Shape {
    func path(in rect: CGRect) -> Path {
        let s = rect.width / 100
        var path = Path()
        path.move(to: CGPoint(x: 28 * s, y: 34 * s))
        path.addCurve(
            to: CGPoint(x: 58 * s, y: 16 * s),
            control1: CGPoint(x: 28 * s, y: 18 * s),
            control2: CGPoint(x: 44 * s, y: 10 * s)
        )
        path.addCurve(
            to: CGPoint(x: 60 * s, y: 46 * s),
            control1: CGPoint(x: 72 * s, y: 22 * s),
            control2: CGPoint(x: 74 * s, y: 40 * s)
        )
        path.addCurve(
            to: CGPoint(x: 50 * s, y: 62 * s),
            control1: CGPoint(x: 52 * s, y: 49 * s),
            control2: CGPoint(x: 50 * s, y: 54 * s)
        )
        return path
    }
}

private struct StandardWiseCheckShape: Shape {
    func path(in rect: CGRect) -> Path {
        let s = rect.width / 100
        var path = Path()
        path.move(to: CGPoint(x: 38 * s, y: 78 * s))
        path.addLine(to: CGPoint(x: 48 * s, y: 90 * s))
        path.addLine(to: CGPoint(x: 70 * s, y: 62 * s))
        return path
    }
}

struct StandardWiseSkeletonBlock: View {
    var width: CGFloat? = nil
    var height: CGFloat = 14
    var cornerRadius: CGFloat = 7

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color(.systemFill).opacity(0.55))
            .frame(width: width, height: height)
            .redacted(reason: .placeholder)
            .accessibilityHidden(true)
    }
}

struct StandardWiseEmptyState: View {
    let systemImage: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(StandardWiseTheme.accent)
                .frame(width: 62, height: 62)
                .background(StandardWiseTheme.accentSoft)
                .clipShape(Circle())

            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.footnote.weight(.semibold))
                    .buttonStyle(.bordered)
                    .tint(StandardWiseTheme.accent)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .padding(.horizontal, 16)
        .background(StandardWiseTheme.cardBackground)
        .overlay {
            RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius)
                .stroke(StandardWiseTheme.subtleBorder, lineWidth: 0.5)
        }
        .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))
        .accessibilityElement(children: .combine)
    }
}

extension View {
    func standardWiseField() -> some View {
        modifier(StandardWiseFieldModifier())
    }
}

/// Toolbar sign-out control with a confirmation dialog so accidental taps
/// don't end the session.
struct StandardWiseSignOutButton: View {
    let onSignOut: () -> Void

    @State private var isConfirming = false

    var body: some View {
        Button {
            isConfirming = true
        } label: {
            Image(systemName: "rectangle.portrait.and.arrow.right")
                .fontWeight(.semibold)
        }
        .tint(StandardWiseTheme.accent)
        .accessibilityLabel("Sign out")
        .accessibilityHint("Shows a confirmation before signing out.")
        .confirmationDialog(
            "Sign out of StandardWise?",
            isPresented: $isConfirming,
            titleVisibility: .visible
        ) {
            Button("Sign out", role: .destructive) {
                onSignOut()
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your progress is saved. You can sign back in anytime.")
        }
    }
}

enum StandardWiseHaptics {
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
