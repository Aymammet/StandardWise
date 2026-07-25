import SwiftUI
import UIKit

enum StandardWiseTheme {
    // MARK: Brand colors

    /// Primary brand accent used for student-facing controls and highlights.
    static let accent = Color(red: 0.36, green: 0.32, blue: 0.78)
    static let accentSoft = Color(red: 0.36, green: 0.32, blue: 0.78).opacity(0.12)
    static let success = Color(red: 0.11, green: 0.62, blue: 0.46)
    static let successSoft = Color(red: 0.11, green: 0.62, blue: 0.46).opacity(0.14)
    static let danger = Color(red: 0.85, green: 0.29, blue: 0.29)
    static let dangerSoft = Color(red: 0.85, green: 0.29, blue: 0.29).opacity(0.12)

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
            .background(Color(.systemBackground))
            .overlay {
                RoundedRectangle(cornerRadius: StandardWiseTheme.controlCornerRadius)
                    .stroke(Color(.separator), lineWidth: 0.5)
            }
            .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.controlCornerRadius))
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
