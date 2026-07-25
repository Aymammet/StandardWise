import Foundation

struct LearningStandard: Identifiable, Codable, Equatable {
    let id: UUID
    let subjectID: UUID
    let gradeID: UUID
    let subjectName: String
    let gradeName: String
    let code: String
    let name: String
    let description: String
    let isActive: Bool

    var displayName: String {
        "\(code): \(name)"
    }

    init(
        id: UUID = UUID(),
        subjectID: UUID,
        gradeID: UUID,
        subjectName: String,
        gradeName: String,
        code: String,
        name: String,
        description: String,
        isActive: Bool = true
    ) {
        self.id = id
        self.subjectID = subjectID
        self.gradeID = gradeID
        self.subjectName = subjectName
        self.gradeName = gradeName
        self.code = code
        self.name = name
        self.description = description
        self.isActive = isActive
    }
}

@MainActor
final class StandardStore: ObservableObject {
    @Published private(set) var subjects: [AcademicSubject] {
        didSet {
            LocalPersistence.save(subjects, forKey: subjectsStorageKey)
        }
    }
    @Published private(set) var grades: [GradeLevel] {
        didSet {
            LocalPersistence.save(grades, forKey: gradesStorageKey)
        }
    }
    @Published private(set) var standards: [LearningStandard] {
        didSet {
            LocalPersistence.save(standards, forKey: standardsStorageKey)
        }
    }
    @Published private(set) var syncStatusMessage: String?

    private let subjectsStorageKey = "standardwise.subjects"
    private let gradesStorageKey = "standardwise.grades"
    private let standardsStorageKey = "standardwise.standards"
    private let usesFirebaseStandards = StandardWiseAuthMode.current == .staging

    /// IDs of subjects/standards edited locally that have not confirmed a
    /// Firebase save yet. Firebase refreshes keep the local copy for these IDs
    /// so an in-flight edit is not overwritten by stale remote data.
    private var pendingSyncSubjectIDs: Set<UUID> = []
    private var pendingSyncStandardIDs: Set<UUID> = []

    init(
        subjects: [AcademicSubject] = StandardWiseSampleData.subjects,
        grades: [GradeLevel] = StandardWiseSampleData.grades,
        standards: [LearningStandard] = LearningStandard.sampleStandards
    ) {
        if let savedSubjects = LocalPersistence.load([AcademicSubject].self, forKey: subjectsStorageKey) {
            self.subjects = savedSubjects
        } else {
            self.subjects = subjects
            LocalPersistence.save(subjects, forKey: subjectsStorageKey)
        }

        if let savedGrades = LocalPersistence.load([GradeLevel].self, forKey: gradesStorageKey) {
            self.grades = savedGrades
        } else {
            self.grades = grades
            LocalPersistence.save(grades, forKey: gradesStorageKey)
        }

        if let savedStandards = LocalPersistence.load([LearningStandard].self, forKey: standardsStorageKey) {
            self.standards = savedStandards
        } else {
            self.standards = standards
            LocalPersistence.save(standards, forKey: standardsStorageKey)
        }

        if usesFirebaseStandards {
            syncStatusMessage = "Syncing subjects and standards from Firebase..."
            Task {
                await loadFirebaseStandards(
                    fallbackSubjects: subjects,
                    fallbackGrades: grades,
                    fallbackStandards: standards
                )
            }
        }
    }

    var activeSubjects: [AcademicSubject] {
        subjects.filter(\.isActive).sorted { $0.name < $1.name }
    }

    var activeStandards: [LearningStandard] {
        standards.filter(\.isActive)
    }

    func saveSubject(_ subject: AcademicSubject) {
        if let index = subjects.firstIndex(where: { $0.id == subject.id }) {
            subjects[index] = subject
        } else {
            subjects.append(subject)
        }

        pendingSyncSubjectIDs.insert(subject.id)
        syncSubjectToFirebase(subject)
    }

    func archiveSubject(_ subject: AcademicSubject) {
        saveSubject(
            AcademicSubject(
                id: subject.id,
                name: subject.name,
                isActive: false
            )
        )
    }

    func saveStandard(_ standard: LearningStandard) {
        if let index = standards.firstIndex(where: { $0.id == standard.id }) {
            standards[index] = standard
        } else {
            standards.insert(standard, at: 0)
        }

        pendingSyncStandardIDs.insert(standard.id)
        syncStandardToFirebase(standard)
    }

    func archiveStandard(_ standard: LearningStandard) {
        saveStandard(
            LearningStandard(
                id: standard.id,
                subjectID: standard.subjectID,
                gradeID: standard.gradeID,
                subjectName: standard.subjectName,
                gradeName: standard.gradeName,
                code: standard.code,
                name: standard.name,
                description: standard.description,
                isActive: false
            )
        )
    }

    func refreshFromFirebaseIfNeeded() async {
        guard usesFirebaseStandards else { return }
        await loadFirebaseStandards(
            fallbackSubjects: subjects,
            fallbackGrades: grades,
            fallbackStandards: standards
        )
    }

