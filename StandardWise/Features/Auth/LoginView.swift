import SwiftUI

struct LoginView: View {
    private enum AuthScreen {
        case welcome
        case login
        case register
        case forgotPassword
    }

    @ObservedObject var session: AppSession
    @State private var authScreen: AuthScreen = .welcome
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false

    private var canSubmit: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !password.isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerView

                    switch authScreen {
                    case .welcome:
                        welcomeActions
                    case .login:
                        loginForm
                    case .register:
                        registerForm
                    case .forgotPassword:
                        forgotPasswordForm
                    }

                    testLoginHelp
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
        }
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("StandardWise")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Practice standards-based questions, get instant answer feedback, and help admins manage learning standards, questions, feedback, and student progress.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 12)
    }

    private var welcomeActions: some View {
        VStack(spacing: 12) {
            Button {
                authScreen = .login
            } label: {
                Label("Login", systemImage: "person.crop.circle")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Button {
                authScreen = .register
            } label: {
                Label("Register", systemImage: "person.badge.plus")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

            Button {
                authScreen = .forgotPassword
            } label: {
                Text("Forgot password?")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .padding(.vertical, 8)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))
    }

    private var loginForm: some View {
        authCard(title: "Login", subtitle: "Enter your email and password to continue.") {
            emailField
            passwordField
            authMessages

            Button {
                Task {
                    await session.login(email: email, password: password)
                }
            } label: {
                if session.isLoggingIn {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Login")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!canSubmit || session.isLoggingIn)

            secondaryAuthButtons
        }
    }

    private var registerForm: some View {
        authCard(title: "Register", subtitle: "Create a regular student account.") {
            emailField
            passwordField
            authMessages

            Button {
                Task {
                    await session.register(email: email, password: password)
                }
            } label: {
                if session.isRegistering {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Create Account")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!canSubmit || session.isRegistering)

            secondaryAuthButtons
        }
    }

    private var forgotPasswordForm: some View {
        authCard(title: "Forgot Password", subtitle: "Enter your email and we will send a reset link.") {
            emailField
            authMessages

            Button {
                Task {
                    await session.sendPasswordReset(email: email)
                }
            } label: {
                if session.isSendingPasswordReset {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Send Reset Email")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || session.isSendingPasswordReset)

            secondaryAuthButtons
        }
    }

    private func authCard<Content: View>(
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)

                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            content()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))
    }

    private var emailField: some View {
        TextField("Email", text: $email)
            .textContentType(.emailAddress)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .textFieldStyle(.roundedBorder)
            .accessibilityLabel("Email address")
            .accessibilityHint("Enter the email for your StandardWise account.")
    }

    private var passwordField: some View {
        HStack(spacing: 8) {
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
            .accessibilityLabel("Password")
            .accessibilityHint("Enter your account password.")

            Button {
                isPasswordVisible.toggle()
            } label: {
                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .accessibilityLabel(isPasswordVisible ? "Hide password" : "Show password")
            .accessibilityHint(isPasswordVisible ? "Hides the password characters." : "Shows the password characters.")
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .background(Color(.systemBackground))
        .overlay {
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(.separator), lineWidth: 0.5)
        }
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private var authMessages: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let message = session.loginErrorMessage {
                Label(message, systemImage: "exclamationmark.triangle.fill")
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .accessibilityLabel("Authentication error. \(message)")
            }

            if let message = session.authInfoMessage {
                Label(message, systemImage: "checkmark.circle.fill")
                    .font(.footnote)
                    .foregroundStyle(.green)
                    .accessibilityLabel(message)
            }
        }
    }

    private var secondaryAuthButtons: some View {
        HStack {
            Button("Back") {
                authScreen = .welcome
            }

            Spacer()

            if authScreen != .forgotPassword {
                Button("Forgot password?") {
                    authScreen = .forgotPassword
                }
            }
        }
        .font(.footnote)
    }

    private var testLoginHelp: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(LocalAuthService.modeTitle) test logins")
                .font(.headline)

            ForEach(LocalAuthService.loginHelpLines, id: \.self) { line in
                Text(line)
            }
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
    }
}
