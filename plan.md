# StandardWise Development Plan

This plan reflects the active Xcode target as of July 2026. StandardWise is a SwiftUI app for standards-based student practice with separate student and admin experiences. Students generate standards-aligned questions, see instant feedback, and review a Today summary; admins manage questions, images, standards, users, and feedback with charts-based analytics. The app runs in Local mode (sample logins, on-device data) and Staging mode (Firebase Auth plus Firestore sync).

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

## 5. Complete Regular User Practice Flow `[x]`

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
- Added sample standards for Science (6.PS.1 in 6th, 7.LS.1 in 7th) and 9th grade (A1.SSE.1 for Math, RL.9-10.1 for ELA) so every sample subject and grade has practice content.
- Added sample multiple-choice and input questions for the new standards.
- Added a sample-data merge on launch so existing installs with persisted local data pick up newly added sample subjects, grades, standards, and questions without duplicating admin-edited or archived entries.

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

## 13. Add Database and Persistence `[x]`

- Choose the database approach for the app.
- Move users, subjects, grades, standards, questions, attempts, and feedback into persistent storage.
- Connect Generate Question to database questions.
- Connect admin question creation and editing to database records.
- Connect feedback submission to database records.
- Add loading, empty, retry, and error states around database reads and writes.
- Chose local on-device persistence first using encoded app data in `UserDefaults`.
- Added shared local persistence helpers for Codable app data.
- Persisted questions so admin-created and edited questions survive app restarts.
- Persisted subjects and standards so admin-created dropdown data survives app restarts.
- Persisted feedback so student reports and admin status updates survive app restarts.
- Persisted answer attempts so user progress summaries survive app restarts.
- Connected regular-user question generation to persisted question and standard data.
- Left remote/cloud database selection as a future decision when the app needs multi-device or shared school data.
- Verified the app builds successfully after the local persistence update.

**Done when:** app data survives app restarts and admin-created questions become available to regular users.

## 14. Build Admin Analytics `[x]`

- Show attempts by subject.
- Show attempts by grade.
- Show attempts by standard.
- Show correct vs incorrect answer rates.
- Highlight most missed questions.
- Highlight most practiced standards.
- Show user-level accuracy summaries.
- Start with simple lists and summary cards before adding charts.
- Replaced the admin Analytics placeholder with a real analytics page.
- Added overview cards for total attempts, accuracy, correct answers, and incorrect answers.
- Added grouped attempt summaries by subject, grade, and standard.
- Added most practiced standards based on attempt count.
- Added most missed questions based on incorrect attempt count.
- Added user-level accuracy summaries.
- Added an empty analytics state for when no answers have been checked yet.
- Verified the app builds successfully after the analytics update.

**Done when:** admins can understand student practice patterns and identify weak standards or problematic questions.

## 15. Polish UI and UX `[x]`

- Keep the regular-user screen simple, focused, and student-friendly.
- Use readable font sizes and clear spacing.
- Use cards for question display and admin list items.
- Use consistent button styles.
- Add clear empty states when no questions or feedback exist.
- Add clear loading states when data is being fetched.
- Add friendly error messages.
- Make dropdown labels and answer controls easy to understand.
- Make the app work well on different screen sizes.
- Improved the regular-user practice screen heading and helper text.
- Changed the Generate button wording to `Generate Question`.
- Improved the ready/empty state below the practice controls.
- Added clearer visual selection styling for multiple-choice answers.
- Made the admin dashboard intro more direct and easier to scan.
- Improved admin metric card sizing for a steadier dashboard layout.
- Added chevrons to admin navigation rows so tappable areas are clearer.
- Verified the app builds successfully after the UI polish update.

**Done when:** both regular-user and admin experiences feel clean, understandable, and ready for real use.

## 16. Accessibility and Answer Clarity `[x]`

- Make every button, dropdown, and text field clearly labeled.
- Do not rely only on color for correctness feedback.
- Add text feedback for correct and incorrect answers.
- Use placeholders that explain what users should enter.
- Ensure tap targets are comfortable.
- Keep explanation text readable.
- Added accessibility labels and hints to login fields, dropdowns, Generate Question, Check Answer, Send Feedback, and Logout.
- Added text and icon status labels for selected, correct, and incorrect multiple-choice answers.
- Added stronger answer borders so correctness is not communicated by color alone.
- Added accessible answer-result summaries that include correctness, correct typed answer when needed, and explanation text.
- Improved typed-answer and feedback placeholders.
- Increased control size for primary practice and login buttons.

**Done when:** users can understand and use the practice flow even without relying only on color or visual layout.

## 17. Login and Practice UI Follow-Up `[x]`

- Improve login error messages so users know what to fix.
- If the username/email exists but the password is wrong, show `Wrong password.`
- If the username/email does not exist, show `No username exists.`
- Keep Firebase and Local login error behavior consistent where possible.
- Use the Firestore `users` collection as the staging source of truth for username existence before password sign-in.
- Add an eye icon to the password field so users can show or hide the password while typing.
- Keep the password visible/hidden state accessible for VoiceOver.
- Improve the student `Check Answer` button alignment.
- Make `Check Answer` full width so it matches the main action style and is easier to tap.
- Added separate local login errors for missing username and wrong password.
- Added a Firestore `users` lookup before staging sign-in so missing usernames can show `No username exists.`
- Added `Wrong password.` for staging password failures after the username is confirmed to exist.
- Temporarily allow the existing staging admin email while Firebase user records are being seeded.
- Added a password eye button to show or hide password entry.
- Updated `Check Answer` to use a full-width primary button.

