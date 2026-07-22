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
        description: String
    ) {
        self.id = id
        self.subjectID = subjectID
        self.gradeID = gradeID
        self.subjectName = subjectName
        self.gradeName = gradeName
        self.code = code
        self.name = name
        self.description = description
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
