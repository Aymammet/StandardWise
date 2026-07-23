import SwiftUI

struct AdminDashboardView: View {
    let user: StandardWiseUser
    @ObservedObject var questionStore: QuestionStore
    @ObservedObject var standardStore: StandardStore
    @ObservedObject var feedbackStore: FeedbackStore
    @ObservedObject var answerAttemptStore: AnswerAttemptStore
    let onLogout: () -> Void

    private let users = LocalAuthService.sampleUsers

    private var multipleChoiceCount: Int {
        questionStore.activeQuestions.filter { $0.type == .multipleChoice }.count
    }

    private var inputAnswerCount: Int {
        questionStore.activeQuestions.filter { $0.type == .input }.count
    }

    private var newFeedbackCount: Int {
        feedbackStore.feedbackItems.filter { $0.status == .new }.count
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
                            value: "\(standardStore.activeStandards.count)",
                            subtitle: "Ready for practice"
                        )
                        AdminMetricCard(
                            title: "Users",
                            value: "\(users.count)",
                            subtitle: "\(answerAttemptStore.attempts.count) answer attempts"
                        )
                        AdminMetricCard(
                            title: "Feedback",
                            value: "\(feedbackStore.feedbackItems.count)",
                            subtitle: "\(newFeedbackCount) new reports"
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
                                destination: AdminQuestionManagementView(
                                    questionStore: questionStore,
                                    standardStore: standardStore
                                )
                            )
                            AdminNavigationRow(
                                title: "Standards",
                                subtitle: "Manage subject, grade, and standard data",
                                systemImage: "list.bullet.rectangle",
                                destination: AdminStandardsManagementView(standardStore: standardStore)
                            )
                            AdminNavigationRow(
                                title: "Users",
                                subtitle: "See roles, attempts, and accuracy summaries",
                                systemImage: "person.2",
                                destination: AdminUsersView(
                                    users: users,
                                    answerAttemptStore: answerAttemptStore
                                )
                            )
                            AdminNavigationRow(
                                title: "Feedback",
                                subtitle: "Read student reports and question notes",
                                systemImage: "bubble.left.and.bubble.right",
                                destination: AdminFeedbackView(
                                    feedbackStore: feedbackStore,
                                    questionStore: questionStore
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
    }

    private var filteredStandards: [LearningStandard] {
        standardStore.activeStandards.filter { standard in
            standard.subjectID == selectedSubjectID && standard.gradeID == selectedGradeID
        }
    }

    private var selectedStandard: LearningStandard {
        standardStore.standards.first { $0.id == selectedStandardID } ?? filteredStandards[0]
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
                        .tint(.blue)
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
                        .tint(.blue)
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
                    .foregroundStyle(.blue)
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
    @State private var statusFilter = "All"

    private var filteredFeedback: [QuestionFeedback] {
        feedbackStore.feedbackItems.filter { feedback in
            statusFilter == "All" || feedback.status.displayName == statusFilter
        }
    }

    var body: some View {
        List {
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
                            question: question(for: feedback)
                        ) { status in
                            feedbackStore.updateStatus(for: feedback, status: status)
                        }
                    }
                }
            }
        }
        .navigationTitle("Feedback")
    }

    private func question(for feedback: QuestionFeedback) -> Question? {
        questionStore.questions.first { $0.id == feedback.questionID }
    }
}

private struct AdminFeedbackRow: View {
    let feedback: QuestionFeedback
    let question: Question?
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

            Text(feedback.message)
                .font(.headline)

            if let question {
                VStack(alignment: .leading, spacing: 4) {
                    Text(question.standardCode)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
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
}

private struct AdminUsersView: View {
    let users: [StandardWiseUser]
    @ObservedObject var answerAttemptStore: AnswerAttemptStore

    var body: some View {
        List {
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
                    .foregroundStyle(.blue)
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
