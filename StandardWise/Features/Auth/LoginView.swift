import SwiftUI

struct LoginView: View {
    private enum AuthScreen {
        case signIn
        case createAccount
        case forgotPassword
    }

    private enum AuthField {
        case email
        case password
    }

    @ObservedObject var session: AppSession
    @State private var authScreen: AuthScreen = .signIn
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @FocusState private var focusedField: AuthField?

    private var canSubmit: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !password.isEmpty
    }

    private var isBusy: Bool {
        session.isLoggingIn || session.isRegistering || session.isSendingPasswordReset
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    brandHeader

                    Group {
                        switch authScreen {
                        case .signIn:
                            signInForm
                        case .createAccount:
                            createAccountForm
                        case .forgotPassword:
                            forgotPasswordForm
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .trailing)))

                    switchScreenFooter

                    testLoginHelp
                }
                .padding(20)
                .animation(StandardWiseTheme.spring, value: authScreen)
            }
            .background(Color(.systemGroupedBackground))
            .onAppear {
                focusedField = .email
            }
        }
    }

    // MARK: Header

    private var brandHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "graduationcap.fill")
                .font(.system(size: 30))
                .foregroundStyle(StandardWiseTheme.accent)
                .frame(width: 64, height: 64)
                .background(StandardWiseTheme.accentSoft)
                .clipShape(RoundedRectangle(cornerRadius: 18))

            VStack(spacing: 4) {
                Text("StandardWise")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Master your standards, one question at a time")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 24)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("StandardWise. Master your standards, one question at a time.")
    }

    // MARK: Forms

    private var signInForm: some View {
        VStack(spacing: 12) {
            emailField
            passwordField
            authMessages

            Button {
                submitSignIn()
            } label: {
                if session.isLoggingIn {
                    ProgressView().tint(.white)
                } else {
                    Text("Sign in")
                }
            }
            .buttonStyle(StandardWisePrimaryButtonStyle())
            .disabled(!canSubmit || isBusy)
            .accessibilityHint("Signs in to your StandardWise account.")

            Button("Forgot password?") {
                changeScreen(to: .forgotPassword)
            }
            .font(.footnote)
            .tint(StandardWiseTheme.accent)
            .padding(.top, 2)
        }
        .padding(20)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))
    }

    private var createAccountForm: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Create your account")
                    .font(.title3)
                    .fontWeight(.bold)

                Text("Start practicing in under a minute.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            emailField
            passwordField
            passwordStrengthBar
            authMessages

            Button {
                submitCreateAccount()
            } label: {
                if session.isRegistering {
                    ProgressView().tint(.white)
                } else {
                    Text("Create account")
                }
            }
            .buttonStyle(StandardWisePrimaryButtonStyle())
            .disabled(!canSubmit || isBusy)
            .accessibilityHint("Creates a new student account.")
        }
        .padding(20)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))
    }

    private var forgotPasswordForm: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Reset your password")
                    .font(.title3)
                    .fontWeight(.bold)

                Text("Enter your email and we'll send a reset link.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            emailField
            authMessages

            Button {
                Task { await session.sendPasswordReset(email: email) }
            } label: {
                if session.isSendingPasswordReset {
                    ProgressView().tint(.white)
                } else {
                    Text("Send reset email")
                }
            }
            .buttonStyle(StandardWisePrimaryButtonStyle())
            .disabled(email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isBusy)
            .accessibilityHint("Sends a password reset email.")
        }
        .padding(20)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))
    }

    // MARK: Fields

    private var emailField: some View {
        HStack(spacing: 10) {
            Image(systemName: "envelope")
                .foregroundStyle(.secondary)

            TextField("name@school.org", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($focusedField, equals: .email)
                .submitLabel(authScreen == .forgotPassword ? .done : .next)
                .onSubmit {
                    if authScreen == .forgotPassword {
                        Task { await session.sendPasswordReset(email: email) }
                    } else {
                        focusedField = .password
                    }
                }
                .accessibilityLabel("Email address")
        }
        .standardWiseField()
        .overlay {
            RoundedRectangle(cornerRadius: StandardWiseTheme.controlCornerRadius)
                .stroke(focusedField == .email ? StandardWiseTheme.accent : .clear, lineWidth: 1.5)
        }
    }

    private var passwordField: some View {
        HStack(spacing: 10) {
            Image(systemName: "lock")
                .foregroundStyle(.secondary)

            Group {
                if isPasswordVisible {
                    TextField("Password", text: $password)
                } else {
                    SecureField("Password", text: $password)
                }
            }
            .textContentType(.password)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .focused($focusedField, equals: .password)
            .submitLabel(.go)
            .onSubmit {
                if authScreen == .createAccount {
                    submitCreateAccount()
                } else {
                    submitSignIn()
                }
            }
            .accessibilityLabel("Password")

            Button {
                isPasswordVisible.toggle()
            } label: {
                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .accessibilityLabel(isPasswordVisible ? "Hide password" : "Show password")
        }
        .standardWiseField()
        .overlay {
            RoundedRectangle(cornerRadius: StandardWiseTheme.controlCornerRadius)
                .stroke(focusedField == .password ? StandardWiseTheme.accent : .clear, lineWidth: 1.5)
        }
    }

    private var passwordStrengthBar: some View {
        let strength = passwordStrength

        return Group {
            if !password.isEmpty {
                HStack(spacing: 4) {
                    ForEach(0..<3) { index in
                        Capsule()
                            .fill(index < strength.filledSegments ? strength.color : Color(.systemFill))
                            .frame(height: 4)
                    }

                    Text(strength.label)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(strength.color)
                        .padding(.leading, 4)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Password strength: \(strength.label)")
            }
        }
    }

    private var passwordStrength: (filledSegments: Int, label: String, color: Color) {
        let hasLength = password.count >= 6
        let hasLongLength = password.count >= 10
        let hasMixture = password.rangeOfCharacter(from: .decimalDigits) != nil
            && password.rangeOfCharacter(from: .letters) != nil

        if hasLongLength && hasMixture {
            return (3, "Strong", StandardWiseTheme.success)
        }

        if hasLength && (hasMixture || hasLongLength) {
            return (2, "Good", StandardWiseTheme.success)
        }

        if hasLength {
            return (2, "Okay", .orange)
        }

        return (1, "Too short", StandardWiseTheme.danger)
    }

    // MARK: Messages and footer

    private var authMessages: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let message = session.loginErrorMessage {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "info.circle")
                    Text(friendlyErrorMessage(message))
                }
                .font(.footnote)
                .foregroundStyle(StandardWiseTheme.danger)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(StandardWiseTheme.dangerSoft)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .accessibilityLabel("Sign-in problem. \(friendlyErrorMessage(message))")
            }

            if let message = session.authInfoMessage {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "checkmark.circle")
                    Text(message)
                }
                .font(.footnote)
                .foregroundStyle(StandardWiseTheme.success)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(StandardWiseTheme.successSoft)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .accessibilityLabel(message)
            }
        }
    }

    private var switchScreenFooter: some View {
        Group {
            switch authScreen {
            case .signIn:
                footerLink(prompt: "New here?", action: "Create an account") {
                    changeScreen(to: .createAccount)
                }
            case .createAccount, .forgotPassword:
                footerLink(prompt: "Already have an account?", action: "Sign in") {
                    changeScreen(to: .signIn)
                }
            }
        }
    }

    private func footerLink(prompt: String, action: String, onTap: @escaping () -> Void) -> some View {
        HStack(spacing: 4) {
            Text(prompt)
                .foregroundStyle(.secondary)

            Button(action, action: onTap)
                .fontWeight(.semibold)
                .tint(StandardWiseTheme.accent)
        }
        .font(.footnote)
    }

    private var testLoginHelp: some View {
        Group {
            #if DEBUG
            VStack(alignment: .leading, spacing: 6) {
                Text("\(LocalAuthService.modeTitle) test logins")
                    .font(.headline)

                ForEach(LocalAuthService.loginHelpLines, id: \.self) { line in
                    Text(line)
                }
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            #endif
        }
    }

    // MARK: Actions

    private func changeScreen(to screen: AuthScreen) {
        authScreen = screen
        session.loginErrorMessage = nil
        session.authInfoMessage = nil
        focusedField = .email
    }

    private func submitSignIn() {
        guard canSubmit, !isBusy else { return }
        Task { await session.login(email: email, password: password) }
    }

    private func submitCreateAccount() {
        guard canSubmit, !isBusy else { return }
        Task { await session.register(email: email, password: password) }
    }

    private func friendlyErrorMessage(_ message: String) -> String {
        switch message {
        case "An account already exists for this email.":
            return "That email already has an account. Try signing in instead."
        case "No username exists.":
            return "We couldn't find that account. Check the email or create an account."
        case "Wrong password.":
            return "That password doesn't match. Try again or reset it below."
        default:
            return message
        }
    }
}
