import SwiftUI
import UIKit

struct PracticeView: View {
    private enum PracticeScreen {
        case home
        case session
        case summary
    }

    let user: StandardWiseUser
    @ObservedObject var questionStore: QuestionStore
    @ObservedObject var standardStore: StandardStore
    @ObservedObject var feedbackStore: FeedbackStore
    @ObservedObject var answerAttemptStore: AnswerAttemptStore
    var onLogout: (() -> Void)?

    @State private var screen: PracticeScreen = .home
    @State private var selectedSubject = "Math"
    @State private var selectedGrade = "6th"
    @State private var selectedStandardCode = "6.RP.1"
    @State private var sessionQuestions: [Question] = []
    @State private var sessionIndex = 0
    @State private var sessionResults: [Bool] = []

    private static let dailyGoal = 5

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

    private var selectedStandard: LearningStandard? {
        filteredStandards.first { $0.code == selectedStandardCode }
    }

    private var availableQuestions: [Question] {
        QuestionBank.questions(
            in: questionStore.questions,
            standards: standardStore.standards,
            subject: selectedSubject,
            grade: selectedGrade,
            standardCode: selectedStandardCode
        )
    }

    private var userAttempts: [AnswerAttempt] {
        answerAttemptStore.attempts(for: user.id)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                Group {
                    switch screen {
                    case .home:
                        homeContent
                    case .session:
                        sessionContent
                    case .summary:
                        summaryContent
                    }
                }
                .padding()
                .animation(StandardWiseTheme.spring, value: screen)
                .animation(StandardWiseTheme.spring, value: sessionIndex)
            }
            .background(StandardWiseTheme.pageBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { practiceToolbarContent }
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

    // MARK: - Brand

    @ToolbarContentBuilder
    private var practiceToolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            brandTitle
        }