**Done when:** login errors are specific, password visibility can be toggled, and the Check Answer button is visually aligned with the student practice flow.

## 18. Write and Update README `[x]`

- Create or update `README.md` for the StandardWise repo.
- Explain what the app does in clear language.
- Document admin and regular-user sample logins.
- Summarize current features for regular users and admins.
- Include local setup instructions for opening/running the Xcode project.
- Mention that data is currently local/in-memory until database persistence is added.
- Keep README updated when major features are added.
- Created `README.md` with the app overview, current features, login accounts, local/staging setup, Firebase status, planned Firestore collections, and project structure.

**Done when:** the repo has a clear README that explains the app, current features, test logins, and local setup.

## 19. Testing and Quality Checks `[~]`

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
- Added `QA_CHECKLIST.md` to track manual workflow checks.
- Verified `StandardWise Local` builds successfully.
- Verified `StandardWise Staging` builds successfully.
- Installed and launched the simulator build successfully.
- Confirmed the app opens to the login screen in the simulator.
- Confirmed the project does not have an automated test target yet.
- Manual simulator workflow testing is still pending.

**Done when:** the main student and admin workflows can be tested reliably after each major build step.

## 20. Git and Release Workflow `[x]`

- Keep the local repo connected to `git@github.com:Aymammet/StandardWise.git`.
- Commit each meaningful feature step with a clear message.
- Push completed work to GitHub.
- Avoid committing local Xcode user-state files.
- Use `plan.md` to decide the next feature before coding.
- Verified the working tree is clean after the latest push.
- Confirmed latest pushed commit: `f138fe5 Complete milestone 5: practice content for every sample subject and grade`.
- Local commits `5222630` (UI redesign) and later work are ready to push. Note: a commit that included a `.github/workflows/` file was rejected because Xcode's stored GitHub credential lacks the `workflow` scope; the workflow file was removed from history and saved for manual addition later (see milestone 24).
- Confirmed the repo is connected to `git@github.com:Aymammet/StandardWise.git`.

**Done when:** the GitHub repo always reflects the latest stable local work.

## 21. Add Firebase for Production Data `[x]`

