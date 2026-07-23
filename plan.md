# StandardWise Development Plan

This plan reflects the active Xcode target as of July 2026. StandardWise is a SwiftUI app for standards-based student practice, with separate regular-user and admin experiences planned. The current app is an early local prototype with grade, subject, and standard dropdowns plus sample generated questions.

## Status Legend

- `[x]` Complete locally
- `[~]` Partially complete
- `[ ]` Not started

## 1. Stabilize Current SwiftUI Prototype `[x]`

- Keep the active `StandardWise` Xcode target clean and buildable.
- Preserve the current grade, subject, and standard selection flow.
- Keep dropdown-style controls for Grade, Subject, and Standard.
- Continue using the existing `Models` and `Services` folders until the app needs a larger feature-based structure.
- Make sure local Xcode user-state files stay out of Git.
- Keep `plan.md` as the source of truth for upcoming features and build order.
- Verified the app builds successfully with the active `StandardWise` scheme.

**Done when:** the app builds cleanly, the current prototype works from Xcode, and every project file has a clear purpose.

## 2. Define Core App Architecture `[x]`

- Create a clear app structure for shared models, services, session state, and feature views.
- Decide whether to keep the simple folder layout or move toward `Core` and `Features` folders as the app grows.
- Separate regular-user practice screens from admin management screens.
- Add shared design values for colors, spacing, card styling, and button styling.
- Keep business logic out of SwiftUI views where possible.
- Created `Core/Models`, `Core/Services`, `Core/DesignSystem`, and `Features/Practice`.
- Moved the current practice screen into `Features/Practice/PracticeView.swift`.
- Added `StandardWiseTheme` for shared card styling values.
- Updated the Xcode project references to match the new source tree.
- Verified the app builds successfully after the architecture update.

**Done when:** the project has a predictable source tree and each major app area has a clear place to live.

## 3. Build Core Data Models `[x]`

- Expand the current `OhioStandard` model into a full Standard model with subject, grade, code, name, and description.
- Replace the current simple `PracticeProblem` model with a full Question model.
- Support multiple choice questions with A, B, C, and D choices.
- Support input-answer questions where students type an answer.
- Add models for User, Subject, Grade, Standard, Question, AnswerAttempt, and Feedback.
- Add role support for admin and regular users.
- Add fields for created date, updated date, active status, and created-by admin where needed.
- Added `StandardWiseUser` and `UserRole`.
- Added `AcademicSubject` and `GradeLevel`.
- Replaced `OhioStandard` with `LearningStandard`.
- Replaced `PracticeProblem` with `Question`, `QuestionType`, and `AnswerChoice`.
- Added `AnswerAttempt`.
- Added `QuestionFeedback` and `FeedbackStatus`.
- Added `StandardWiseSampleData` for stable local subject and grade IDs.
- Updated the current practice flow to compile against `LearningStandard` and `Question`.
- Verified the app builds successfully with the new model layer.

**Done when:** app data can represent users, standards, questions, answers, attempts, and feedback without relying on placeholder-only structures.

## 4. Replace Hard-Coded Generator With Question Data `[x]`

- Replace `ProblemGenerator` switch logic with structured sample question data.
- Filter available questions by subject, grade, and standard.
- Randomly or sequentially select a question from the matching question list.
- Show a friendly empty state when no questions exist for the selected standard.
- Keep local sample data first, before connecting a real database.
- Added `QuestionBank` as a structured local question source.
- Added sample input-answer and multiple-choice questions.
- Updated `ProblemGenerator` to select from `QuestionBank` instead of using hard-coded switch branches.
- Updated the practice screen to request questions by subject, grade, and standard.
- Added a friendly no-question message when no local question exists for the selected standard.
- Display multiple-choice answer choices on generated question cards.
- Verified the app builds successfully with the local question bank.

**Done when:** the Generate Question button loads a real question object from sample data instead of creating one through hard-coded switch cases.

