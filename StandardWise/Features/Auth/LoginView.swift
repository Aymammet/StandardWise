import SwiftUI

struct LoginView: View {
    @ObservedObject var session: AppSession
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false

    private var canSubmit: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !password.isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("StandardWise")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Log in to continue.")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)
                        .accessibilityLabel("Email address")
                        .accessibilityHint("Enter the email for your StandardWise account.")

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

                    if let message = session.loginErrorMessage {
                        Label(message, systemImage: "exclamationmark.triangle.fill")
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .accessibilityLabel("Login error. \(message)")
                    }

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
                    .accessibilityHint("Logs in with the email and password entered above.")
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))

                VStack(alignment: .leading, spacing: 6) {
                    Text("\(LocalAuthService.modeTitle) test logins")
                        .font(.headline)

                    ForEach(LocalAuthService.loginHelpLines, id: \.self) { line in
                        Text(line)
                    }
                }
                .font(.footnote)
                .foregroundStyle(.secondary)

                Spacer()
            }
            .padding()
        }
    }
}
