import Charts
import PhotosUI
import SwiftUI
import UIKit

struct AdminDashboardView: View {
    let user: StandardWiseUser
    @ObservedObject var questionStore: QuestionStore
    @ObservedObject var standardStore: StandardStore
    @ObservedObject var feedbackStore: FeedbackStore
    @ObservedObject var answerAttemptStore: AnswerAttemptStore
    let onLogout: () -> Void

    @State private var users = LocalAuthService.sampleUsers
    @State private var userSyncStatusMessage: String?
    @State private var isAddingQuestion = false

    private var multipleChoiceCount: Int {
        questionStore.activeQuestions.filter { $0.type == .multipleChoice }.count
    }

    private var newFeedbackCount: Int {
        feedbackStore.feedbackItems.filter { $0.status == .new }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    todayStrip

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ],
                        spacing: 12
                    ) {
                        NavigationLink {
                            AdminQuestionManagementView(
                                questionStore: questionStore,
                                standardStore: standardStore
                            )
                        } label: {
                            AdminMetricCard(
                                title: "Questions",
                                value: "\(questionStore.activeQuestions.count)",
                                subtitle: "\(multipleChoiceCount) multiple choice"
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            AdminStandardsManagementView(standardStore: standardStore)
                        } label: {
                            AdminMetricCard(
                                title: "Standards",
                                value: "\(standardStore.activeStandards.count)",
                                subtitle: "\(standardStore.activeSubjects.count) subjects"
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            AdminUsersView(
                                users: users,
                                userSyncStatusMessage: userSyncStatusMessage,
                                answerAttemptStore: answerAttemptStore
                            )
                        } label: {
                            AdminMetricCard(
                                title: "Students",
                                value: "\(users.count)",
                                subtitle: "\(answerAttemptStore.attempts.count) total attempts"
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            AdminFeedbackView(
                                feedbackStore: feedbackStore,
                                questionStore: questionStore,
                                users: users
                            )
                        } label: {
                            AdminMetricCard(
                                title: "Feedback",
                                value: "\(feedbackStore.feedbackItems.count)",
                                subtitle: "\(newFeedbackCount) new reports",
                                isAlert: newFeedbackCount > 0
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Admin Areas")
                            .font(.title3)
                            .fontWeight(.semibold)

                        VStack(spacing: 8) {
                            AdminNavigationRow(
                                title: "Questions",
                                systemImage: "questionmark.square",
                                destination: AdminQuestionManagementView(
                                    questionStore: questionStore,
                                    standardStore: standardStore
                                )
                            )
                            AdminNavigationRow(
                                title: "Standards",
                                systemImage: "list.bullet.rectangle",
                                destination: AdminStandardsManagementView(standardStore: standardStore)
                            )
                            AdminNavigationRow(
                                title: "Students",
                                systemImage: "person.2",
                                destination: AdminUsersView(
                                    users: users,
                                    userSyncStatusMessage: userSyncStatusMessage,
                                    answerAttemptStore: answerAttemptStore
                                )
                            )
                            AdminNavigationRow(
                                title: "Feedback",
                                systemImage: "bubble.left.and.bubble.right",
                                badgeText: newFeedbackCount > 0 ? "\(newFeedbackCount) new" : nil,
                                destination: AdminFeedbackView(
                                    feedbackStore: feedbackStore,
                                    questionStore: questionStore,
                                    users: users
                                )
                            )
                            AdminNavigationRow(
                                title: "Analytics",
                                systemImage: "chart.bar",
                                destination: AdminAnalyticsView(
                                    users: users,
                                    questionStore: questionStore,
                                    answerAttemptStore: answerAttemptStore
                                )
                            )
                        }
                    }

                    syncFooter
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Admin")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isAddingQuestion = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                    .tint(StandardWiseTheme.accent)
                    .accessibilityLabel("Add question")
                    .accessibilityHint("Opens the new question form.")
                }

                ToolbarItem(placement: .primaryAction) {
                    StandardWiseSignOutButton(onSignOut: onLogout)
                }
            }
            .sheet(isPresented: $isAddingQuestion) {
                AdminQuestionFormView(question: nil, standardStore: standardStore) { question in
                    questionStore.save(question)
                }
            }
            .task {
                await loadFirebaseUsersIfNeeded()
            }
        }
    }

    private var header: some View {
        Text("Welcome back, \(adminFirstName)")
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }

    private var adminFirstName: String {
        user.name.split(separator: " ").first.map(String.init) ?? user.name
    }

    private var attemptsToday: [AnswerAttempt] {
        let calendar = Calendar.current
        return answerAttemptStore.attempts.filter { calendar.isDateInToday($0.createdAt) }
    }

    private var todayAccuracyText: String {
        guard !attemptsToday.isEmpty else { return "—" }

        let correct = attemptsToday.filter(\.isCorrect).count
        let accuracy = Double(correct) / Double(attemptsToday.count) * 100
        return "\(Int(accuracy.rounded()))%"
    }

    private var todayStrip: some View {
        HStack(spacing: 0) {
            todayStripColumn(value: "\(attemptsToday.count)", label: "Attempts today")
            Divider().frame(height: 28)
            todayStripColumn(value: "\(Set(attemptsToday.map(\.userID)).count)", label: "Active students")
            Divider().frame(height: 28)
            todayStripColumn(
                value: todayAccuracyText,
                label: "Accuracy",
                valueColor: attemptsToday.isEmpty ? .primary : StandardWiseTheme.success
            )
        }
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .overlay {
            RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius)
                .stroke(Color(.separator), lineWidth: 0.5)
        }
        .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Today: \(attemptsToday.count) attempts, \(Set(attemptsToday.map(\.userID)).count) active students, accuracy \(todayAccuracyText).")
    }

    private func todayStripColumn(value: String, label: String, valueColor: Color = .primary) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline)
                .foregroundStyle(valueColor)
                .monospacedDigit()

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var syncFooter: some View {
        Group {
            if StandardWiseAuthMode.current == .staging {
                Label(
                    isUsingLocalData ? "Offline · using local data" : "Synced with Firebase",
                    systemImage: isUsingLocalData ? "icloud.slash" : "checkmark.icloud"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var isUsingLocalData: Bool {
        [
            questionStore.syncStatusMessage,
            standardStore.syncStatusMessage,
            feedbackStore.syncStatusMessage,
            answerAttemptStore.syncStatusMessage,
            userSyncStatusMessage
        ]
        .compactMap { $0 }
        .contains { message in
            message.localizedCaseInsensitiveContains("unavailable")
                || message.localizedCaseInsensitiveContains("failed")
        }
    }

    private func loadFirebaseUsersIfNeeded() async {
        guard StandardWiseAuthMode.current == .staging else { return }

        userSyncStatusMessage = "Syncing users from Firebase..."

        do {
            let firebaseUsers = try await FirebaseUserService.loadUsers()
            if !firebaseUsers.isEmpty {
                users = firebaseUsers
            }
            userSyncStatusMessage = "Users are synced with Firebase."
        } catch {
            userSyncStatusMessage = "Using local users because Firebase users are unavailable."
        }
    }
}

private struct AdminMetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    var isAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Text(value)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(subtitle)
                .font(.caption)
                .fontWeight(isAlert ? .semibold : .regular)
                .foregroundStyle(isAlert ? StandardWiseTheme.danger : Color.secondary)
        }
        .frame(minHeight: 108)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .overlay {
            RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius)
                .stroke(
                    isAlert ? StandardWiseTheme.danger : Color(.separator),
                    lineWidth: isAlert ? 1.5 : 0.5
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))
    }
}