## 5. Complete Regular User Practice Flow `[~]`

- Show the main practice screen after regular-user login.
- Present dropdowns in this order: Subject, Grade, Standard.
- Include subjects such as Math, ELA, Science, and future subjects.
- Include grades such as 6th, 7th, 8th, 9th, and future grades.
- Show standard names with code and title, for example `6.RP.1: Understand ratio concepts`.
- Add a clear Generate Question button.
- Display the selected question below the dropdowns.
- Support multiple choice answer selection.
- Support typed input answers.
- Prevent answer checking until the user selects or enters an answer.
- Reordered the practice dropdowns to Subject, Grade, Standard.
- Disabled Generate when no standard is available.
- Added a no-standards message for subject and grade combinations that do not have standards yet.
- Added selectable multiple-choice answer buttons.
- Added a typed-answer field for input-answer questions.
- Added a Check Answer button that stays disabled until the user selects or enters an answer.
- Reset answer state when a new question is generated.
- Verified the app builds successfully after the practice-flow update.

**Done when:** a regular user can choose a subject, grade, and standard, generate a matching question, answer it, and check the result.

## 6. Implement Answer Checking and Feedback UI `[x]`

- Add a Check Answer button below each question.
- Highlight a correct selected answer in green.
- Highlight an incorrect selected answer in red.
- Highlight the correct answer in green when the user is wrong.
- For input answers, compare typed answer against the correct answer and accepted alternate answers.
- Show text feedback in addition to color feedback.
- Show the explanation only after the user checks an answer.
- Reset selected answer, typed answer, feedback, and explanation when a new question is generated.
- Added real answer checking for multiple-choice and input-answer questions.
- Added accepted alternate answer comparison for typed answers.
- Normalized typed answers before comparison.
- Highlighted the correct multiple-choice answer in green after checking.
- Highlighted the user's incorrect multiple-choice answer in red after checking.
- Added Correct and Incorrect text feedback with icons.
- Show the explanation only after the answer is checked.
- Disabled answer editing after checking.
- Verified the app builds successfully after the answer-checking update.

**Done when:** students receive clear correct or incorrect feedback for both multiple choice and input-answer questions.

## 7. Add Login and Session Routing `[x]`

- Create a Login screen with email and password fields.
- Add a Login button with loading and error states.
- Add role-based routing after login.
- Send admin users to the Admin Dashboard.
- Send regular users to the Main Practice screen.
- Use local sample users first while the database/auth choice is still open.
- Keep user-facing error messages simple and friendly.
- Added a local login screen for email and password.
- Added sample admin and regular-user accounts.
- Added app session state for login, logout, loading, and login errors.
- Added root routing so admins open the Admin Dashboard and regular users open the Practice screen.
- Added Logout buttons for admin and regular-user flows.
- Added an early Admin Dashboard placeholder with the planned admin areas.
- Verified the app builds successfully after the login and routing update.

**Done when:** logging in as an admin or regular user opens the correct app experience.

## 8. Build Admin Dashboard `[x]`

- Create an admin-only dashboard screen.
- Add admin navigation for Questions, Standards, Users, Feedback, and Analytics.
- Show overview cards for total questions, total users, recent feedback, most practiced standards, and high-miss questions.
- Keep admin screens dense, clear, and easy to scan.
- Prevent regular users from opening admin pages.
- Replaced the placeholder admin list with a dashboard layout.
- Added overview cards for local questions, standards, users, and input-answer questions.
- Added admin navigation rows for Questions, Standards, Users, Feedback, and Analytics.
- Added placeholder destination pages for each admin area so navigation is ready for the next steps.
- Kept admin access behind role-based login routing.
- Verified the app builds successfully after the dashboard update.

**Done when:** admin users have a central dashboard with navigation to all management areas.

## 9. Build Admin Question Management `[x]`