        if screen == .home, let onLogout {
            ToolbarItem {
                StandardWiseSignOutButton(onSignOut: onLogout)
            }
        }
    }

    private var brandTitle: some View {
        Text("StandardWise")
            .font(.headline)
            .fontWeight(.bold)
            .accessibilityLabel("StandardWise")
    }

    // MARK: - Home

    private var homeContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            greetingHeader
            if isPracticeDataLoading {
                practiceSkeleton
            }
            subjectPicker
            gradePicker
            standardPicker
            startButton
            todaySummarySection
        }
    }

    private var greetingHeader: some View {
        HStack(spacing: 12) {
            Text(userInitials)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(
                    LinearGradient(
                        colors: [StandardWiseTheme.accent, Color(red: 0.52, green: 0.42, blue: 0.92)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text("Hi \(firstName)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(homeHeadline)
                    .font(.title2)
                    .fontWeight(.bold)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding()
        .background(StandardWiseTheme.raisedCardBackground)
        .overlay {
            RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius)
                .stroke(StandardWiseTheme.subtleBorder, lineWidth: 0.5)
        }
        .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))
        .accessibilityElement(children: .combine)
    }

    private var todaySummarySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Today")
                .font(.subheadline)
                .fontWeight(.semibold)

            if todayStandardSummaries.isEmpty {
                StandardWiseEmptyState(
                    systemImage: "chart.bar.doc.horizontal",
                    title: "No practice yet today",
                    message: "Generate a question above and today's score by standard will show up here."
                )
            } else {
                VStack(spacing: 8) {
                    ForEach(todayStandardSummaries) { summary in
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(summary.subjectName) \(summary.standardCode)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)

                                Text("\(summary.correct)/\(summary.total) correct")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text("\(summary.percent)%")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(percentColor(for: summary.percent))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(percentColor(for: summary.percent).opacity(0.14))
                                .clipShape(Capsule())
                        }
                        .padding()
                        .background(StandardWiseTheme.raisedCardBackground)
                        .overlay {
                            RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius)
                                .stroke(StandardWiseTheme.subtleBorder, lineWidth: 0.5)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel(
                            "\(summary.subjectName) \(summary.standardCode): \(summary.correct) of \(summary.total) correct, \(summary.percent) percent."
                        )
                    }
                }
            }
        }
    }

    private var practiceSkeleton: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                StandardWiseSkeletonBlock(width: 120, height: 14)
                Spacer()
                StandardWiseSkeletonBlock(width: 52, height: 14)
            }

            HStack(spacing: 10) {
                StandardWiseSkeletonBlock(height: 54, cornerRadius: StandardWiseTheme.cardCornerRadius)
                StandardWiseSkeletonBlock(height: 54, cornerRadius: StandardWiseTheme.cardCornerRadius)
            }

            StandardWiseSkeletonBlock(height: 52, cornerRadius: StandardWiseTheme.cardCornerRadius)
        }
        .padding()
        .background(StandardWiseTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))
        .accessibilityLabel("Practice content is loading")
    }

    private var subjectPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Pick a subject")
                .font(.subheadline)
                .fontWeight(.semibold)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 10)], spacing: 10) {
                ForEach(subjects, id: \.self) { subject in
                    Button {
                        StandardWiseHaptics.tap()
                        selectedSubject = subject
                        selectedStandardCode = filteredStandards.first?.code ?? ""
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: subjectIcon(for: subject))
                                .font(.title3)
                                .foregroundStyle(subject == selectedSubject ? StandardWiseTheme.accent : .secondary)

                            Text(subject)
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(subject == selectedSubject ? StandardWiseTheme.accentSoft : StandardWiseTheme.cardBackground)
                        .overlay {
                            RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius)
                                .stroke(
                                    subject == selectedSubject ? StandardWiseTheme.accent : StandardWiseTheme.subtleBorder,
                                    lineWidth: subject == selectedSubject ? 2 : 0.5
                                )
                        }
                        .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Subject \(subject)")
                    .accessibilityValue(subject == selectedSubject ? "Selected" : "Not selected")
                }
            }
        }
    }

    private var gradePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Grade")
                .font(.subheadline)
                .fontWeight(.semibold)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(grades, id: \.self) { grade in
                        Button {
                            StandardWiseHaptics.tap()
                            selectedGrade = grade
                            selectedStandardCode = filteredStandards.first?.code ?? ""
                        } label: {
                            Text(grade)
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundStyle(grade == selectedGrade ? StandardWiseTheme.accent : .secondary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(grade == selectedGrade ? StandardWiseTheme.accentSoft : StandardWiseTheme.cardBackground)
                                .overlay {
                                    Capsule().stroke(
                                        grade == selectedGrade ? StandardWiseTheme.accent : StandardWiseTheme.subtleBorder,
                                        lineWidth: grade == selectedGrade ? 1.5 : 0.5
                                    )
                                }
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Grade \(grade)")
                        .accessibilityValue(grade == selectedGrade ? "Selected" : "Not selected")
                    }
                }
            }
        }
    }

    private var standardPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Standard")
                .font(.subheadline)
                .fontWeight(.semibold)

            if filteredStandards.isEmpty {
                StandardWiseEmptyState(
                    systemImage: "binoculars",
                    title: "Nothing here yet",
                    message: "No standards for \(selectedSubject) in \(selectedGrade) yet. Try another subject or grade."
                )
            } else {
                Menu {
                    ForEach(filteredStandards) { standard in
                        Button {
                            selectedStandardCode = standard.code
                        } label: {
                            if standard.code == selectedStandardCode {
                                Label(standard.displayName, systemImage: "checkmark")
                            } else {
                                Text(standard.displayName)
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(selectedStandard?.displayName ?? selectedStandardCode)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                                .lineLimit(1)

                            if let mastery = masteryPercent(for: selectedStandardCode) {
                                Text("Mastery \(mastery)%")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("Not practiced yet")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Spacer()

                        Image(systemName: "chevron.down")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(StandardWiseTheme.cardBackground)
                    .overlay {
                        RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius)
                            .stroke(StandardWiseTheme.subtleBorder, lineWidth: 0.5)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Standard")
                .accessibilityValue(selectedStandard?.displayName ?? selectedStandardCode)
                .accessibilityHint("Opens a list of standards for the selected subject and grade.")
            }
        }
    }

    private var startButton: some View {
        VStack(spacing: 8) {
            Button {
                startSession()
            } label: {
                Text("Generate question")
            }
            .buttonStyle(StandardWisePrimaryButtonStyle())
            .disabled(selectedStandardCode.isEmpty || availableQuestions.isEmpty)
            .accessibilityHint("Generates practice questions for the selected standard.")

            if !selectedStandardCode.isEmpty && availableQuestions.isEmpty {
                StandardWiseEmptyState(
                    systemImage: "questionmark.folder",
                    title: "No questions yet",
                    message: "This standard is ready, but it does not have practice questions yet. Try another standard for now.",
                    actionTitle: nextAvailableStandard == nil ? nil : "Use \(nextAvailableStandard?.code ?? "another standard")"
                ) {
                    if let nextAvailableStandard {
                        selectedStandardCode = nextAvailableStandard.code
                    }
                }
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Session

    private var sessionContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            sessionProgressHeader

            if let question = currentQuestion {
                SessionQuestionCard(
                    user: user,
                    question: question,
                    standard: resolvedStandard(for: question),
                    feedbackStore: feedbackStore,
                    answerAttemptStore: answerAttemptStore,
                    onAnswered: { isCorrect in
                        sessionResults.append(isCorrect)
                    },
                    onNext: {
                        advanceSession()
                    }
                )
                .id(question.id)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
        }
    }

    private var sessionProgressHeader: some View {
        let correctSoFar = sessionResults.filter { $0 }.count

        return HStack(spacing: 12) {
            Button {
                endSessionEarly()
            } label: {
                Image(systemName: "xmark")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(width: 32, height: 32)
                    .background(StandardWiseTheme.cardBackground)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("End practice session")

            VStack(alignment: .leading, spacing: 2) {
                Text("Question \(sessionIndex + 1)")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                if !sessionResults.isEmpty {
                    Text("\(correctSoFar)/\(sessionResults.count) correct so far")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Question \(sessionIndex + 1). \(correctSoFar) of \(sessionResults.count) correct so far.")
    }

    private var currentQuestion: Question? {
        guard sessionQuestions.indices.contains(sessionIndex) else { return nil }
        return sessionQuestions[sessionIndex]
    }

    // MARK: - Summary

    private var summaryContent: some View {
        let correct = sessionResults.filter { $0 }.count
        let total = max(sessionResults.count, 1)

        return VStack(spacing: 16) {
            Image(systemName: correct == total ? "trophy.fill" : "sparkles")
                .font(.system(size: 40))
                .foregroundStyle(StandardWiseTheme.accent)
                .frame(width: 88, height: 88)
                .background(StandardWiseTheme.accentSoft)
                .clipShape(Circle())
                .padding(.top, 32)

            VStack(spacing: 4) {
                Text(summaryHeadline(correct: correct, total: total))
                    .font(.title2)
                    .fontWeight(.bold)

                Text("You got \(correct) of \(total) right on \(selectedStandardCode).")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let mastery = masteryPercent(for: selectedStandardCode) {
                VStack(spacing: 6) {
                    HStack {
                        Text("Mastery")
                            .font(.footnote)
                            .fontWeight(.semibold)
                        Spacer()
                        Text("\(mastery)%")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundStyle(StandardWiseTheme.accent)
                    }

                    ProgressView(value: Double(mastery), total: 100)
                        .tint(StandardWiseTheme.accent)
                }
                .padding()
                .background(StandardWiseTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))
            }

            VStack(spacing: 10) {
                Button("Practice again") {
                    startSession()
                }
                .buttonStyle(StandardWisePrimaryButtonStyle())

                Button("Back to home") {
                    screen = .home
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .tint(StandardWiseTheme.accent)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .contain)
    }

    private func summaryHeadline(correct: Int, total: Int) -> String {
        let ratio = Double(correct) / Double(total)
        if ratio == 1 { return "Perfect round!" }
        if ratio >= 0.6 { return "Nice work!" }
        return "Keep going!"
    }

    // MARK: - Helpers

    private var firstName: String {
        user.name.split(separator: " ").first.map(String.init) ?? user.name
    }

    private var homeHeadline: String {
        if attemptsTodayCount >= Self.dailyGoal {
            return "Daily goal complete!"
        }

        if let recent = userAttempts.first {
            return recent.isCorrect ? "Keep the streak going." : "Ready for a comeback?"
        }

        return "Ready to practice?"
    }

    private var userInitials: String {
        let initials = user.name
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
            .map(String.init)
            .joined()

        if !initials.isEmpty {
            return initials.uppercased()
        }

        return user.email.first.map { String($0).uppercased() } ?? "S"
    }

    private var isPracticeDataLoading: Bool {
        questionStore.syncStatusMessage?.lowercased().contains("syncing") == true
            || standardStore.syncStatusMessage?.lowercased().contains("syncing") == true
    }

    private var nextAvailableStandard: LearningStandard? {
        filteredStandards.first { standard in
            !QuestionBank.questions(
                in: questionStore.questions,
                standards: standardStore.standards,
                subject: selectedSubject,
                grade: selectedGrade,
                standardCode: standard.code
            ).isEmpty
        }
    }

    private func subjectIcon(for subject: String) -> String {
        switch subject.lowercased() {
        case "math":
            return "function"
        case "ela":
            return "book.closed"
        case "science":
            return "atom"
        default:
            return "square.grid.2x2"
        }
    }

    private func resolvedStandard(for question: Question) -> LearningStandard? {
        standardStore.standards.first { $0.id == question.standardID }
            ?? standardStore.standards.first { $0.code == question.standardCode }
    }

    private func masteryPercent(for standardCode: String) -> Int? {
        let attempts = userAttempts.filter { $0.standardCode == standardCode }
        guard !attempts.isEmpty else { return nil }

        let correct = attempts.filter(\.isCorrect).count
        return Int((Double(correct) / Double(attempts.count) * 100).rounded())
    }

    private var attemptsTodayCount: Int {
        let calendar = Calendar.current
        return userAttempts.filter { calendar.isDateInToday($0.createdAt) }.count
    }

    private var todayStandardSummaries: [StandardActivitySummary] {
        let calendar = Calendar.current
        let todaysAttempts = userAttempts.filter { calendar.isDateInToday($0.createdAt) }
        let grouped = Dictionary(grouping: todaysAttempts, by: \.standardCode)

        return grouped.map { standardCode, attempts in
            StandardActivitySummary(
                standardCode: standardCode,
                subjectName: attempts.first?.subjectName ?? "",
                correct: attempts.filter(\.isCorrect).count,
                total: attempts.count,
                latestAttemptAt: attempts.map(\.createdAt).max() ?? .distantPast
            )
        }
        .sorted { $0.latestAttemptAt > $1.latestAttemptAt }
    }

    private func percentColor(for percent: Int) -> Color {
        if percent >= 80 { return StandardWiseTheme.success }
        if percent >= 50 { return StandardWiseTheme.warning }
        return StandardWiseTheme.danger
    }

    private func startSession() {
        let questions = availableQuestions.shuffled()
        guard !questions.isEmpty else { return }

        sessionQuestions = questions
        sessionIndex = 0
        sessionResults = []
        screen = .session
        StandardWiseHaptics.tap()
    }

    private func advanceSession() {
        if sessionIndex >= sessionQuestions.count - 1 {
            appendMoreQuestions()
        }
        sessionIndex += 1
    }

    /// Keeps practice going indefinitely: once the shuffled batch runs out,
    /// reshuffle the same available questions and keep appending rather than
    /// forcing the student to stop at a fixed count.
    private func appendMoreQuestions() {
        guard !availableQuestions.isEmpty else { return }
        sessionQuestions.append(contentsOf: availableQuestions.shuffled())
    }

    private func endSessionEarly() {
        if sessionResults.isEmpty {
            screen = .home
        } else {
            screen = .summary
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
    }
}

// MARK: - Today summary

private struct StandardActivitySummary: Identifiable {
    var id: String { standardCode }
    let standardCode: String
    let subjectName: String
    let correct: Int
    let total: Int
    let latestAttemptAt: Date

    var percent: Int {
        guard total > 0 else { return 0 }
        return Int((Double(correct) / Double(total) * 100).rounded())
    }
}

// MARK: - Session question card

private struct SessionQuestionCard: View {
    let user: StandardWiseUser
    let question: Question
    let standard: LearningStandard?
    @ObservedObject var feedbackStore: FeedbackStore
    @ObservedObject var answerAttemptStore: AnswerAttemptStore
    let onAnswered: (Bool) -> Void
    let onNext: () -> Void

    @State private var selectedChoiceID: String?
    @State private var typedAnswer = ""
    @State private var answerResult: AnswerResult?
    @State private var isShowingFeedbackForm = false
    @State private var didSubmitFeedback = false

    private var hasAnswer: Bool {
        switch question.type {
        case .multipleChoice:
            return selectedChoiceID != nil
        case .input:
            return !typedAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    private var submittedAnswer: String {
        switch question.type {
        case .multipleChoice:
            return selectedChoiceID ?? ""
        case .input:
            return typedAnswer
        }
    }

    private var answerResultAccessibilityValue: String {
        let explanation = question.explanation.trimmingCharacters(in: .whitespacesAndNewlines)

        if question.type == .input && answerResult?.isCorrect == false {
            if explanation.isEmpty {
                return "Correct answer: \(question.correctAnswer)."
            }

            return "Correct answer: \(question.correctAnswer). Explanation: \(explanation)"
        }

        return explanation.isEmpty ? "" : "Explanation: \(explanation)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(question.standardCode) · \(standard?.name ?? "Practice")")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(StandardWiseTheme.accent)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(StandardWiseTheme.accentSoft)
                .clipShape(Capsule())

            if let attachedImage = question.attachedImage {
                Image(uiImage: attachedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: 220)
                    .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))
                    .accessibilityLabel("Image for this question")
            }

            Text(question.prompt)
                .font(.title3)
                .fontWeight(.semibold)
                .fixedSize(horizontal: false, vertical: true)

            if question.type == .multipleChoice {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(question.choices) { choice in
                        Button {
                            guard answerResult == nil else { return }
                            StandardWiseHaptics.tap()
                            withAnimation(StandardWiseTheme.spring) {
                                selectedChoiceID = choice.id
                            }
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
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .disabled(answerResult != nil)
                    .standardWiseField()
                    .accessibilityLabel("Answer")
                    .accessibilityHint("Type your answer before checking it.")
            }

            if answerResult == nil {
                Button("Check answer") {
                    checkAnswer()
                }
                .buttonStyle(StandardWisePrimaryButtonStyle())
                .disabled(!hasAnswer)
                .accessibilityHint("Checks your answer and shows the explanation.")
            }

            if let answerResult {
                VStack(alignment: .leading, spacing: 10) {
                    Label(
                        answerResult.isCorrect ? "Nice work!" : "Not quite",
                        systemImage: answerResult.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill"
                    )
                    .font(.headline)
                    .foregroundStyle(answerResult.isCorrect ? StandardWiseTheme.success : StandardWiseTheme.danger)

                    if question.type == .input && !answerResult.isCorrect {
                        Text("Correct answer: \(question.correctAnswer)")
                            .fontWeight(.semibold)
                    }

                    if !question.explanation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(question.explanation)
                            .font(.subheadline)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(answerResult.isCorrect ? StandardWiseTheme.successSoft : StandardWiseTheme.dangerSoft)
                .overlay {
                    RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius)
                        .stroke(
                            answerResult.isCorrect ? StandardWiseTheme.success.opacity(0.4) : StandardWiseTheme.danger.opacity(0.4),
                            lineWidth: 1
                        )
                }
                .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .accessibilityElement(children: .combine)
                .accessibilityLabel(answerResult.isCorrect ? "Correct answer." : "Incorrect answer.")
                .accessibilityValue(
                    question.type == .input && !answerResult.isCorrect
                        ? answerResultAccessibilityValue
                        : answerResultAccessibilityValue
                )

                Button("Next question") {
                    onNext()
                }
                .buttonStyle(StandardWisePrimaryButtonStyle())
                .accessibilityHint("Shows the next question.")

                Button {
                    isShowingFeedbackForm = true
                } label: {
                    Label(didSubmitFeedback ? "Feedback sent" : "Report a problem", systemImage: "bubble.left")
                        .font(.footnote)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                .disabled(didSubmitFeedback)
                .accessibilityHint(didSubmitFeedback ? "Feedback has already been sent for this question." : "Opens a form to send feedback about this question.")
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(StandardWiseTheme.raisedCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))
        .shadow(
            color: StandardWiseTheme.cardShadowColor,
            radius: StandardWiseTheme.cardShadowRadius,
            y: StandardWiseTheme.cardShadowYOffset
        )
        .animation(StandardWiseTheme.spring, value: answerResult != nil)
        .sheet(isPresented: $isShowingFeedbackForm) {
            FeedbackFormView(question: question) { message in
                feedbackStore.submitFeedback(
                    userID: user.id,
                    questionID: question.id,
                    message: message
                )
                didSubmitFeedback = true
            }
        }
    }

    private func checkAnswer() {
        let result = AnswerChecker.check(answer: submittedAnswer, for: question)

        withAnimation(StandardWiseTheme.spring) {
            answerResult = result
        }

        if result.isCorrect {
            StandardWiseHaptics.success()
        } else {
            StandardWiseHaptics.error()
        }

        answerAttemptStore.record(
            AnswerAttempt(
                userID: user.id,
                questionID: question.id,
                subjectName: standard?.subjectName ?? "Unknown",
                gradeName: standard?.gradeName ?? "Unknown",
                standardCode: question.standardCode,
                submittedAnswer: submittedAnswer,
                isCorrect: result.isCorrect
            )
        )

        onAnswered(result.isCorrect)
    }

    private func choiceBackground(_ choice: AnswerChoice) -> Color {
        guard let answerResult else {
            return choice.id == selectedChoiceID ? StandardWiseTheme.accentSoft : StandardWiseTheme.cardBackground
        }

        if choice.id == question.correctAnswer {
            return StandardWiseTheme.successSoft
        }

        if choice.id == selectedChoiceID && !answerResult.isCorrect {
            return StandardWiseTheme.dangerSoft
        }

        return StandardWiseTheme.cardBackground
    }

    private func choiceBorderColor(_ choice: AnswerChoice) -> Color {
        guard answerResult != nil else {
            return choice.id == selectedChoiceID ? StandardWiseTheme.accent : StandardWiseTheme.subtleBorder
        }

        if choice.id == question.correctAnswer {
            return StandardWiseTheme.success
        }

        if choice.id == selectedChoiceID {
            return StandardWiseTheme.danger
        }

        return StandardWiseTheme.subtleBorder
    }

    private func choiceStatus(_ choice: AnswerChoice) -> ChoiceStatus? {
        guard let answerResult else {
            return choice.id == selectedChoiceID
                ? ChoiceStatus(text: "Selected", systemImage: "checkmark.circle", color: StandardWiseTheme.accent)
                : nil
        }

        if choice.id == question.correctAnswer {
            return ChoiceStatus(text: "Correct answer", systemImage: "checkmark.circle.fill", color: StandardWiseTheme.success)
        }

        if choice.id == selectedChoiceID && !answerResult.isCorrect {
            return ChoiceStatus(text: "Your answer", systemImage: "xmark.circle.fill", color: StandardWiseTheme.danger)
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

// MARK: - Feedback form

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
                        .foregroundStyle(StandardWiseTheme.accent)
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
                            .foregroundStyle(StandardWiseTheme.danger)
                    }
                }
            }
            .navigationTitle("Report a problem")
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

// MARK: - Answer checking

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