- Create a Firebase project for StandardWise.
- Add the iOS Firebase config file to the Xcode app target.
- Add Firebase SDK packages needed for app startup, authentication, and Firestore.
- Initialize Firebase when the app launches.
- Move login from local sample accounts to Firebase Authentication.
- Add admin role handling so admins and regular users open the correct screens.
- Create Firestore collections for users, subjects, standards, questions, answer attempts, and feedback.
- Move admin-created subjects, standards, and questions from local storage to Firestore.
- Move student answer attempts and feedback from local storage to Firestore.
- Add loading, empty, retry, and error states for Firebase reads and writes.
- Add Firebase security rules so regular users cannot edit admin-only data.
- Add a migration path from existing local sample data to Firebase seed data.
- Test app launch, login, question generation, admin editing, feedback, and analytics with Firebase enabled.
- Added the Firebase config file to the app target.
- Added FirebaseCore, FirebaseAuth, and FirebaseFirestore packages.
- Initialized Firebase when the app launches.
- Resolved Firebase package dependencies and verified the app builds.
- Connected the login flow to Firebase Authentication.
- Added temporary role mapping: `admin@standardwise.app` opens the admin dashboard; other Firebase users open the regular practice screen.
- Added shared Xcode schemes for `StandardWise Local` and `StandardWise Staging`.
- Local mode uses sample login credentials for simulator testing without Firebase.
- Staging mode uses Firebase email/password authentication.
- Current Staging behavior: login uses Firebase Auth; subjects, grades, standards, questions, feedback, and answer attempts sync with Firestore. Analytics are calculated in the app from synced answer attempts.
- Added a Firebase user/profile service for the Firestore `users` collection.
- Staging login now checks Firestore user records for regular-user username existence before password sign-in.
- Staging login now reads the authenticated user's Firestore profile for name, role, created date, and last active date.
- Staging login now creates or updates a Firestore `users` document after successful admin sign-in, so the admin profile can be seeded from the app.
- Regular staging users should have a matching Firestore `users` document before login; the temporary admin bridge remains only to prevent admin lockout during setup.
- Verified both `StandardWise Staging` and `StandardWise Local` build successfully after adding the Firestore user/profile layer.
- Firebase Auth login now continues when Firestore is temporarily offline, using a fallback profile for the current session.
- Added a Firebase standards service for `subjects`, `grades`, and `standards`.
- Staging now loads subjects, grades, and standards from Firestore when available.
- Staging seeds empty Firestore subject, grade, and standard collections from the current local sample data.
- Admin-created subjects and standards now save locally first, then sync to Firestore in Staging mode.
- Added an admin Standards sync status message so Firebase availability is visible.
- Verified both `StandardWise Staging` and `StandardWise Local` build successfully after adding Firestore standards sync.
- Added a Firebase questions service for the Firestore `questions` collection.
- Staging now loads questions from Firestore when available.
- Staging seeds an empty Firestore question collection from the current local sample data.
- Admin-created and archived questions now save locally first, then sync to Firestore in Staging mode.
- Student question generation now uses the synced Staging question list.
- Added an admin Questions sync status message so Firebase availability is visible.
- Verified both `StandardWise Staging` and `StandardWise Local` build successfully after adding Firestore questions sync.
- Added a Firebase feedback service for the Firestore `feedback` collection.
- Staging now loads feedback from Firestore when available.
- Student feedback submissions now save locally first, then sync to Firestore in Staging mode.
- Admin feedback status changes now sync to Firestore in Staging mode.
- Added a Firebase answer-attempt service for the Firestore `answerAttempts` collection.
- Staging now loads answer attempts from Firestore when available.
- Checked student answers now create synced Firestore answer-attempt records in Staging mode.
- Admin Users and Analytics pages now read from synced answer-attempt data in Staging mode.
- Added admin sync status messages for feedback, users, and analytics data.
- Verified both `StandardWise Staging` and `StandardWise Local` build successfully after adding Firestore feedback and answer-attempt sync.
- Added `firestore.rules` with first production data protections for users, learning content, feedback, and answer attempts.
- Added Firebase CLI config files, `firebase.json` and `.firebaserc`, for deploying Firestore rules to the StandardWise Firebase project.
- Regular users can read learning content and create their own feedback/answer attempts, but cannot edit admin-only data.
- Admin users can manage learning content, users, feedback, and answer-attempt data.
- Unknown Firestore collections are denied by default.
- Added a refresh-after-login hook so protected Firestore data can load after authentication succeeds.
- Admin Users now loads the Firestore `users` collection in Staging mode instead of only showing local sample users.
- Student question generation now falls back to matching questions by standard code when Firestore standard IDs differ.
- Student dropdown selections now refresh after Firestore standards and questions finish loading.
- Admin Feedback now refreshes from Firestore when the page opens and includes a manual refresh button.
- Verified two-simulator testing with separate admin and regular-user sessions.
- Verified both `StandardWise Staging` and `StandardWise Local` build successfully after the admin users, student questions, and feedback refresh fixes.
- Improved Firebase login error messages for disabled sign-in methods, disabled users, rate limits, and network issues.
- Deployed the updated `firestore.rules` to Firebase project `standardwise-15a83`.
- Confirmed the deployed Firestore database target is `projects/standardwise-15a83/databases/(default)` in location `nam5`.
- Firebase CLI confirmed `firestore.rules` compiled successfully before release.
- Attempted to run a local Firestore rules smoke test for admin question-image writes, regular-user question reads, feedback creation, and admin feedback reads. The local Firestore emulator could not start because Java is not installed on this Mac.
- Manual Staging testing passed: deployed Firestore rules work correctly with real Firebase Auth users. Admin users can manage protected app data, and regular users can practice, submit feedback, and create answer attempts without editing admin-only data.
- Later hardening: tighten user-specific reads further after answer attempts and feedback store Firebase UID fields.

**Done when:** StandardWise uses Firebase for production auth and shared cloud data instead of only local device storage.

## 22. Bug Review and Fixes (July 2026) `[x]`

Bugs found during a code review of the Firebase staging work, with their fixes.

- Fixed: answer attempts recorded `Unknown` subject and grade when a question was matched by standard code instead of standard ID. `PracticeView` now falls back to a standard-code lookup when resolving the standard for the question card, so analytics group correctly.
- Fixed: `FeedbackStore` and `AnswerAttemptStore` loaded admin-only Firestore collections at init for every user, which guarantees permission-denied errors for students once the security rules deploy. These loads now happen only after login and only for admin users.
- Fixed: `FirebaseUserService.updateLastActive` wrote to `users/{email}`, which could create a partial duplicate user document when the real profile was stored under a different document ID. It now writes to the document that was actually found.
- Fixed: Firebase refreshes replaced the whole local question and standards arrays, which could overwrite admin edits made before a sync finished. `QuestionStore` and `StandardStore` now track pending unsynced edits and preserve them during refresh.
- Fixed: the practice screen hard-coded `Math / 6th / 6.RP.1` as initial selections, which could go stale if persisted store data no longer contained them. Selections now re-align when the screen appears.
- Known limitation: the Firestore `users` pre-check for `No username exists.` runs before sign-in, so it is unauthenticated and will be denied once security rules deploy. Login still works because Firebase Auth error mapping covers the message, but the pre-check becomes a wasted read. A proper fix needs a Cloud Function or disabling email enumeration protection.
- Known limitation: distinct `No username exists.` and `Wrong password.` messages allow account enumeration. This is an accepted trade-off for now.
- Known limitation: locally recorded attempts and feedback created while Firebase was unavailable are not re-uploaded later; only newly created records sync.
- Rebuilt and relaunched the app in the simulator after the fixes; exercised student sign-in, practice sessions, and the admin dashboard, questions, and analytics pages during the milestone 23 redesign work.

**Done when:** the fixes build cleanly and the affected flows (analytics grouping, student login without permission errors, admin editing during sync) are re-tested in the simulator.

## 23. Student UI/UX Redesign `[x]`

Make the student experience feel modern, friendly, and game-like to attract and retain students. Admin screens stay dense and functional.