- Create a question list page.
- Add search and filters for subject, grade, standard, and question type.
- Add an Add Question button.
- Add an Edit button for each question.
- Add delete or archive behavior with confirmation.
- Build a question form with subject, grade, standard, prompt, type, choices, correct answer, alternate answers, and explanation.
- Add a subject dropdown to the Add/Edit Question form so admins can choose the subject before selecting grade and standard.
- Filter the grade and standard dropdowns in the question form based on the selected subject.
- Validate required fields before saving.
- Save locally first, then connect to the database later.
- Added a shared local `QuestionStore` for the current app session.
- Connected regular-user question generation to the shared local question store.
- Replaced the admin Questions placeholder with a real question management screen.
- Added search plus filters for subject, grade, standard, question type, and active/archive status.
- Added an Add Question form for multiple-choice and input-answer questions.
- Added a clear Subject dropdown to the Add/Edit Question form.
- Filtered the question form's Grade and Standard choices based on the selected subject.
- Added edit support by tapping a question or using the edit swipe action.
- Added archive support with confirmation so archived questions no longer appear in regular-user generation.
- Added validation for required prompt, explanation, answers, and multiple-choice choices.
- Verified the app builds successfully after the admin question management update.

**Done when:** admins can create, edit, archive, and review practice questions from inside the app.

## 10. Build Admin Standards Management `[x]`

- Create a standards management page.
- Let admins view subjects, grades, and standards.
- Add an Add Standard button.
- When admin taps Add Standard, open a form to add a new standard with code, name, subject, grade, and description.
- Support standards such as `6.G.1: Basic concepts of geometry`.
- Add edit behavior for existing standards.
- Add a subjects management area inside the admin Standards page.
- Add an Add Subject button.
- When admin taps Add Subject, open a form to add a new subject.
- Support subjects such as Science, ELA, Math, and future subjects.
- Make newly added subjects available when creating or editing standards.
- Store standard code, standard name, subject, grade, and full description.
- Store subject name and active/archive status.
- Make sure the regular-user Standard dropdown uses the same standards data.
- Make sure the regular-user Subject dropdown uses the same subjects data.
- Added a shared local `StandardStore` for subjects, grades, and standards.
- Connected regular-user Subject and Standard dropdowns to the shared standard store.
- Replaced the admin Standards placeholder with a real standards management screen.
- Added subject list, Add Subject form, Edit Subject flow, and subject archive action.
- Added standards list, Add Standard form, Edit Standard flow, and standard archive action.
- Added validation for required subject name, standard code, standard name, and standard description.
- Connected the Admin Add/Edit Question form to the shared standard store.
- Verified the app builds successfully after the admin standards management update.

**Done when:** admins can manage the subjects and standards that appear in the regular-user dropdowns.

## 11. Build Feedback Flow `[x]`

- Add a Send Feedback button below generated questions.
- Let regular users submit a short message about a question.
- Attach feedback to the related question and user.
- Create an admin Feedback page.
- Show feedback status as New, Reviewed, or Resolved.
- Let admins update feedback status.
- Added a shared local `FeedbackStore` for feedback submitted during the current app session.
- Added a Send Feedback button below generated questions.
- Added a feedback form that attaches the message to the current user and question.
- Added validation so empty feedback messages cannot be submitted.
- Replaced the admin Feedback placeholder with a real feedback review page.
- Added admin status filtering for All, New, Reviewed, and Resolved feedback.
- Added segmented status controls so admins can update feedback status.
- Added a dashboard feedback metric showing total feedback and new reports.
- Verified the app builds successfully after the feedback flow update.

**Done when:** students can report confusing or incorrect questions, and admins can review those reports.

## 12. Track Users and Answer Attempts `[x]`