    private func loadFirebaseStandards(
        fallbackSubjects: [AcademicSubject],
        fallbackGrades: [GradeLevel],
        fallbackStandards: [LearningStandard]
    ) async {
        do {
            let firebaseData = try await FirebaseStandardsService.loadStandardsData(
                fallbackSubjects: fallbackSubjects,
                fallbackGrades: fallbackGrades,
                fallbackStandards: fallbackStandards
            )
            var remoteSubjects = firebaseData.subjects
            var remoteStandards = firebaseData.standards

            // Keep local versions of subjects/standards with unsynced edits.
            for pendingID in pendingSyncSubjectIDs {
                guard let localSubject = subjects.first(where: { $0.id == pendingID }) else { continue }

                if let index = remoteSubjects.firstIndex(where: { $0.id == pendingID }) {
                    remoteSubjects[index] = localSubject
                } else {
                    remoteSubjects.append(localSubject)
                }
            }

            for pendingID in pendingSyncStandardIDs {
                guard let localStandard = standards.first(where: { $0.id == pendingID }) else { continue }

                if let index = remoteStandards.firstIndex(where: { $0.id == pendingID }) {
                    remoteStandards[index] = localStandard
                } else {
                    remoteStandards.insert(localStandard, at: 0)
                }
            }

            subjects = remoteSubjects
            grades = firebaseData.grades
            standards = remoteStandards
            syncStatusMessage = "Subjects and standards are synced with Firebase."
        } catch {
            syncStatusMessage = "Using local subjects and standards because Firebase is unavailable."
        }
    }

    private func syncSubjectToFirebase(_ subject: AcademicSubject) {
        guard usesFirebaseStandards else { return }

        Task {
            do {
                try await FirebaseStandardsService.saveSubject(subject)
                pendingSyncSubjectIDs.remove(subject.id)
                syncStatusMessage = "Subject saved to Firebase."
            } catch {
                syncStatusMessage = "Subject saved locally. Firebase sync failed."
            }
        }
    }

    private func syncStandardToFirebase(_ standard: LearningStandard) {
        guard usesFirebaseStandards else { return }

        Task {
            do {
                try await FirebaseStandardsService.saveStandard(standard)
                pendingSyncStandardIDs.remove(standard.id)
                syncStatusMessage = "Standard saved to Firebase."
            } catch {
                syncStatusMessage = "Standard saved locally. Firebase sync failed."
            }
        }
    }
}

extension LearningStandard {
    static let sampleStandards: [LearningStandard] = [
        LearningStandard(
            subjectID: StandardWiseSampleData.mathSubjectID,
            gradeID: StandardWiseSampleData.grade6ID,
            subjectName: "Math",
            gradeName: "6th",
            code: "6.RP.1",
            name: "Understand ratio concepts",
            description: "Understand the concept of a ratio and use ratio language to describe a relationship between two quantities."
        ),
        LearningStandard(
            subjectID: StandardWiseSampleData.mathSubjectID,
            gradeID: StandardWiseSampleData.grade6ID,
            subjectName: "Math",
            gradeName: "6th",
            code: "6.EE.3a",
            name: "Apply properties to equivalent expressions",
            description: "Apply properties of operations to generate equivalent expressions."
        ),
        LearningStandard(
            subjectID: StandardWiseSampleData.elaSubjectID,
            gradeID: StandardWiseSampleData.grade6ID,
            subjectName: "ELA",
            gradeName: "6th",
            code: "RL.6.1",
            name: "Cite textual evidence",
            description: "Cite textual evidence to support analysis of what the text says explicitly and inferences drawn from the text."
        ),
        LearningStandard(
            subjectID: StandardWiseSampleData.mathSubjectID,
            gradeID: StandardWiseSampleData.grade7ID,
            subjectName: "Math",
            gradeName: "7th",
            code: "7.RP.2",
            name: "Recognize proportional relationships",
            description: "Recognize and represent proportional relationships between quantities."
        ),
        LearningStandard(
            subjectID: StandardWiseSampleData.elaSubjectID,
            gradeID: StandardWiseSampleData.grade7ID,
            subjectName: "ELA",
            gradeName: "7th",
            code: "RL.7.2",
            name: "Determine theme or central idea",
            description: "Determine a theme or central idea of a text and analyze its development over the course of the text."
        ),
        LearningStandard(
            subjectID: StandardWiseSampleData.mathSubjectID,
            gradeID: StandardWiseSampleData.grade8ID,
            subjectName: "Math",
            gradeName: "8th",
            code: "8.EE.5",
            name: "Graph proportional relationships",
            description: "Graph proportional relationships and interpret the unit rate as the slope of the graph."
        ),
        LearningStandard(
            subjectID: StandardWiseSampleData.elaSubjectID,
            gradeID: StandardWiseSampleData.grade8ID,
            subjectName: "ELA",
            gradeName: "8th",
            code: "RI.8.1",
            name: "Cite textual evidence from informational text",
            description: "Cite textual evidence that most strongly supports analysis of informational text."
        )
    ]
}