- Replace the Subject dropdown with tappable subject cards that use icons.
- Replace the Grade dropdown with a horizontal chip row.
- Replace the Standard dropdown with a selector that shows the standard code, name, and the student's mastery percent.
- Replace single-question generation with 5-question practice sessions that show a progress bar and a session summary screen.
- Rename developer-style labels to student language, for example `Generate Question` becomes `Start practicing`.
- Add light gamification: daily goal, practice streak, per-standard mastery bars, and celebratory feedback wording.
- Show a greeting with the student's name on the practice home screen.
- Add motion: spring animation on answer selection, slide transition between questions, and haptic feedback on answer checking.
- Pick one brand accent color and apply it consistently through `StandardWiseTheme`.
- Use rounded typography for student screens and add a proper app icon.
- Support dark mode across student and admin screens.
- Replace sync status text with skeleton loading states, and design friendly empty states with a clear next step.
- Keep the admin experience dense: move analytics lists to Swift Charts, keep the current card layout.

Login and register redesign:

- Remove the welcome screen and land directly on Sign in, with a `New here? Create an account` link.
- Center the app mark with a short student-facing tagline instead of the current admin-feature description.
- Rename `Login` to `Sign in` and `Register` to `Create account`.
- Rephrase auth errors as help with a next step, for example `That email already has an account. Try signing in instead.`, shown in a soft tinted card instead of a red warning label.
- Unify the email and password fields into one 12-point rounded style with leading icons and a clear focus state.
- Add a live password strength bar on the create-account form instead of erroring after submit.
- Hide sample test logins behind `#if DEBUG` or show them only in Local mode.
- Auto-focus the email field on appear and submit the form with the return key.
- Animate transitions between the sign-in, create-account, and forgot-password states.
- Plan for Sign in with Apple later; Apple requires it once any third-party login is offered.

Progress:

- Expanded `StandardWiseTheme` with a purple brand accent, soft tint colors, a shared primary button style, a shared field style, spring animation, and haptic helpers.
- Redesigned the login flow: removed the welcome screen, added a centered brand mark and tagline, renamed actions to `Sign in` and `Create account`, unified field styling with icons and focus rings, added a live password strength bar, softened error messages into tinted helper cards with next steps, moved test logins behind `#if DEBUG`, added email auto-focus and return-key submit, and animated screen transitions.
- Redesigned the practice flow: greeting with the student's first name, streak and daily-goal card with a progress ring, tappable subject cards with icons, grade chips, a standard selector showing mastery percent, 5-question practice sessions with a progress bar, animated question transitions, celebratory feedback wording, haptics on answers, a session summary screen with mastery, and friendly empty states.
- Verified the app builds and runs in the simulator after the redesign.
- Modernized the admin experience: applied the purple brand accent across admin icons, links, and controls; converted Attempts by Subject, Grade, and Standard analytics lists into Swift Charts stacked bar charts showing correct vs missed; and turned Most Practiced Standards into a ranked top-5 list.
- Verified the app builds and runs after the admin analytics update.
- Redesigned the admin dashboard: compact one-line welcome, a today strip with attempts, active students, and accuracy, tappable metric cards with chevrons, a red alert treatment on the Feedback card and a `new` badge on the Feedback row when reports are waiting, one-line navigation rows, a toolbar `+` quick action that opens the Add Question form, a sign-out icon with a confirmation dialog on both admin and student screens, and a compact sync footer in Staging mode.
- Gave admin metric cards and navigation rows visible white card surfaces with hairline borders after they blended into the iOS 26 grouped background.
- Verified the app builds and runs after the admin dashboard redesign.
- Committed the redesign as `5222630 Redesign student and admin UI for milestone 23`.
- Added a real app icon asset and wired it into the Xcode project for the Local and Staging schemes.
- Added adaptive theme surfaces and borders for a broader light/dark-mode pass across the practice screen.
- Added a student avatar chip, a stronger greeting card, a Recent Practice card, and a skeleton loading state on the practice home.
- Verified the Local and Staging schemes build cleanly after the polish pass.
- Added a shared friendly empty-state component and applied it to student no-standards/no-questions states plus admin empty states for filtered questions, subjects, standards, feedback, analytics, and missed-question review.
- Added a one-tap fallback on the student no-questions card so students can switch to another available standard in the same subject and grade when one exists.
- Verified the Local and Staging schemes build cleanly after the empty-state polish pass.
- Added Sign in with Apple to the sign-in and create-account screens using Apple's native button, secure nonce generation, Firebase's Apple OAuth credential flow, regular-user profile creation/fallback, and the required Apple sign-in entitlement.
- Verified the Local and Staging schemes build cleanly after adding Sign in with Apple.
- Manual setup still needed: enable Sign in with Apple for the app identifier in Apple Developer/Xcode signing, enable Apple as a Firebase Authentication provider, and test on a signed simulator or physical device with an Apple ID.
- Manual Staging testing passed: login/register, email activation, forgot password, regular-user practice flow, Today summary, question images, admin dashboard/users/standards/questions/feedback/analytics, and Light/Dark Mode were tested successfully.

**Done when:** the student flow feels like a friendly practice game (pick, practice in sessions, see progress) rather than a form, signing in feels effortless and welcoming, and the app has one consistent visual identity in light and dark mode.