- Save each answer attempt with user, question, selected or typed answer, correctness, and date.
- Track attempts by subject, grade, standard, and question.
- Create an Admin Users page.
- Show each user's role, last active date, questions attempted, and accuracy summary.
- Prepare this data for analytics screens.
- Added a shared local `AnswerAttemptStore` for the current app session.
- Recorded an answer attempt each time a regular user checks an answer.
- Saved user, question, submitted answer, correctness, subject, grade, standard, and date for each attempt.
- Added an Admin Users page with user role, email, attempt count, accuracy, and last activity.
- Added user detail pages with summary metrics and recent answer attempts.
- Added dashboard attempt count under the Users metric.
- Verified the app builds successfully after the answer-attempt tracking update.

**Done when:** the app records student practice activity and admins can review basic user progress.

## 13. Add Database and Persistence `[ ]`

- Choose the database approach for the app.
- Move users, subjects, grades, standards, questions, attempts, and feedback into persistent storage.
- Connect Generate Question to database questions.
- Connect admin question creation and editing to database records.
- Connect feedback submission to database records.
- Add loading, empty, retry, and error states around database reads and writes.

**Done when:** app data survives app restarts and admin-created questions become available to regular users.

## 14. Build Admin Analytics `[ ]`

- Show attempts by subject.
- Show attempts by grade.
- Show attempts by standard.
- Show correct vs incorrect answer rates.
- Highlight most missed questions.
- Highlight most practiced standards.
- Show user-level accuracy summaries.
- Start with simple lists and summary cards before adding charts.

**Done when:** admins can understand student practice patterns and identify weak standards or problematic questions.

## 15. Polish UI and UX `[ ]`

- Keep the regular-user screen simple, focused, and student-friendly.
- Use readable font sizes and clear spacing.
- Use cards for question display and admin list items.
- Use consistent button styles.
- Add clear empty states when no questions or feedback exist.
- Add clear loading states when data is being fetched.
- Add friendly error messages.
- Make dropdown labels and answer controls easy to understand.
- Make the app work well on different screen sizes.

**Done when:** both regular-user and admin experiences feel clean, understandable, and ready for real use.

## 16. Accessibility and Answer Clarity `[ ]`

- Make every button, dropdown, and text field clearly labeled.
- Do not rely only on color for correctness feedback.
- Add text feedback for correct and incorrect answers.
- Use placeholders that explain what users should enter.
- Ensure tap targets are comfortable.
- Keep explanation text readable.

**Done when:** users can understand and use the practice flow even without relying only on color or visual layout.

## 17. Testing and Quality Checks `[ ]`

- Test login as admin and regular user.
- Test subject, grade, and standard filtering.
- Test question generation.
- Test multiple choice answer checking.
- Test typed input answer checking.
- Test empty states when no questions exist.
- Test admin add and edit question flow.
- Test feedback submission and admin review.
- Test database save and load behavior once persistence is added.
- Run Xcode builds before committing major changes.

**Done when:** the main student and admin workflows can be tested reliably after each major build step.

## 18. Git and Release Workflow `[~]`

- Keep the local repo connected to `git@github.com:Aymammet/StandardWise.git`.
- Commit each meaningful feature step with a clear message.
- Push completed work to GitHub.
- Avoid committing local Xcode user-state files.
- Use `plan.md` to decide the next feature before coding.

**Done when:** the GitHub repo always reflects the latest stable local work.

## Open Decisions

- Which database should StandardWise use?
- Should login use Firebase, Supabase, local school accounts, or another auth system?
- Will users create their own accounts, or will admin users create accounts for them?
- Should the app require internet connection?
- Should questions be random, sequential, or adaptive based on past answers?
- Should students see progress history?
- Should admins be able to import questions from CSV, spreadsheet, or document files?
- Should questions support images, diagrams, tables, or reading passages?
- Should ELA passages connect to multiple questions?
- Should there be difficulty levels for questions?

## Immediate Next Step

- Start with milestone 4: replace the current hard-coded `ProblemGenerator` with structured local question data that supports both multiple choice and input-answer questions.
