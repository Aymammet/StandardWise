import SwiftUI

struct PracticeView: View {
    let user: StandardWiseUser
    @ObservedObject var questionStore: QuestionStore
    @ObservedObject var standardStore: StandardStore
    @ObservedObject var feedbackStore: FeedbackStore
    @ObservedObject var answerAttemptStore: AnswerAttemptStore
    var onLogout: (() -> Void)?

    @State private var selectedSubject = "Math"
    @State private var selectedGrade = "6th"
    @State private var selectedStandardCode = "6.RP.1"
    @State private var currentProblem: Question?
    @State private var emptyMessage = "Choose a subject, grade, and standard, then tap Generate."

    private var subjects: [String] {
        standardStore.activeSubjects.map(\.name)
    }

    private var grades: [String] {
        standardStore.grades.map(\.name)
    }

    private var standards: [LearningStandard] {
        standardStore.activeStandards
    }

    private var filteredStandards: [LearningStandard] {
        standards.filter { standard in
            standard.gradeName == selectedGrade && standard.subjectName == selectedSubject
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Generate practice problems by Ohio standard.")
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        LabeledMenuSelector(
                            title: "Subject",
                            selection: $selectedSubject,
                            options: subjects
                        )
                        .onChange(of: selectedSubject) { _, _ in
                            selectedStandardCode = filteredStandards.first?.code ?? ""
                            currentProblem = nil
                            emptyMessage = "Choose a subject, grade, and standard, then tap Generate."
                        }

                        LabeledMenuSelector(
                            title: "Grade",
                            selection: $selectedGrade,
                            options: grades
                        )
                        .onChange(of: selectedGrade) { _, _ in
                            selectedStandardCode = filteredStandards.first?.code ?? ""
                            currentProblem = nil
                            emptyMessage = "Choose a subject, grade, and standard, then tap Generate."
                        }

                        LabeledMenuSelector(
                            title: "Standard",
                            selection: $selectedStandardCode,
                            options: filteredStandards.map(\.code),
                            displayText: { code in
                                filteredStandards.first { $0.code == code }?.displayName ?? code
                            }
                        )
                        .disabled(filteredStandards.isEmpty)

                        if filteredStandards.isEmpty {
                            Text("No standards are available for this subject and grade yet.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }

                        Button {
                            currentProblem = ProblemGenerator.generate(
                                subject: selectedSubject,
                                grade: selectedGrade,
                                standardCode: selectedStandardCode,
                                questions: questionStore.questions,
                                standards: standardStore.standards
                            )
                            emptyMessage = "No questions are available for this standard yet."
                        } label: {
                            Text("Generate")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(selectedStandardCode.isEmpty)
                    }
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))

                    if let problem = currentProblem {
                        ProblemCard(
                            user: user,
                            problem: problem,
                            standard: standardStore.standards.first { $0.id == problem.standardID },
                            feedbackStore: feedbackStore,
                            answerAttemptStore: answerAttemptStore
                        )
                            .id(problem.id)
                    } else {
                        EmptyProblemView(message: emptyMessage)
                    }
                }
                .padding()
            }
            .navigationTitle("StandardWise")
            .toolbar {
                if let onLogout {
                    Button("Logout", action: onLogout)
                }
            }
        }
    }
}

private struct LabeledMenuSelector: View {
    let title: String
    @Binding var selection: String
    let options: [String]
    var displayText: (String) -> String = { $0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)

            Menu {
                ForEach(options, id: \.self) { option in
                    Button {
                        selection = option
                    } label: {
                        if option == selection {
                            Label(displayText(option), systemImage: "checkmark")
                        } else {
                            Text(displayText(option))
                        }
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    Text(displayText(selection))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .truncationMode(.tail)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(Color(.secondarySystemBackground))
                .overlay {
                    RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius)
                        .stroke(Color(.separator), lineWidth: 1)
                }
                .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))
            }
            .buttonStyle(.plain)
        }
    }
}

private struct ProblemCard: View {
    let user: StandardWiseUser
    let problem: Question
    let standard: LearningStandard?
    @ObservedObject var feedbackStore: FeedbackStore
    @ObservedObject var answerAttemptStore: AnswerAttemptStore
    @State private var selectedChoiceID: String?
    @State private var typedAnswer = ""
    @State private var answerResult: AnswerResult?
    @State private var isShowingFeedbackForm = false
    @State private var didSubmitFeedback = false

