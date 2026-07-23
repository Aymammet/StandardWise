import SwiftUI

struct AdminDashboardView: View {
    let user: StandardWiseUser
    @ObservedObject var questionStore: QuestionStore
    let onLogout: () -> Void

    private let standards = LearningStandard.sampleStandards
    private let users = LocalAuthService.sampleUsers

    private var multipleChoiceCount: Int {
        questionStore.activeQuestions.filter { $0.type == .multipleChoice }.count
    }

    private var inputAnswerCount: Int {
        questionStore.activeQuestions.filter { $0.type == .input }.count
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
                            value: "\(questionStore.activeQuestions.count)",
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
                                destination: AdminQuestionManagementView(questionStore: questionStore)
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

private struct AdminQuestionManagementView: View {
    @ObservedObject var questionStore: QuestionStore
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
        filterOptions(LearningStandard.sampleStandards.map(\.subjectName))
    }

    private var gradeOptions: [String] {
        filterOptions(LearningStandard.sampleStandards.map(\.gradeName))
    }

    private var standardOptions: [String] {
        filterOptions(LearningStandard.sampleStandards.map(\.code))
    }

    var body: some View {
        List {
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
                            .tint(.blue)
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
            AdminQuestionFormView(question: nil) { question in
                questionStore.save(question)
            }
        }
        .sheet(item: $editingQuestion) { question in
            AdminQuestionFormView(question: question) { updatedQuestion in
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
        LearningStandard.sampleStandards.first { $0.id == question.standardID }
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
                    .foregroundStyle(.blue)
                Text(question.type.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
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
    let onSave: (Question) -> Void

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

    private let standards = LearningStandard.sampleStandards

    init(question: Question?, onSave: @escaping (Question) -> Void) {
        self.question = question
        self.onSave = onSave

        let standardID = question?.standardID ?? LearningStandard.sampleStandards[0].id
        let type = question?.type ?? .multipleChoice
        let choices = question?.choices ?? []

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
    }

    private var selectedStandard: LearningStandard {
        standards.first { $0.id == selectedStandardID } ?? standards[0]
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Standard") {
                    Picker("Standard", selection: $selectedStandardID) {
                        ForEach(standards) { standard in
                            Text(standard.displayName)
                                .tag(standard.id)
                        }
                    }

                    Text("\(selectedStandard.subjectName) - \(selectedStandard.gradeName)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Question") {
                    Picker("Type", selection: $questionType) {
                        ForEach(QuestionType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)

                    TextField("Question prompt", text: $prompt, axis: .vertical)
                        .lineLimit(3...6)
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
        }
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
            updatedAt: Date()
        )

        onSave(savedQuestion)
        dismiss()
    }

    private func validate() -> Bool {
        validationMessage = nil

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