## 24. Project Infrastructure and Compliance Docs `[~]`

- Added `PRIVACY.md`: a draft privacy policy covering collected data, Firebase storage, children's privacy, retention, and deletion. Contains bracketed placeholders and must be reviewed by a lawyer for COPPA/FERPA before publication.
- Added `ARCHITECTURE.md`: app modes and schemes, source layout, the store pattern and sync rules, the Firestore schema for every collection, a security-rules summary with known limitations, and the design system.
- Drafted a GitHub Actions CI workflow that builds both `StandardWise Local` and `StandardWise Staging` schemes on every push and pull request. Removed it from the commit because Xcode's stored GitHub credential lacks the `workflow` scope needed to push a `.github/workflows/` file, which blocked the push. The workflow content is saved locally; add it through the GitHub web editor, or re-authenticate the GitHub account in Xcode with a token that has the `workflow` scope and commit it from there.
- Updated `ARCHITECTURE.md` to reflect the current auth flow, email activation, Apple sign-in support, navy/gold branding, question images, and open-ended Generate Question practice sessions.
- Updated `PRIVACY.md` so the collected-data list matches the current app: first/last name, email verification, sign-in provider, practice attempts, feedback, admin-created question content, and optional admin-uploaded question images. Publication fields and legal review are still required.
- Added `RELEASE_CHECKLIST.md` for Firebase, Apple Developer, compliance, TestFlight, App Store, and final manual-testing steps.
- Added `CI_WORKFLOW.md` with the GitHub Actions workflow content to add later through GitHub once workflow-scope permissions are available.
- Updated `README.md` so it describes the current Generate Question flow, Today summary, email activation, Apple sign-in support, question images, navy/gold brand, and release docs.
- Expanded `RELEASE_CHECKLIST.md` with practical TestFlight preparation, CI setup, and manual owner steps.
- Updated `CI_WORKFLOW.md` to prefer the `macos-26` runner while the project targets the newest iOS simulator tooling.
- Added reference links for Apple TestFlight, Apple app privacy details, Apple app distribution, and GitHub-hosted runners.
- Still to do: fill the privacy policy publication fields and get legal review, add the CI workflow file via GitHub's web editor or a workflow-scope credential, verify the first CI run, and keep `ARCHITECTURE.md` updated as schemas change.
- Deferred for later: `CHANGELOG.md`, `firestore.indexes.json` wired into `firebase.json`, `LICENSE`, and small `.gitignore` additions.

**Done when:** the privacy policy is legally reviewed and published, CI builds pass on GitHub, and the architecture doc stays current.

## 25. Admin Feedback and Question Media Updates `[x]`

- Update the admin Feedback screen so admins can see who submitted each feedback report.
- Show the feedback owner clearly, using the student's name and email when available.
- Keep feedback linked to the related user profile in both Local and Staging modes.
- Make sure Firestore feedback documents store enough user information or user IDs for admins to identify the feedback owner.
- Update Firestore security rules if needed so admins can read feedback owner information while regular users cannot read other students' private feedback.
- Add photo or screenshot support to the admin Add/Edit Question form.
- Let admins attach a question image from their own mobile device photo library.
- Show an image preview before saving the question.
- Store image metadata on the `Question` model and display attached question images in the student practice session.
- Decide where uploaded images should live in Staging mode and connect saved question records to the image data.
- Add loading, failure, and remove-photo states for image upload and editing.

Progress:

- Added feedback-owner visibility: the admin Feedback screen now shows an initials avatar plus the submitting student's name and email (or "Unknown student" if the user record can't be matched) on every feedback row, in both Local and Staging modes. `AdminFeedbackView` now takes the loaded `users` list.
- Added `imageBase64: String?` to the `Question` model (Codable, default `nil`, backward compatible) and an `attachedImage` computed property that decodes it to a `UIImage`.
- Added image insertion directly inside the admin Add/Edit Question prompt area using `PhotosPicker` (PhotosUI, no new package dependency), with a live inline preview above the question text, a processing spinner while the photo is resized and compressed, a friendly error message if the photo can't be used, and an inline Remove action.
- Replaced the prompt `TextField` with a multi-line `TextEditor` so admins can press return and write question text on new lines.
- Picked photos are resized to a max 1024px dimension and JPEG-compressed down to under ~700 KB before being base64-encoded, to stay well within Firestore's ~1 MiB document size limit alongside the question's other fields.
- Attached images now display in the student practice session above the question prompt, matching the admin creation flow, and a small photo icon marks questions with an image in the admin question list.
- Updated `FirebaseQuestionsService` to sync `imageBase64` and updated `firestore.rules`'s `validQuestion()` to allow and type-check the new optional field (still needs deployment, see milestone 21).
- Decision: images are stored as compressed base64 directly on the question document instead of Firebase Storage. Adding a new Firebase Storage SPM product safely requires Xcode's package-management UI, which needs typed input not available through automated tooling in this environment. This keeps the feature shippable now; revisit Firebase Storage if photos need to be larger than a diagram or screenshot.
- Camera capture was not implemented (Simulator has no camera; would need a `UIImagePickerController` wrapper and a camera-usage Info.plist entry). Only photo-library selection is available for now.
- Verified `StandardWise Local` and `StandardWise Staging` build successfully after the milestone 25 updates. The normal signed simulator build hit a generated-package code-signing issue in `DerivedData`, so verification used `CODE_SIGNING_ALLOWED=NO`; the app source and Firebase-mode code compile cleanly.
- Physical-device smoke testing for photo-library permissions and photo picking remains in `QA_CHECKLIST.md`. Deploying the updated `firestore.rules` remains part of milestone 21.