    private var hasAnswer: Bool {
        switch problem.type {
        case .multipleChoice:
            return selectedChoiceID != nil
        case .input:
            return !typedAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    private var submittedAnswer: String {
        switch problem.type {
        case .multipleChoice:
            return selectedChoiceID ?? ""
        case .input:
            return typedAnswer
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(problem.standardCode)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue)

                Text(problem.prompt)
                    .font(.title3)
                    .fontWeight(.semibold)
            }

            if problem.type == .multipleChoice {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(problem.choices) { choice in
                        Button {
                            guard answerResult == nil else { return }
                            selectedChoiceID = choice.id
                        } label: {
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text(choice.id)
                                    .fontWeight(.semibold)
                                Text(choice.text)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .background(choiceBackground(choice))
                            .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))
                        }
                        .buttonStyle(.plain)
                        .disabled(answerResult != nil)
                    }
                }
            } else {
                TextField("Enter your answer", text: $typedAnswer)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .disabled(answerResult != nil)
            }

            Button("Check Answer") {
                let result = AnswerChecker.check(answer: submittedAnswer, for: problem)
                answerResult = result
                answerAttemptStore.record(
                    AnswerAttempt(
                        userID: user.id,
                        questionID: problem.id,
                        subjectName: standard?.subjectName ?? "Unknown",
                        gradeName: standard?.gradeName ?? "Unknown",
                        standardCode: problem.standardCode,
                        submittedAnswer: submittedAnswer,
                        isCorrect: result.isCorrect
                    )
                )
            }
            .buttonStyle(.borderedProminent)
            .disabled(!hasAnswer || answerResult != nil)

            if let answerResult {
                VStack(alignment: .leading, spacing: 10) {
                    Label(
                        answerResult.isCorrect ? "Correct" : "Incorrect",
                        systemImage: answerResult.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill"
                    )
                    .font(.headline)
                    .foregroundStyle(answerResult.isCorrect ? .green : .red)

                    if problem.type == .input {
                        Text("Correct answer: \(problem.correctAnswer)")
                            .fontWeight(.semibold)
                    }

                    Text("Explanation")
                        .font(.headline)
                    Text(problem.explanation)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(answerResult.isCorrect ? Color.green.opacity(0.12) : Color.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))
            }

            Button {
                isShowingFeedbackForm = true
            } label: {
                Label(didSubmitFeedback ? "Feedback Sent" : "Send Feedback", systemImage: "bubble.left")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(didSubmitFeedback)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))
        .shadow(
            color: StandardWiseTheme.cardShadowColor,
            radius: StandardWiseTheme.cardShadowRadius,
            y: StandardWiseTheme.cardShadowYOffset
        )
        .sheet(isPresented: $isShowingFeedbackForm) {
            FeedbackFormView(question: problem) { message in
                feedbackStore.submitFeedback(
                    userID: user.id,
                    questionID: problem.id,
                    message: message
                )
                didSubmitFeedback = true
            }
        }
    }

    private func choiceBackground(_ choice: AnswerChoice) -> Color {
        guard let answerResult else {
            return choice.id == selectedChoiceID ? Color.blue.opacity(0.15) : Color(.secondarySystemBackground)
        }

        if choice.id == problem.correctAnswer {
            return Color.green.opacity(0.18)
        }

        if choice.id == selectedChoiceID && !answerResult.isCorrect {
            return Color.red.opacity(0.16)
        }

        return Color(.secondarySystemBackground)
    }
}

private struct FeedbackFormView: View {
    @Environment(\.dismiss) private var dismiss

    let question: Question
    let onSubmit: (String) -> Void

    @State private var message = ""
    @State private var validationMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Question") {
                    Text(question.standardCode)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                    Text(question.prompt)
                }

                Section("Feedback") {
                    TextField("What should admin know?", text: $message, axis: .vertical)
                        .lineLimit(4...8)
                }

                if let validationMessage {
                    Section {
                        Text(validationMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Send Feedback")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Send") {
                        submit()
                    }
                }
            }
        }
    }

    private func submit() {
        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else {
            validationMessage = "Feedback message is required."
            return
        }

        onSubmit(trimmedMessage)
        dismiss()
    }
}

private struct AnswerResult {
    let isCorrect: Bool
}

private enum AnswerChecker {
    static func check(answer: String, for question: Question) -> AnswerResult {
        let normalizedAnswer = normalize(answer)
        let acceptedAnswers = ([question.correctAnswer] + question.acceptedAlternateAnswers).map(normalize)

        return AnswerResult(isCorrect: acceptedAnswers.contains(normalizedAnswer))
    }

    private static func normalize(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "")
            .lowercased()
    }
}

private struct EmptyProblemView: View {
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ready when you are")
                .font(.headline)
            Text(message)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))
    }
}
