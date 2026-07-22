import SwiftUI

struct AdminDashboardView: View {
    let user: StandardWiseUser
    let onLogout: () -> Void

    private let questions = QuestionBank.sampleQuestions
    private let standards = LearningStandard.sampleStandards
    private let users = LocalAuthService.sampleUsers

    private var multipleChoiceCount: Int {
        questions.filter { $0.type == .multipleChoice }.count
    }

    private var inputAnswerCount: Int {
        questions.filter { $0.type == .input }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ],
                        spacing: 12
                    ) {
                        AdminMetricCard(
                            title: "Questions",
                            value: "\(questions.count)",
                            subtitle: "\(multipleChoiceCount) multiple choice"
                        )
                        AdminMetricCard(
                            title: "Standards",
                            value: "\(standards.count)",
                            subtitle: "Ready for practice"
                        )
                        AdminMetricCard(
                            title: "Users",
                            value: "\(users.count)",
                            subtitle: "Local sample users"
                        )
                        AdminMetricCard(
                            title: "Input Answers",
                            value: "\(inputAnswerCount)",
                            subtitle: "Typed response items"
                        )
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Admin Areas")
                            .font(.title3)
                            .fontWeight(.semibold)

                        VStack(spacing: 10) {
                            AdminNavigationRow(
                                title: "Questions",
                                subtitle: "Review, add, and edit practice questions",
                                systemImage: "questionmark.square",
                                destination: AdminPlaceholderView(
                                    title: "Questions",
                                    message: "Question management starts in Step 9."
                                )
                            )
                            AdminNavigationRow(
                                title: "Standards",
                                subtitle: "Manage subject, grade, and standard data",
                                systemImage: "list.bullet.rectangle",
                                destination: AdminPlaceholderView(
                                    title: "Standards",
                                    message: "Standards management starts in Step 10."
                                )
                            )
                            AdminNavigationRow(
                                title: "Users",
                                subtitle: "See user roles and future progress summaries",
                                systemImage: "person.2",
                                destination: AdminPlaceholderView(
                                    title: "Users",
                                    message: "User tracking starts in Step 12."
                                )
                            )
                            AdminNavigationRow(
                                title: "Feedback",
                                subtitle: "Read student reports and question notes",
                                systemImage: "bubble.left.and.bubble.right",
                                destination: AdminPlaceholderView(
                                    title: "Feedback",
                                    message: "Feedback review starts in Step 11."
                                )
                            )
                            AdminNavigationRow(
                                title: "Analytics",
                                subtitle: "Analyze standards, accuracy, and activity",
                                systemImage: "chart.bar",
                                destination: AdminPlaceholderView(
                                    title: "Analytics",
                                    message: "Analytics starts in Step 14."
                                )
                            )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Admin")
            .toolbar {
                Button("Logout", action: onLogout)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome, \(user.name)")
                .font(.title2)
                .fontWeight(.bold)

            Text("Use this dashboard to manage content, review users, and prepare analytics as each admin tool is added.")
                .foregroundStyle(.secondary)
        }
    }
}

private struct AdminMetricCard: View {
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.largeTitle)
                .fontWeight(.bold)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))
    }
}

private struct AdminNavigationRow<Destination: View>: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let destination: Destination

    var body: some View {
        NavigationLink {
            destination
        } label: {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.title3)
                    .foregroundStyle(.blue)
                    .frame(width: 32, height: 32)
                    .background(Color.blue.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))
        }
        .buttonStyle(.plain)
    }
}

private struct AdminPlaceholderView: View {
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
            Text(message)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .navigationTitle(title)
    }
}