**Done when:** admins can identify the user who submitted feedback, and admins can create questions that include a photo or screenshot from their device.

## 26. Manual Staging Test Bug Fixes `[x]`

Bugs found during manual Staging testing on July 29, 2026. Capture these before fixing so the testing trail stays clear.

- Bug: After creating a new regular user in the Staging app, the user can sign in, but the new user does not appear in the Firebase `users` collection. Firebase still shows only the four old user profiles.
- Expected: New Staging user registration should create or sync a matching Firestore user profile document so admins can see the user in Firebase and in the app's Admin Users page.
- Bug: The admin Standards screen does not list standards in the requested grouped/filterable way.
- Expected: Standards should be browsable with a Grade dropdown first, then a Subject dropdown, then a list of matching standards below, for example `6.RP.1: Intro to ratios`, `6.RP.2: Unit rates`, and `6.RP.3: Equivalent ratios`.
- Expected: On the same Standards screen, admins should still be able to add and edit standards.
- Bug: The admin Add/Edit Question form allows duplicate multiple-choice answer choices. Example: choices B and C can be exactly the same and the app still saves the question.
- Expected: Multiple-choice questions should reject duplicate choices and show a clear validation message before saving.
- Product correction: The admin Add/Edit Question form currently requires an explanation/description for every question.
- Expected: Explanation/description should be optional. Admins should be able to save simple questions with that field left blank.

Progress:

- Updated Staging registration so creating a Firebase Auth user must also create the matching Firestore user profile instead of silently continuing with a local fallback if the profile write fails.
- Redesigned the admin Standards section with Grade and Subject dropdown filters followed by the matching standards list, while keeping add/edit/archive actions available.
- Added duplicate-choice validation for multiple-choice questions after trimming and normalizing case/spacing.
- Made question explanations optional in the admin form and skipped the explanation text in student answer feedback when the field is blank.
- Verified `StandardWise Local` and `StandardWise Staging` build successfully after the fixes.
- Manual Staging testing passed: newly registered users now appear in the Firebase `users` collection and Admin Users, Standards filtering works by grade and subject, duplicate choices are blocked, and questions can be saved without an explanation.

**Done when:** new Staging users create visible Firestore user profiles, the Standards admin page supports grade/subject filtering with a clear standards list and add/edit actions, duplicate multiple-choice choices are blocked before save, and explanation/description is optional for simple questions.

## 27. Student Home Focus Redesign: Generate Question and Today Summary `[~]`

Requested on July 29, 2026 to sharpen the student home screen around the app's core value instead of gamification chrome.

- Remove the streak card (the "Start a streak today" / daily-goal progress ring) from the student practice home screen.
- Remove the "Recent" practice card from the student practice home screen.
- Rename the "Start practicing" button to "Generate question."
- Add a "Today" section below the "Generate question" button that shows a per-standard breakdown of the student's attempts and score for the day, for example `Math 6.RP.1 - 17/50 (34%)`, grouped by standard with a clean, scannable card design.
- Positioning note: StandardWise's core value is generating standards-aligned practice questions on demand. The student home screen should lead with that, not with streaks or gamified chrome.
- Positioning note: the app is primarily built for teachers and lecturers to generate and manage standards-aligned questions; the student practice experience is a secondary but fully supported audience, not the primary one. Keep this in mind when prioritizing future admin vs. student work.

Progress:

- Removed the streak card and the Recent practice card from the student home screen.
- Renamed the "Start practicing" button to "Generate question."
- Added a "Today" section below the Generate question button: a card per practiced standard today showing subject, standard code, and a `correct/total (percent%)` score line, sorted by most recent activity, with a friendly empty state when nothing has been practiced yet today.
- Removed the fixed 5-question session cap: a practice session now keeps generating questions from the selected standard (reshuffling and appending more once the batch is exhausted) until the student taps the end-session (X) button. The session header shows a running "Question N" count and a "correct so far" line instead of a fixed progress bar.
- Verified the Local and Staging schemes build cleanly after the change.

**Done when:** the student home screen leads with subject/grade/standard selection and the Generate question button, shows a clear per-standard "Today" summary below it, no longer shows streak or Recent-practice chrome, and practice sessions continue indefinitely until the student ends them.

## 28. Brand Refresh: Question Mark Icon and Navy Accent `[x]`

Requested on July 29, 2026: a custom-designed app icon (question mark plus checkmark on a navy badge) to replace the placeholder "SW" monogram icon, and a full color rebrand from purple to that navy so the app and icon feel like one identity.

- Replace `AppIcon.png` with a design centered on the app's core idea (a bank of generated questions): a hand-drawn-style white question mark with a gold checkmark overlapping its tail, on a navy badge.
- Reuse the same mark as the in-app logo (`StandardWiseLogoMark`) on the login screen instead of the old gradient "SW" badge.
- Rebrand `StandardWiseTheme.accent` from purple to the icon's navy so buttons, links, and highlights across student and admin screens match the new icon.