private struct AdminNavigationRow<Destination: View>: View {
    let title: String
    let systemImage: String
    var badgeText: String?
    let destination: Destination

    var body: some View {
        NavigationLink {
            destination
        } label: {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.subheadline)
                    .foregroundStyle(StandardWiseTheme.accent)
                    .frame(width: 30, height: 30)
                    .background(StandardWiseTheme.accentSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                Spacer()

                if let badgeText {
                    Text(badgeText)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(StandardWiseTheme.danger)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(StandardWiseTheme.dangerSoft)
                        .clipShape(Capsule())
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .overlay {
                RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius)
                    .stroke(Color(.separator), lineWidth: 0.5)
            }
            .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(badgeText != nil ? "\(title), \(badgeText!)" : title)
    }
}

private struct AdminQuestionManagementView: View {
    @ObservedObject var questionStore: QuestionStore
    @ObservedObject var standardStore: StandardStore
    @State private var searchText = ""
    @State private var subjectFilter = "All"
    @State private var gradeFilter = "All"
    @State private var standardFilter = "All"
    @State private var typeFilter = "All"
    @State private var statusFilter = "Active"
    @State private var isAddingQuestion = false
    @State private var editingQuestion: Question?
    @State private var questionToArchive: Question?

    private var filteredQuestions: [Question] {
        questionStore.questions.filter { question in
            matchesSearch(question)
                && matchesFilter(subjectFilter, value: standard(for: question)?.subjectName)
                && matchesFilter(gradeFilter, value: standard(for: question)?.gradeName)
                && matchesFilter(standardFilter, value: question.standardCode)
                && matchesFilter(typeFilter, value: question.type.displayName)
                && matchesStatus(question)
        }
    }

    private var subjectOptions: [String] {
        filterOptions(standardStore.activeStandards.map(\.subjectName))
    }

    private var gradeOptions: [String] {
        filterOptions(standardStore.activeStandards.map(\.gradeName))
    }

    private var standardOptions: [String] {
        filterOptions(standardStore.activeStandards.map(\.code))
    }

    var body: some View {
        List {
            if let syncStatusMessage = questionStore.syncStatusMessage {
                Section {
                    Text(syncStatusMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                VStack(alignment: .leading, spacing: 12) {
                    TextField("Search questions", text: $searchText)
                        .textFieldStyle(.roundedBorder)

                    HStack {
                        adminFilterMenu(title: "Subject", selection: $subjectFilter, options: subjectOptions)
                        adminFilterMenu(title: "Grade", selection: $gradeFilter, options: gradeOptions)
                    }

                    HStack {
                        adminFilterMenu(title: "Standard", selection: $standardFilter, options: standardOptions)
                        adminFilterMenu(
                            title: "Type",
                            selection: $typeFilter,
                            options: ["All"] + QuestionType.allCases.map(\.displayName)
                        )
                    }

                    adminFilterMenu(title: "Status", selection: $statusFilter, options: ["All", "Active", "Archived"])
                }
                .padding(.vertical, 4)
            }

            Section("\(filteredQuestions.count) Questions") {
                if filteredQuestions.isEmpty {
                    Text("No questions match these filters.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(filteredQuestions) { question in
                        Button {
                            editingQuestion = question
                        } label: {
                            AdminQuestionRow(question: question, standard: standard(for: question))
                        }
                        .buttonStyle(.plain)
                        .swipeActions {
                            if question.isActive {
                                Button("Archive", role: .destructive) {
                                    questionToArchive = question
                                }
                            }
                            Button("Edit") {
                                editingQuestion = question
                            }
                            .tint(StandardWiseTheme.accent)
                        }
                    }
                }
            }
        }
        .navigationTitle("Questions")
        .toolbar {
            Button {
                isAddingQuestion = true
            } label: {
                Label("Add Question", systemImage: "plus")
            }
        }
        .sheet(isPresented: $isAddingQuestion) {
            AdminQuestionFormView(question: nil, standardStore: standardStore) { question in
                questionStore.save(question)
            }
        }
        .sheet(item: $editingQuestion) { question in
            AdminQuestionFormView(question: question, standardStore: standardStore) { updatedQuestion in
                questionStore.save(updatedQuestion)
            }
        }
        .confirmationDialog(
            "Archive this question?",
            isPresented: Binding(
                get: { questionToArchive != nil },
                set: { isPresented in
                    if !isPresented {
                        questionToArchive = nil
                    }
                }
            ),
            titleVisibility: .visible
        ) {
            Button("Archive", role: .destructive) {
                if let questionToArchive {
                    questionStore.archive(questionToArchive)
                }
                questionToArchive = nil
            }
            Button("Cancel", role: .cancel) {
                questionToArchive = nil
            }
        } message: {
            Text("Archived questions stay in the admin list, but regular users will not receive them.")
        }
    }

    private func adminFilterMenu(title: String, selection: Binding<String>, options: [String]) -> some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button {
                    selection.wrappedValue = option
                } label: {
                    if option == selection.wrappedValue {
                        Label(option, systemImage: "checkmark")
                    } else {
                        Text(option)
                    }
                }
            }
        } label: {
            HStack {
                Text("\(title): \(selection.wrappedValue)")
                    .font(.subheadline)
                    .lineLimit(1)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 9)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))
        }
        .buttonStyle(.plain)
    }

    private func filterOptions(_ values: [String]) -> [String] {
        ["All"] + Array(Set(values)).sorted()
    }

    private func matchesFilter(_ filter: String, value: String?) -> Bool {
        filter == "All" || value == filter
    }

    private func matchesStatus(_ question: Question) -> Bool {
        switch statusFilter {
        case "Active":
            return question.isActive
        case "Archived":
            return !question.isActive
        default:
            return true
        }
    }

    private func matchesSearch(_ question: Question) -> Bool {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return true }

        return question.prompt.lowercased().contains(query)
            || question.standardCode.lowercased().contains(query)
            || question.explanation.lowercased().contains(query)
    }

    private func standard(for question: Question) -> LearningStandard? {
        standardStore.standards.first { $0.id == question.standardID }
    }
}

