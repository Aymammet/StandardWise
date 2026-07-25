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
    @State private var emptyMessage = "Choose a subject, grade, and standard, then tap Generate Question."

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
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Practice by standard")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Pick what you want to practice, then generate one question at a time.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        LabeledMenuSelector(
                            title: "Subject",
                            selection: $selectedSubject,
                            options: subjects
                        )
                        .onChange(of: selectedSubject) { _, _ in
                            selectedStandardCode = filteredStandards.first?.code ?? ""
                            currentProblem = nil
                            emptyMessage = "Choose a subject, grade, and standard, then tap Generate Question."
                        }

                        LabeledMenuSelector(
                            title: "Grade",
                            selection: $selectedGrade,
                            options: grades
                        )
                        .onChange(of: selectedGrade) { _, _ in
                            selectedStandardCode = filteredStandards.first?.code ?? ""
                            currentProblem = nil
                            emptyMessage = "Choose a subject, grade, and standard, then tap Generate Question."
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
                                .accessibilityLabel("No standards are available for this subject and grade yet.")
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
                            Text("Generate Question")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .disabled(selectedStandardCode.isEmpty)
                        .accessibilityHint("Creates one practice question for the selected subject, grade, and standard.")
                    }
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))

                    if let problem = currentProblem {
                        ProblemCard(
                            user: user,
                            problem: problem,
                            standard: standardStore.standards.first { $0.id == problem.standardID }
                                ?? standardStore.standards.first { $0.code == problem.standardCode },
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
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Practice")
            .toolbar {
                if let onLogout {
                    Button("Logout", action: onLogout)
                        .accessibilityHint("Logs out and returns to the login screen.")
                }
            }
            .onAppear {
                alignSelectionWithAvailableStandards()
            }
            .onChange(of: standardStore.subjects) { _, _ in
                alignSelectionWithAvailableStandards()
            }
            .onChange(of: standardStore.grades) { _, _ in
                alignSelectionWithAvailableStandards()
            }
            .onChange(of: standardStore.standards) { _, _ in
                alignSelectionWithAvailableStandards()
            }
        }
    }

    private func alignSelectionWithAvailableStandards() {
        if !subjects.contains(selectedSubject) {
            selectedSubject = subjects.first ?? ""
        }

        if !grades.contains(selectedGrade) {
            selectedGrade = grades.first ?? ""
        }

        if filteredStandards.contains(where: { $0.code == selectedStandardCode }) {
            return
        }

        if let matchingStandard = standards.first(where: { $0.subjectName == selectedSubject }) {
            selectedGrade = matchingStandard.gradeName
            selectedStandardCode = matchingStandard.code
        } else if let firstStandard = standards.first {
            selectedSubject = firstStandard.subjectName
            selectedGrade = firstStandard.gradeName
            selectedStandardCode = firstStandard.code
        } else {
            selectedStandardCode = ""
        }

        currentProblem = nil
        emptyMessage = "Choose a subject, grade, and standard, then tap Generate Question."
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
            .accessibilityElement(children: .combine)
            .accessibilityLabel(title)
            .accessibilityValue(displayText(selection))
            .accessibilityHint("Opens a list of available \(title.lowercased()) options.")
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
                    Text("Answer choices")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .accessibilityAddTraits(.isHeader)

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

                                if let status = choiceStatus(choice) {
                                    Label(status.text, systemImage: status.systemImage)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(status.color)
                                        .labelStyle(.titleAndIcon)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                            .background(choiceBackground(choice))
                            .overlay {
                                RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius)
                                    .stroke(choiceBorderColor(choice), lineWidth: choice.id == selectedChoiceID ? 2 : 1)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))
                        }
                        .buttonStyle(.plain)
                        .disabled(answerResult != nil)
                        .accessibilityLabel("Choice \(choice.id), \(choice.text)")
                        .accessibilityValue(choiceAccessibilityValue(choice))
                        .accessibilityHint(answerResult == nil ? "Selects this answer choice." : "Answer choices are locked after checking your answer.")
                    }
                }
            } else {
                TextField("Type your answer here", text: $typedAnswer)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .disabled(answerResult != nil)
                    .accessibilityLabel("Answer")
                    .accessibilityHint("Type your answer before checking it.")
            }

            Button {
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
            } label: {
                Text("Check Answer")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .frame(maxWidth: .infinity)
            .disabled(!hasAnswer || answerResult != nil)
            .accessibilityHint("Checks your answer and shows the explanation.")

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
                .overlay {
                    RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius)
                        .stroke(answerResult.isCorrect ? Color.green.opacity(0.35) : Color.red.opacity(0.35), lineWidth: 1)
                }
                .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))
                .accessibilityElement(children: .combine)
                .accessibilityLabel(answerResult.isCorrect ? "Correct answer." : "Incorrect answer.")
                .accessibilityValue(problem.type == .input ? "Correct answer: \(problem.correctAnswer). Explanation: \(problem.explanation)" : "Explanation: \(problem.explanation)")
            }

            Button {
                isShowingFeedbackForm = true
            } label: {
                Label(didSubmitFeedback ? "Feedback Sent" : "Send Feedback", systemImage: "bubble.left")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .frame(maxWidth: .infinity, alignment: .leading)
            .disabled(didSubmitFeedback)
            .accessibilityHint(didSubmitFeedback ? "Feedback has already been sent for this question." : "Opens a form to send feedback about this question.")
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

    private func choiceBorderColor(_ choice: AnswerChoice) -> Color {
        guard answerResult != nil else {
            return choice.id == selectedChoiceID ? Color.blue.opacity(0.65) : Color(.separator)
        }

        if choice.id == problem.correctAnswer {
            return Color.green.opacity(0.7)
        }

        if choice.id == selectedChoiceID {
            return Color.red.opacity(0.7)
        }

        return Color(.separator)
    }

    private func choiceStatus(_ choice: AnswerChoice) -> ChoiceStatus? {
        guard let answerResult else {
            return choice.id == selectedChoiceID ? ChoiceStatus(text: "Selected", systemImage: "checkmark.circle", color: .blue) : nil
        }

        if choice.id == problem.correctAnswer {
            return ChoiceStatus(text: "Correct answer", systemImage: "checkmark.circle.fill", color: .green)
        }

        if choice.id == selectedChoiceID && !answerResult.isCorrect {
            return ChoiceStatus(text: "Your answer", systemImage: "xmark.circle.fill", color: .red)
        }

        return nil
    }

    private func choiceAccessibilityValue(_ choice: AnswerChoice) -> String {
        guard let status = choiceStatus(choice) else {
            return "Not selected"
        }

        return status.text
    }
}

private struct ChoiceStatus {
    let text: String
    let systemImage: String
    let color: Color
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
                    TextField("Describe the issue or suggestion", text: $message, axis: .vertical)
                        .lineLimit(4...8)
                        .accessibilityLabel("Feedback message")
                        .accessibilityHint("Tell the admin what is confusing or incorrect about this question.")
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
                    .disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
            Label("Ready when you are", systemImage: "sparkle.magnifyingglass")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))
    }
}