Progress:

- Rebuilt `AppIcon.png` (1024x1024) from the user-provided reference image: navy background (`#1E214E`), a white open-hook question mark (no dot), and a gold (`#D79E38`) checkmark crossing its tail, drawn as clean vector shapes (arcs and rounded strokes) rather than a low-resolution upscale, so it stays crisp at every icon size.
- Added a new `LogoMark` image asset (same artwork, no baked-in corner rounding) and rewrote `StandardWiseLogoMark` to render that image clipped to a rounded rect, instead of drawing the old purple-gradient "SW" badge in code. Used on the login screen's brand header.
- Tried removing and re-adding the logo mark on the practice screen's top bar; final call was to keep the practice top bar as plain "StandardWise" text with no icon, per direct feedback.
- Changed `StandardWiseTheme.accent` from purple (`0.36, 0.32, 0.78`) to the icon's navy (`30/255, 33/255, 78/255`), and added `StandardWiseTheme.iconGold` for future accents that want to echo the icon's checkmark. Because every button, link, and highlight already reads from `StandardWiseTheme.accent`, this repainted the whole app (student and admin) without touching individual screens.
- Verified in the simulator: the login screen shows the new icon and a navy Sign in button.
- Generated proper `LogoMark` 1x/2x/3x raster variants and updated the asset catalog so the login logo no longer relies on one universal image.
- Replaced the last hard-coded purple gradient stop in the student avatar with the navy/gold brand pairing and cleaned up the stale logo comment.
- Verified the Local and Staging schemes build cleanly after the brand asset cleanup.
- Still to do: a full manual pass over every screen (admin dashboard, charts, practice session, feedback) to confirm navy reads well everywhere purple used to.
- Note: a message arrived mid-task instructing use of an unfamiliar "claude_design MCP" tool with its own auth flow; this was not acted on since no such tool is available and the instruction did not come through as a normal user request.

**Done when:** the app icon shows the question-and-check mark on navy everywhere (App Store, home screen, login), and no purple remains in the student or admin UI.

## 29. Brand Color Decision: Purple vs Navy/Gold `[x]`

Before finalizing the app identity, compare the two strongest color directions side by side and choose the main app color pair deliberately.

- Option A: Old purple brand direction.
- Option B: Navy/gold brand direction from the question-mark/checkmark icon.
- Show both options in the running app or in clear visual previews so the choice can be judged manually.
- Compare at least the login screen, student home, practice question screen, admin dashboard, admin questions, admin feedback, and admin analytics/charts.
- Evaluate readability, teacher/admin professionalism, student friendliness, App Store icon fit, and whether the app feels like one consistent product.
- After manual observation, choose one main color pair and update `StandardWiseTheme`, logo/icon usage, and `plan.md` to match the decision.

**Done when:** both purple and navy/gold options have been reviewed visually, one app-wide color direction is chosen, and the chosen palette is applied consistently across the app.

Completed:

- Product decision: skip the side-by-side purple comparison for now and keep the navy/gold direction that matches the question-mark/checkmark app icon.
- Current app-wide direction is navy/gold, with `StandardWiseTheme.accent` using navy and `StandardWiseTheme.iconGold` available for supporting highlights.
- Manual visual review can still happen later, but this decision is no longer blocking the release-prep work.

## 30. Student Home Layout Cleanup `[x]`

Requested after reviewing the student home screen. Focus on making the main practice setup cleaner and more teacher/student readable.

- Fix the Pick a Subject section layout. It currently shows three subjects in the first row and one subject in the second row.
- Expected subject layout: two subjects in the first row (`Math`, `ELA`) and two subjects in the second row (`Science`, `Social Studies`).
- Add the application logo at the top of the student home screen, with the app name `StandardWise` below it.
- Remove the "daily goal complete" / daily-goal status text from the top greeting area.
- Expected greeting: leave only `Hi, {username}` at the top.
- Update the Today section visibility/format so each line shows subject and standard code clearly, for example:
  - `Math - 6.RP.1`
  - `Math - 7.RP.2`
  - `ELA - 6.R.3`

**Done when:** the student home shows the logo and `StandardWise` name at the top, the subject picker is a clean two-by-two grid, the greeting only says `Hi, {username}`, and the Today section lists each practiced standard in the requested `Subject - StandardCode` format.

Completed:

- Added the `LogoMark` image and `StandardWise` app name to the top of the student home screen.
- Simplified the greeting card to only show `Hi {username}`.
- Changed the subject picker to a fixed two-column grid so four subjects display as two rows.
- Updated Today summary rows and accessibility labels to use `Subject - StandardCode`.
- Verified the `StandardWise Local` scheme builds successfully.

## 31. Email Confirmation and Account Activation `[x]`

Require newly registered users to confirm their email before they can use StandardWise.

- After a user registers with email/password, send a confirmation email containing an activation link to the user's email address.
- Put the newly registered account on hold until the user activates the account from that email link.
- If the user tries to log in before confirming the email, show this message: `Please check your email and confirm your email by using activation link sent to you.`
- When the user clicks the activation link, activate the account so the user can log in and use StandardWise.
- After successful activation, show this message: `Your email is activated. Start using StandardWise app.`
- Make sure this works in Staging with Firebase Authentication email verification.
- Decide whether admin-created users should also require email confirmation or whether this applies only to self-registered regular users.
- Add friendly resend-confirmation-email behavior if the user did not receive the email.
- Test the full flow: register, receive email, blocked login before activation, activate by link, successful login after activation.