private struct AdminQuestionRow: View {
    let question: Question
    let standard: LearningStandard?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(question.standardCode)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(StandardWiseTheme.accent)
                Text(question.type.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if question.imageBase64 != nil {
                    Image(systemName: "photo")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("Has attached photo")
                }
                Spacer()
                if !question.isActive {
                    Text("Archived")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.red)
                }
            }

            Text(question.prompt)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(2)

            Text("\(standard?.subjectName ?? "Unknown") - \(standard?.gradeName ?? "Unknown")")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

private struct AdminQuestionFormView: View {
    @Environment(\.dismiss) private var dismiss

    let question: Question?
    @ObservedObject var standardStore: StandardStore
    let onSave: (Question) -> Void

    @State private var selectedSubjectID: UUID
    @State private var selectedGradeID: UUID
    @State private var selectedStandardID: UUID
    @State private var questionType: QuestionType
    @State private var prompt: String
    @State private var choiceA: String
    @State private var choiceB: String
    @State private var choiceC: String
    @State private var choiceD: String
    @State private var correctChoiceID: String
    @State private var inputCorrectAnswer: String
    @State private var alternateAnswersText: String
    @State private var explanation: String
    @State private var validationMessage: String?
    @State private var imageBase64: String?
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var isProcessingImage = false
    @State private var imageErrorMessage: String?

    init(question: Question?, standardStore: StandardStore, onSave: @escaping (Question) -> Void) {
        self.question = question
        self.standardStore = standardStore
        self.onSave = onSave

        let firstSubjectID = standardStore.activeSubjects.first?.id ?? StandardWiseSampleData.mathSubjectID
        let firstGradeID = standardStore.grades.first?.id ?? StandardWiseSampleData.grade6ID
        let existingStandard = question.flatMap { question in
            standardStore.standards.first { $0.id == question.standardID }
        }
        let firstStandard = standardStore.activeStandards.first
        let standardID = existingStandard?.id ?? firstStandard?.id ?? UUID()
        let subjectID = existingStandard?.subjectID ?? firstStandard?.subjectID ?? firstSubjectID
        let gradeID = existingStandard?.gradeID ?? firstStandard?.gradeID ?? firstGradeID
        let type = question?.type ?? .multipleChoice
        let choices = question?.choices ?? []

        _selectedSubjectID = State(initialValue: subjectID)
        _selectedGradeID = State(initialValue: gradeID)
        _selectedStandardID = State(initialValue: standardID)
        _questionType = State(initialValue: type)
        _prompt = State(initialValue: question?.prompt ?? "")
        _choiceA = State(initialValue: choices.first { $0.id == "A" }?.text ?? "")
        _choiceB = State(initialValue: choices.first { $0.id == "B" }?.text ?? "")
        _choiceC = State(initialValue: choices.first { $0.id == "C" }?.text ?? "")
        _choiceD = State(initialValue: choices.first { $0.id == "D" }?.text ?? "")
        _correctChoiceID = State(initialValue: type == .multipleChoice ? question?.correctAnswer ?? "A" : "A")
        _inputCorrectAnswer = State(initialValue: type == .input ? question?.correctAnswer ?? "" : "")
        _alternateAnswersText = State(initialValue: question?.acceptedAlternateAnswers.joined(separator: ", ") ?? "")
        _explanation = State(initialValue: question?.explanation ?? "")
        _imageBase64 = State(initialValue: question?.imageBase64)
    }

    private var filteredStandards: [LearningStandard] {
        standardStore.activeStandards.filter { standard in
            standard.subjectID == selectedSubjectID && standard.gradeID == selectedGradeID
        }
    }

    private var selectedStandard: LearningStandard {
        standardStore.standards.first { $0.id == selectedStandardID } ?? filteredStandards[0]
    }

