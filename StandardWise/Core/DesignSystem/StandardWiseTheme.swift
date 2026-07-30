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

/// Shared brand mark: a rounded "SW" badge with a purple gradient and sparkle
/// accent, matching the app icon design. Used on the login screen and the
/// practice screen's top bar so the brand looks the same everywhere.
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