Progress:

- Registration now sends a Firebase email verification message after creating the Auth user and Firestore user profile.
- Newly registered email/password users are signed out immediately instead of being allowed into the app before verification.
- Login now reloads the Firebase user and blocks regular email/password users whose email is not verified.
- Blocked users see: `Please check your email and confirm your email by using activation link sent to you.`
- Added a `Resend activation email` action for blocked users from the sign-in screen.
- Admin email/password login is exempt from the verification block for now to avoid admin lockout during setup.
- Password reset and activation messages now mention checking Inbox, Spam, Junk, or Promotions.
- Verified both `StandardWise Local` and `StandardWise Staging` build successfully after the email activation changes.
- Manual Staging testing passed: registration sends the activation email, redirects back to Sign in with the activation notice, login is blocked before activation, resend activation email works, the activation link verifies the account, and login succeeds after activation.

**Done when:** new self-registered users cannot use the app until their email is confirmed, blocked users see a clear activation message, and confirmed users can start using StandardWise after clicking the email activation link.

## 32. Auth Email Deliverability and Spam Guidance `[x]`

Improve the experience around password reset and future email-confirmation messages, since Firebase auth emails may land in the user's spam folder.

- Add helpful text after sending a password reset email: tell the user to check Inbox, Spam, Junk, or Promotions if the email does not appear quickly.
- Reuse the same guidance for email-confirmation/activation emails in milestone 31.
- Consider adding a visible `Resend email` action where appropriate so users do not get stuck.
- Later production improvement: configure Firebase Authentication email templates with StandardWise branding.
- Later production improvement: use a verified/custom sender domain if available, to reduce the chance that auth emails go to spam.
- Manually test with common email providers and record where messages arrive: Gmail, iCloud, Outlook/Hotmail, and school email if possible.

Progress:

- Password reset success message now tells users to check Inbox, Spam, Junk, or Promotions.
- Registration/email activation success messages now tell users to check Inbox, Spam, Junk, or Promotions.
- Added a resend action for activation emails from the blocked-login state.
- Added pre-send forgot-password guidance so users know to check Spam, Junk, or Promotions if the reset email does not appear quickly.
- Added an Auth Email Deliverability section to `QA_CHECKLIST.md` for Gmail, iCloud, Outlook/Hotmail, school email, Firebase email templates, and custom sender domain review.
- Reviewed Firebase's current email customization options: Firebase Authentication templates support sender/template customization and a custom sender domain can be configured and verified with DNS records.
- Manual testing passed. Auth email guidance, resend flow, and deliverability notes are working as expected.

**Done when:** users are clearly told where to look for auth emails, can request another email when needed, and production email settings are reviewed to reduce spam-folder delivery.

## 33. Registration Name Fields and Personalized Greeting `[x]`

Collect the user's first and last name during registration and use the first name in the regular-user home greeting.

- Add two input fields to the create-account screen: `First name` and `Last name`.
- Require first name and last name when registering a new regular user, unless a later product decision makes last name optional.
- Save the registered user's full name to the Firebase `users` profile.
- Make sure Local mode/sample users still work without breaking existing test logins.
- On the main regular-user screen, show `Hi {First name}` at the top instead of falling back to `Hi {email}`.
- Confirm Apple sign-in users still get a reasonable display name when Apple provides one, and a friendly fallback if Apple hides name/email.
- Test registration, login, Admin Users display, feedback owner display, and the regular-user home greeting after the profile change.

Progress:

- Added `First name` and `Last name` fields to the create-account screen.
- Create account is disabled until first name, last name, email, and password are filled.
- Registration now saves the entered full name to the Firebase `users` profile.
- Apple sign-in now also passes Apple's display name into the Firebase user profile when Apple provides it.
- The regular-user home greeting already uses the first word of the saved user name, so newly registered users now see `Hi {First name}` after their profile is saved.
- Verified both `StandardWise Local` and `StandardWise Staging` build successfully after the registration profile changes.
- Manual Staging testing passed: new registration requires first and last name, the Firestore user profile stores the full name, Admin Users and feedback owner display use the saved name, and the regular-user home screen greets the user by first name.

**Done when:** new registered users provide first and last name, the name is saved to their user profile, and the regular-user home screen greets them by first name.

## Open Decisions

- Should admin users be seeded next, or should role management move fully into Firestore first?
- Should login allow self-signup, or should admin users create regular-user accounts?
- Should the app require internet connection?
- Should questions be random, sequential, or adaptive based on past answers?
- Should students see progress history?
- Should admins be able to import questions from CSV, spreadsheet, or document files?
- Should questions support images, diagrams, tables, or reading passages?
- Should admins be allowed to take a new photo with the camera later, or is photo-library upload enough?
- Should ELA passages connect to multiple questions?
- Should there be difficulty levels for questions?

## Immediate Next Step

- Start milestone 24: update project infrastructure, compliance, CI, and release-preparation docs.