    private var questionImage: UIImage? {
        imageBase64
            .flatMap { Data(base64Encoded: $0) }
            .flatMap(UIImage.init(data:))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Standard") {
                    Picker("Subject", selection: $selectedSubjectID) {
                        ForEach(standardStore.activeSubjects) { subject in
                            Text(subject.name)
                                .tag(subject.id)
                        }
                    }
                    .onChange(of: selectedSubjectID) { _, _ in
                        resetSelectedStandard()
                    }

                    Picker("Grade", selection: $selectedGradeID) {
                        ForEach(standardStore.grades) { grade in
                            Text(grade.name)
                                .tag(grade.id)
                        }
                    }
                    .onChange(of: selectedGradeID) { _, _ in
                        resetSelectedStandard()
                    }

                    Picker("Standard", selection: $selectedStandardID) {
                        ForEach(filteredStandards) { standard in
                            Text(standard.displayName)
                                .tag(standard.id)
                        }
                    }
                    .disabled(filteredStandards.isEmpty)

                    if filteredStandards.isEmpty {
                        Text("No standards exist for this subject and grade yet.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("\(selectedStandard.subjectName) - \(selectedStandard.gradeName)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    }
                }

                Section("Question") {
                    Picker("Type", selection: $questionType) {
                        ForEach(QuestionType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            PhotosPicker(selection: $photosPickerItem, matching: .images) {
                                Label(imageBase64 == nil ? "Insert image" : "Replace image", systemImage: "photo.badge.plus")
                            }
                            .disabled(isProcessingImage)

                            Spacer()

                            if isProcessingImage {
                                ProgressView()
                            }

                            if imageBase64 != nil {
                                Button("Remove", role: .destructive) {
                                    imageBase64 = nil
                                    photosPickerItem = nil
                                    imageErrorMessage = nil
                                }
                            }
                        }

                        if let uiImage = questionImage {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 180)
                                .frame(maxWidth: .infinity)
                                .background(StandardWiseTheme.raisedCardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))
                                .accessibilityLabel("Inserted question image")
                        }

                        TextEditor(text: $prompt)
                            .frame(minHeight: 120)
                            .scrollContentBackground(.hidden)
                            .padding(8)
                            .background(StandardWiseTheme.raisedCardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius)
                                    .stroke(StandardWiseTheme.subtleBorder)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: StandardWiseTheme.cardCornerRadius))
                            .accessibilityLabel("Question prompt")

                        if prompt.isEmpty {
                            Text("Write the question text below the image, for example: What is the area of this triangle?")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }

                        if isProcessingImage {
                            Text("Processing image...")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }

                        if let imageErrorMessage {
                            Text(imageErrorMessage)
                                .font(.footnote)
                                .foregroundStyle(StandardWiseTheme.danger)
                        }
                    }
                }

                if questionType == .multipleChoice {
                    Section("Choices") {
                        TextField("A", text: $choiceA)
                        TextField("B", text: $choiceB)
                        TextField("C", text: $choiceC)
                        TextField("D", text: $choiceD)

                        Picker("Correct answer", selection: $correctChoiceID) {
                            ForEach(["A", "B", "C", "D"], id: \.self) { id in
                                Text(id).tag(id)
                            }
                        }
                    }
                } else {
                    Section("Answer") {
                        TextField("Correct answer", text: $inputCorrectAnswer)
                        TextField("Alternate answers, separated by commas", text: $alternateAnswersText, axis: .vertical)
                            .lineLimit(2...4)
                    }
                }

                Section("Explanation") {
                    TextField("Explain why the answer is correct", text: $explanation, axis: .vertical)
                        .lineLimit(3...6)
                }

                if let validationMessage {
                    Section {
                        Text(validationMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(question == nil ? "Add Question" : "Edit Question")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveQuestion()
                    }
                }
            }
            .onChange(of: photosPickerItem) { _, newItem in
                loadPickedPhoto(newItem)
            }
        }
    }

    private func loadPickedPhoto(_ item: PhotosPickerItem?) {
        guard let item else { return }

        isProcessingImage = true
        imageErrorMessage = nil

        Task {
            defer { isProcessingImage = false }

            do {
                guard let data = try await item.loadTransferable(type: Data.self) else {
                    imageErrorMessage = "Could not load that photo. Try a different one."
                    return
                }

                guard let base64 = Self.compressedImageBase64(from: data) else {
                    imageErrorMessage = "That photo is too large or in an unsupported format. Try a smaller photo or screenshot."
                    return
                }

                imageBase64 = base64
            } catch {
                imageErrorMessage = "Could not load that photo. Try again."
            }
        }
    }

    /// Resizes and JPEG-compresses picked photo data so it stays well under
    /// the ~1 MiB Firestore document limit once base64-encoded alongside the
    /// rest of the question's fields.
    private static func compressedImageBase64(
        from data: Data,
        maxDimension: CGFloat = 1024,
        maxByteCount: Int = 700_000
    ) -> String? {
        guard let image = UIImage(data: data) else { return nil }

        let scale = min(1, maxDimension / max(image.size.width, image.size.height))
        let targetSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }

        var quality: CGFloat = 0.7
        var jpegData = resizedImage.jpegData(compressionQuality: quality)

        while let currentData = jpegData, currentData.count > maxByteCount, quality > 0.1 {
            quality -= 0.1
            jpegData = resizedImage.jpegData(compressionQuality: quality)
        }

        guard let finalData = jpegData, finalData.count <= maxByteCount else { return nil }

        return finalData.base64EncodedString()
    }

    private func saveQuestion() {
        guard validate() else { return }

        let savedQuestion = Question(
            id: question?.id ?? UUID(),
            subjectID: selectedStandard.subjectID,
            gradeID: selectedStandard.gradeID,
            standardID: selectedStandard.id,
            standardCode: selectedStandard.code,
            prompt: clean(prompt),
            type: questionType,
            choices: questionType == .multipleChoice ? answerChoices : [],
            correctAnswer: questionType == .multipleChoice ? correctChoiceID : clean(inputCorrectAnswer),
            acceptedAlternateAnswers: questionType == .input ? alternateAnswers : [],
            explanation: clean(explanation),
            difficulty: question?.difficulty,
            isActive: question?.isActive ?? true,
            createdByAdminID: question?.createdByAdminID,
            createdAt: question?.createdAt ?? Date(),
            updatedAt: Date(),
            imageBase64: imageBase64
        )

        onSave(savedQuestion)
        dismiss()
    }

    private func validate() -> Bool {
        validationMessage = nil

        guard !filteredStandards.isEmpty else {
            validationMessage = "Add a standard for this subject and grade before saving a question."
            return false
        }

        guard !clean(prompt).isEmpty else {
            validationMessage = "Question prompt is required."
            return false
        }

        guard !clean(explanation).isEmpty else {
            validationMessage = "Explanation is required."
            return false
        }

        if questionType == .multipleChoice {
            guard [choiceA, choiceB, choiceC, choiceD].allSatisfy({ !clean($0).isEmpty }) else {
                validationMessage = "All four choices are required for multiple choice questions."
                return false
            }
        } else {
            guard !clean(inputCorrectAnswer).isEmpty else {
                validationMessage = "Correct answer is required."
                return false
            }
        }

        return true
    }

    private func resetSelectedStandard() {
        selectedStandardID = filteredStandards.first?.id ?? selectedStandardID
    }

    private var answerChoices: [AnswerChoice] {
        [
            AnswerChoice(id: "A", text: clean(choiceA)),
            AnswerChoice(id: "B", text: clean(choiceB)),
            AnswerChoice(id: "C", text: clean(choiceC)),
            AnswerChoice(id: "D", text: clean(choiceD))
        ]
    }

    private var alternateAnswers: [String] {
        alternateAnswersText
            .split(separator: ",")
            .map { clean(String($0)) }
            .filter { !$0.isEmpty }
    }

    private func clean(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private struct AdminStandardsManagementView: View {
    @ObservedObject var standardStore: StandardStore
    @State private var isAddingSubject = false
    @State private var isAddingStandard = false
    @State private var editingSubject: AcademicSubject?
    @State private var editingStandard: LearningStandard?
    @State private var subjectToArchive: AcademicSubject?
    @State private var standardToArchive: LearningStandard?

    var body: some View {
        List {
            if let syncStatusMessage = standardStore.syncStatusMessage {
                Section {
                    Text(syncStatusMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            subjectsSection
            standardsSection
        }
        .navigationTitle("Standards")
        .toolbar {
            Menu {
                Button {
                    isAddingSubject = true
                } label: {
                    Label("Add Subject", systemImage: "folder.badge.plus")
                }

                Button {
                    isAddingStandard = true
                } label: {
                    Label("Add Standard", systemImage: "plus.square")
                }
            } label: {
                Label("Add", systemImage: "plus")
            }
        }
        .sheet(isPresented: $isAddingSubject) {
            AdminSubjectFormView(subject: nil) { subject in
                standardStore.saveSubject(subject)
            }
        }
        .sheet(item: $editingSubject) { subject in
            AdminSubjectFormView(subject: subject) { updatedSubject in
                standardStore.saveSubject(updatedSubject)
            }
        }
        .sheet(isPresented: $isAddingStandard) {
            AdminStandardFormView(standard: nil, standardStore: standardStore) { standard in
                standardStore.saveStandard(standard)
            }
        }
        .sheet(item: $editingStandard) { standard in
            AdminStandardFormView(standard: standard, standardStore: standardStore) { updatedStandard in
                standardStore.saveStandard(updatedStandard)
            }
        }
        .confirmationDialog(
            "Archive this subject?",
            isPresented: Binding(
                get: { subjectToArchive != nil },
                set: { isPresented in
                    if !isPresented {
                        subjectToArchive = nil
                    }
                }
            ),
            titleVisibility: .visible
        ) {
            Button("Archive", role: .destructive) {
                if let subjectToArchive {
                    standardStore.archiveSubject(subjectToArchive)
                }
                subjectToArchive = nil
            }
            Button("Cancel", role: .cancel) {
                subjectToArchive = nil
            }
        } message: {
            Text("Archived subjects will not appear in regular-user subject dropdowns.")
        }
        .confirmationDialog(
            "Archive this standard?",
            isPresented: Binding(
                get: { standardToArchive != nil },
                set: { isPresented in
                    if !isPresented {
                        standardToArchive = nil
                    }
                }
            ),
            titleVisibility: .visible
        ) {
            Button("Archive", role: .destructive) {
                if let standardToArchive {
                    standardStore.archiveStandard(standardToArchive)
                }
                standardToArchive = nil
            }
            Button("Cancel", role: .cancel) {
                standardToArchive = nil
            }
        } message: {
            Text("Archived standards will not appear in regular-user standard dropdowns.")
        }
    }

    private var subjectsSection: some View {
        Section("Subjects") {
            if standardStore.subjects.isEmpty {
                Text("No subjects yet.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(standardStore.subjects.sorted { $0.name < $1.name }) { subject in
                    Button {
                        editingSubject = subject
                    } label: {
                        AdminSubjectRow(subject: subject)
                    }
                    .buttonStyle(.plain)
                    .swipeActions {
                        if subject.isActive {
                            Button("Archive", role: .destructive) {
                                subjectToArchive = subject
                            }
                        }
                        Button("Edit") {
                            editingSubject = subject
                        }
                        .tint(StandardWiseTheme.accent)
                    }
                }
            }
        }
    }

    private var standardsSection: some View {
        Section("Standards") {
            if standardStore.standards.isEmpty {
                Text("No standards yet.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(standardStore.standards.sorted { $0.code < $1.code }) { standard in
                    Button {
                        editingStandard = standard
                    } label: {
                        AdminStandardRow(standard: standard)
                    }
                    .buttonStyle(.plain)
                    .swipeActions {
                        if standard.isActive {
                            Button("Archive", role: .destructive) {
                                standardToArchive = standard
                            }
                        }
                        Button("Edit") {
                            editingStandard = standard
                        }
                        .tint(StandardWiseTheme.accent)
                    }
                }
            }
        }
    }
}

private struct AdminSubjectRow: View {
    let subject: AcademicSubject

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(subject.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(subject.isActive ? "Active" : "Archived")
                    .font(.caption)
                    .foregroundStyle(subject.isActive ? Color.secondary : Color.red)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

private struct AdminStandardRow: View {
    let standard: LearningStandard

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(standard.code)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(StandardWiseTheme.accent)
                Text("\(standard.subjectName) - \(standard.gradeName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                if !standard.isActive {
                    Text("Archived")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.red)
                }
            }

            Text(standard.name)
                .font(.headline)
                .foregroundStyle(.primary)

            Text(standard.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }
}

private struct AdminSubjectFormView: View {
    @Environment(\.dismiss) private var dismiss

    let subject: AcademicSubject?
    let onSave: (AcademicSubject) -> Void

    @State private var name: String
    @State private var validationMessage: String?

    init(subject: AcademicSubject?, onSave: @escaping (AcademicSubject) -> Void) {
        self.subject = subject
        self.onSave = onSave
        _name = State(initialValue: subject?.name ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Subject") {
                    TextField("Subject name", text: $name)
                }

                if let validationMessage {
                    Section {
                        Text(validationMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(subject == nil ? "Add Subject" : "Edit Subject")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveSubject()
                    }
                }
            }
        }
    }

    private func saveSubject() {
        let cleanedName = clean(name)
        guard !cleanedName.isEmpty else {
            validationMessage = "Subject name is required."
            return
        }

        onSave(
            AcademicSubject(
                id: subject?.id ?? UUID(),
                name: cleanedName,
                isActive: subject?.isActive ?? true
            )
        )
        dismiss()
    }

    private func clean(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private struct AdminStandardFormView: View {
    @Environment(\.dismiss) private var dismiss

    let standard: LearningStandard?
    @ObservedObject var standardStore: StandardStore
    let onSave: (LearningStandard) -> Void

    @State private var selectedSubjectID: UUID
    @State private var selectedGradeID: UUID
    @State private var code: String
    @State private var name: String
    @State private var description: String
    @State private var validationMessage: String?

    init(
        standard: LearningStandard?,
        standardStore: StandardStore,
        onSave: @escaping (LearningStandard) -> Void
    ) {
        self.standard = standard
        self.standardStore = standardStore
        self.onSave = onSave

        _selectedSubjectID = State(
            initialValue: standard?.subjectID ?? standardStore.activeSubjects.first?.id ?? StandardWiseSampleData.mathSubjectID
        )
        _selectedGradeID = State(
            initialValue: standard?.gradeID ?? standardStore.grades.first?.id ?? StandardWiseSampleData.grade6ID
        )
        _code = State(initialValue: standard?.code ?? "")
        _name = State(initialValue: standard?.name ?? "")
        _description = State(initialValue: standard?.description ?? "")
    }

    private var selectedSubject: AcademicSubject? {
        standardStore.subjects.first { $0.id == selectedSubjectID }
    }

    private var selectedGrade: GradeLevel? {
        standardStore.grades.first { $0.id == selectedGradeID }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Subject and Grade") {
                    Picker("Subject", selection: $selectedSubjectID) {
                        ForEach(standardStore.activeSubjects) { subject in
                            Text(subject.name)
                                .tag(subject.id)
                        }
                    }

                    Picker("Grade", selection: $selectedGradeID) {
                        ForEach(standardStore.grades) { grade in
                            Text(grade.name)
                                .tag(grade.id)
                        }
                    }
                }

                Section("Standard") {
                    TextField("Code, for example 6.G.1", text: $code)
                        .textInputAutocapitalization(.characters)
                    TextField("Name, for example Basic concepts of geometry", text: $name)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                if let validationMessage {
                    Section {
                        Text(validationMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(standard == nil ? "Add Standard" : "Edit Standard")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveStandard()
                    }
                }
            }
        }
    }

    private func saveStandard() {
        guard let selectedSubject, let selectedGrade else {
            validationMessage = "Subject and grade are required."
            return
        }

        guard !clean(code).isEmpty else {
            validationMessage = "Standard code is required."
            return
        }

        guard !clean(name).isEmpty else {
            validationMessage = "Standard name is required."
            return
        }

        guard !clean(description).isEmpty else {
            validationMessage = "Description is required."
            return
        }

        onSave(
            LearningStandard(
                id: standard?.id ?? UUID(),
                subjectID: selectedSubject.id,
                gradeID: selectedGrade.id,
                subjectName: selectedSubject.name,
                gradeName: selectedGrade.name,
                code: clean(code),
                name: clean(name),
                description: clean(description),
                isActive: standard?.isActive ?? true
            )
        )
        dismiss()
    }

    private func clean(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private struct AdminFeedbackView: View {
    @ObservedObject var feedbackStore: FeedbackStore
    @ObservedObject var questionStore: QuestionStore
    let users: [StandardWiseUser]
    @State private var statusFilter = "All"

    private var filteredFeedback: [QuestionFeedback] {
        feedbackStore.feedbackItems.filter { feedback in
            statusFilter == "All" || feedback.status.displayName == statusFilter
        }
    }

    var body: some View {
        List {
            if let syncStatusMessage = feedbackStore.syncStatusMessage {
                Section {
                    Text(syncStatusMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Menu {
                    ForEach(["All"] + FeedbackStatus.allCases.map(\.displayName), id: \.self) { option in
                        Button {
                            statusFilter = option
                        } label: {
                            if option == statusFilter {
                                Label(option, systemImage: "checkmark")
                            } else {
                                Text(option)
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text("Status: \(statusFilter)")
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("\(filteredFeedback.count) Feedback Items") {
                if filteredFeedback.isEmpty {
                    Text("No feedback matches this filter.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(filteredFeedback) { feedback in
                        AdminFeedbackRow(
                            feedback: feedback,
                            question: question(for: feedback),
                            owner: owner(for: feedback)
                        ) { status in
                            feedbackStore.updateStatus(for: feedback, status: status)
                        }
                    }
                }
            }
        }
        .navigationTitle("Feedback")
        .toolbar {
            Button {
                Task {
                    await feedbackStore.refreshFromFirebaseIfNeeded()
                }
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            .accessibilityHint("Loads the latest feedback from Firebase.")
        }
        .task {
            await feedbackStore.refreshFromFirebaseIfNeeded()
        }
    }

    private func question(for feedback: QuestionFeedback) -> Question? {
        questionStore.questions.first { $0.id == feedback.questionID }
    }

    private func owner(for feedback: QuestionFeedback) -> StandardWiseUser? {
        users.first { $0.id == feedback.userID }
    }
}

private struct AdminFeedbackRow: View {
    let feedback: QuestionFeedback
    let question: Question?
    let owner: StandardWiseUser?
    let onStatusChange: (FeedbackStatus) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(feedback.status.displayName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(statusColor)
                Spacer()
                Text(feedback.createdAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ownerRow

            Text(feedback.message)
                .font(.headline)

            if let question {
                VStack(alignment: .leading, spacing: 4) {
                    Text(question.standardCode)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(StandardWiseTheme.accent)
                    Text(question.prompt)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }
            } else {
                Text("Question not found.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Picker("Status", selection: statusBinding) {
                ForEach(FeedbackStatus.allCases) { status in
                    Text(status.displayName).tag(status)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(.vertical, 6)
    }

    private var statusBinding: Binding<FeedbackStatus> {
        Binding(
            get: { feedback.status },
            set: { onStatusChange($0) }
        )
    }

    private var statusColor: Color {
        switch feedback.status {
        case .new:
            return .blue
        case .reviewed:
            return .orange
        case .resolved:
            return .green
        }
    }

    @ViewBuilder
    private var ownerRow: some View {
        HStack(spacing: 8) {
            Text(ownerInitials)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(StandardWiseTheme.accent)
                .frame(width: 24, height: 24)
                .background(StandardWiseTheme.accentSoft)
                .clipShape(Circle())

            if let owner {
                VStack(alignment: .leading, spacing: 0) {
                    Text(owner.name)
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text(owner.email)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("Unknown student")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(owner.map { "Submitted by \($0.name), \($0.email)" } ?? "Submitted by an unknown student")
    }

    private var ownerInitials: String {
        guard let name = owner?.name, !name.isEmpty else { return "?" }

        let initials = name
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
            .map(String.init)
            .joined()

        return initials.isEmpty ? "?" : initials.uppercased()
    }
}

private struct AdminUsersView: View {
    let users: [StandardWiseUser]
    let userSyncStatusMessage: String?
    @ObservedObject var answerAttemptStore: AnswerAttemptStore

    var body: some View {
        List {
            if let userSyncStatusMessage {
                Section {
                    Text(userSyncStatusMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            if let syncStatusMessage = answerAttemptStore.syncStatusMessage {
                Section {
                    Text(syncStatusMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Section("\(users.count) Users") {
                ForEach(users) { user in
                    NavigationLink {
                        AdminUserDetailView(
                            user: user,
                            attempts: answerAttemptStore.attempts(for: user.id)
                        )
                    } label: {
                        AdminUserRow(
                            user: user,
                            attempts: answerAttemptStore.attempts(for: user.id)
                        )
                    }
                }
            }
        }
        .navigationTitle("Users")
    }
}

private struct AdminUserRow: View {
    let user: StandardWiseUser
    let attempts: [AnswerAttempt]

    private var correctCount: Int {
        attempts.filter(\.isCorrect).count
    }

    private var accuracyText: String {
        guard !attempts.isEmpty else { return "No attempts yet" }

        let accuracy = Double(correctCount) / Double(attempts.count) * 100
        return "\(Int(accuracy.rounded()))% accuracy"
    }

    private var lastActiveText: String {
        guard let lastAttempt = attempts.map(\.createdAt).max() else {
            return "No activity yet"
        }

        return lastAttempt.formatted(date: .abbreviated, time: .shortened)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.name)
                        .font(.headline)
                    Text(user.email)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(user.role.displayName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(user.role == .admin ? .blue : .secondary)
            }

            HStack {
                Text("\(attempts.count) attempts")
                Text(accuracyText)
                Spacer()
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            Text("Last active: \(lastActiveText)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

private struct AdminUserDetailView: View {
    let user: StandardWiseUser
    let attempts: [AnswerAttempt]

    private var correctCount: Int {
        attempts.filter(\.isCorrect).count
    }

    private var accuracyText: String {
        guard !attempts.isEmpty else { return "No attempts yet" }

        let accuracy = Double(correctCount) / Double(attempts.count) * 100
        return "\(Int(accuracy.rounded()))%"
    }

    var body: some View {
        List {
            Section("Summary") {
                LabeledContent("Role", value: user.role.displayName)
                LabeledContent("Email", value: user.email)
                LabeledContent("Attempts", value: "\(attempts.count)")
                LabeledContent("Correct", value: "\(correctCount)")
                LabeledContent("Accuracy", value: accuracyText)
            }

            Section("Recent Attempts") {
                if attempts.isEmpty {
                    Text("No answer attempts yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(attempts) { attempt in
                        AdminAttemptRow(attempt: attempt)
                    }
                }
            }
        }
        .navigationTitle(user.name)
    }
}

private struct AdminAttemptRow: View {
    let attempt: AnswerAttempt

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(attempt.standardCode)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(StandardWiseTheme.accent)
                Text("\(attempt.subjectName) - \(attempt.gradeName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Label(
                    attempt.isCorrect ? "Correct" : "Incorrect",
                    systemImage: attempt.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill"
                )
                .font(.caption)
                .foregroundStyle(attempt.isCorrect ? Color.green : Color.red)
            }

            Text("Answer: \(attempt.submittedAnswer)")
                .font(.subheadline)

            Text(attempt.createdAt, style: .date)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

private struct AdminAnalyticsView: View {
    let users: [StandardWiseUser]
    @ObservedObject var questionStore: QuestionStore
    @ObservedObject var answerAttemptStore: AnswerAttemptStore

    private var attempts: [AnswerAttempt] {
        answerAttemptStore.attempts
    }

    private var correctCount: Int {
        attempts.filter(\.isCorrect).count
    }

    private var incorrectCount: Int {
        attempts.count - correctCount
    }

    private var accuracyText: String {
        guard !attempts.isEmpty else { return "No data" }

        let accuracy = Double(correctCount) / Double(attempts.count) * 100
        return "\(Int(accuracy.rounded()))%"
    }

    var body: some View {
        List {
            if let syncStatusMessage = answerAttemptStore.syncStatusMessage {
                Section {
                    Text(syncStatusMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Overview") {
                AnalyticsSummaryGrid(
                    attempts: attempts.count,
                    correct: correctCount,
                    incorrect: incorrectCount,
                    accuracy: accuracyText
                )
            }

            if attempts.isEmpty {
                Section {
                    Text("Analytics will appear after students check answers.")
                        .foregroundStyle(.secondary)
                }
            } else {
                AnalyticsGroupSection(
                    title: "Attempts by Subject",
                    items: AnalyticsGroup.make(from: attempts, keyPath: \.subjectName)
                )

                AnalyticsGroupSection(
                    title: "Attempts by Grade",
                    items: AnalyticsGroup.make(from: attempts, keyPath: \.gradeName)
                )

                AnalyticsGroupSection(
                    title: "Attempts by Standard",
                    items: AnalyticsGroup.make(from: attempts, keyPath: \.standardCode)
                )

                AnalyticsRankSection(
                    title: "Most Practiced Standards",
                    items: AnalyticsGroup.make(from: attempts, keyPath: \.standardCode)
                        .sorted { $0.total > $1.total }
                )

                AnalyticsQuestionSection(
                    title: "Most Missed Questions",
                    items: missedQuestionGroups
                )

                AnalyticsUserSection(
                    users: users,
                    attempts: attempts
                )
            }
        }
        .navigationTitle("Analytics")
    }

    private var missedQuestionGroups: [AnalyticsQuestionGroup] {
        Dictionary(grouping: attempts, by: \.questionID)
            .map { questionID, attempts in
                AnalyticsQuestionGroup(
                    questionID: questionID,
                    prompt: questionStore.questions.first { $0.id == questionID }?.prompt ?? "Question not found",
                    standardCode: attempts.first?.standardCode ?? "Unknown",
                    total: attempts.count,
                    missed: attempts.filter { !$0.isCorrect }.count
                )
            }
            .filter { $0.missed > 0 }
            .sorted {
                if $0.missed == $1.missed {
                    return $0.total > $1.total
                }
                return $0.missed > $1.missed
            }
    }
}

private struct AnalyticsSummaryGrid: View {
    let attempts: Int
    let correct: Int
    let incorrect: Int
    let accuracy: String

    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ],
            spacing: 12
        ) {
            AdminMetricCard(title: "Attempts", value: "\(attempts)", subtitle: "Total checked answers")
            AdminMetricCard(title: "Accuracy", value: accuracy, subtitle: "Correct answer rate")
            AdminMetricCard(title: "Correct", value: "\(correct)", subtitle: "Right answers")
            AdminMetricCard(title: "Incorrect", value: "\(incorrect)", subtitle: "Missed answers")
        }
        .padding(.vertical, 4)
    }
}

private struct AnalyticsGroup: Identifiable {
    let id: String
    let total: Int
    let correct: Int

    var accuracyText: String {
        guard total > 0 else { return "No data" }

        let accuracy = Double(correct) / Double(total) * 100
        return "\(Int(accuracy.rounded()))%"
    }

    static func make(from attempts: [AnswerAttempt], keyPath: KeyPath<AnswerAttempt, String>) -> [AnalyticsGroup] {
        Dictionary(grouping: attempts, by: { $0[keyPath: keyPath] })
            .map { key, attempts in
                AnalyticsGroup(
                    id: key,
                    total: attempts.count,
                    correct: attempts.filter(\.isCorrect).count
                )
            }
            .sorted { $0.id < $1.id }
    }
}

private struct AnalyticsGroupSection: View {
    let title: String
    let items: [AnalyticsGroup]

    private var chartItems: [AnalyticsGroup] {
        Array(items.prefix(8))
    }

    var body: some View {
        Section(title) {
            Chart(chartItems) { item in
                BarMark(
                    x: .value("Correct", item.correct),
                    y: .value("Group", item.id)
                )
                .foregroundStyle(by: .value("Result", "Correct"))

                BarMark(
                    x: .value("Missed", item.total - item.correct),
                    y: .value("Group", item.id)
                )
                .foregroundStyle(by: .value("Result", "Missed"))
            }
            .chartForegroundStyleScale([
                "Correct": StandardWiseTheme.success,
                "Missed": StandardWiseTheme.danger
            ])
            .chartXAxisLabel("Attempts")
            .frame(height: CGFloat(chartItems.count) * 40 + 40)
            .padding(.vertical, 4)
            .accessibilityLabel("\(title) chart")

            ForEach(chartItems) { item in
                HStack {
                    Text(item.id)
                        .font(.subheadline)

                    Spacer()

                    Text("\(item.total) attempts")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(item.accuracyText)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(StandardWiseTheme.accent)
                        .frame(minWidth: 48, alignment: .trailing)
                }
                .padding(.vertical, 2)
            }
        }
    }
}

private struct AnalyticsRankSection: View {
    let title: String
    let items: [AnalyticsGroup]

    var body: some View {
        Section(title) {
            ForEach(Array(items.prefix(5).enumerated()), id: \.element.id) { index, item in
                HStack(spacing: 12) {
                    Text("\(index + 1)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(StandardWiseTheme.accent)
                        .frame(width: 24, height: 24)
                        .background(StandardWiseTheme.accentSoft)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.id)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("\(item.total) attempts")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text(item.accuracyText)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(StandardWiseTheme.accent)
                }
                .padding(.vertical, 2)
            }
        }
    }
}

private struct AnalyticsQuestionGroup: Identifiable {
    let questionID: UUID
    let prompt: String
    let standardCode: String
    let total: Int
    let missed: Int

    var id: UUID { questionID }
}

private struct AnalyticsQuestionSection: View {
    let title: String
    let items: [AnalyticsQuestionGroup]

    var body: some View {
        Section(title) {
            if items.isEmpty {
                Text("No missed questions yet.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(items.prefix(5)) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(item.standardCode)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(StandardWiseTheme.accent)
                            Spacer()
                            Text("\(item.missed) missed of \(item.total)")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }

                        Text(item.prompt)
                            .font(.subheadline)
                            .lineLimit(3)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

private struct AnalyticsUserSection: View {
    let users: [StandardWiseUser]
    let attempts: [AnswerAttempt]

    private var userSummaries: [AnalyticsUserSummary] {
        users.map { user in
            let userAttempts = attempts.filter { $0.userID == user.id }
            return AnalyticsUserSummary(
                user: user,
                total: userAttempts.count,
                correct: userAttempts.filter(\.isCorrect).count
            )
        }
        .sorted { $0.total > $1.total }
    }

    var body: some View {
        Section("User Accuracy") {
            ForEach(userSummaries) { summary in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(summary.user.name)
                            .font(.headline)
                        Text("\(summary.total) attempts")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(summary.accuracyText)
                        .font(.headline)
                        .foregroundStyle(StandardWiseTheme.accent)
                }
                .padding(.vertical, 4)
            }
        }
    }
}

private struct AnalyticsUserSummary: Identifiable {
    let user: StandardWiseUser
    let total: Int
    let correct: Int

    var id: UUID { user.id }

    var accuracyText: String {
        guard total > 0 else { return "No data" }

        let accuracy = Double(correct) / Double(total) * 100
        return "\(Int(accuracy.rounded()))%"
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
