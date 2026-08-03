# StandardWise

StandardWise is a SwiftUI iOS app for standards-based student practice and teacher/admin question management. Students pick a subject, grade, and learning standard, then generate standards-aligned practice questions with instant feedback and a Today summary. Admin users manage questions, images, subjects, standards, users, and feedback, and review activity through charts-based analytics from a separate admin area.

## Current Status

The app is in active development. It runs in two modes: `Local` (sample logins, on-device data only) and `Staging` (Firebase Authentication plus shared Firestore data for users, standards, questions, feedback, and answer attempts). The student and admin interfaces were redesigned around the navy/gold StandardWise brand, and the practice content now covers Math, ELA, and Science across grades 6 through 9.

See `ARCHITECTURE.md` for how the app, stores, and Firestore schema fit together, and `plan.md` for the full build history and open items.

## Current Features

### Student experience

- Sign in / create account flow with first and last name fields, email activation, resend activation email, forgot password, Sign in with Apple support, friendly error messages, and a password strength check.
- Practice home screen with a greeting, tappable subject cards, grade chips, a standard picker showing mastery percent, and a Today summary grouped by practiced standard.
- Generated-question practice sessions that continue until the student ends the session, with animated transitions and haptics.
- Multiple-choice and typed-answer questions with instant correct/incorrect feedback and explanations.
- Question images display inline when admins attach diagrams, graphs, or screenshots.
- In-session feedback reporting for confusing or incorrect questions.

### Admin experience

- Dashboard with a today activity strip (attempts, active students, accuracy), tappable metric cards, and a feedback alert badge when new reports are waiting.
- Question management with add, edit, archive, search, filters, duplicate-choice validation, optional explanations, and inline photo insertion from the photo library.
- Standards management with grade/subject filters and add/edit/archive support for subjects and standards.
- Feedback review with status tracking (new, reviewed, resolved) and feedback-owner visibility.
- User list with accuracy summaries and attempt history.
- Analytics with bar charts for attempts by subject, grade, and standard, plus most-missed questions and most-practiced standards.

### Platform

- Role-based login for admin and regular users.
- Local mode tracking for users, answer attempts, feedback, and analytics.
- Staging mode sync for users, standards, questions, feedback, and answer attempts.
- Shared Xcode schemes for Local and Staging runs.
- Draft privacy, architecture, release, and CI workflow docs for TestFlight preparation.

## Login Accounts

### Local Scheme

Use the `StandardWise Local` scheme for local sample login.

- Admin: `admin@standardwise.app` / `admin123`
- Regular user: `student@standardwise.app` / `student123`

### Staging Scheme

Use the `StandardWise Staging` scheme for Firebase Authentication.

- Admin: `admin@standardwise.app` / Firebase password
- Regular user: any Firebase email/password account that should use the regular practice screen

Staging currently maps `admin@standardwise.app` to the admin role. Other Firebase users are treated as regular users until full user profiles and role management are moved into Firestore.

## Firebase and Data

Firebase is connected for staging authentication and shared Firestore data. The app includes:

- `FirebaseCore`
- `FirebaseAuth`
- `FirebaseFirestore`
- `GoogleService-Info.plist`

Current staging behavior:

- Login uses Firebase Authentication.
- Regular-user username existence is checked against the Firestore `users` collection when Firestore is available.
- Firebase Auth login is no longer blocked when Firestore is temporarily offline.
- After successful login, the app reads the user's Firestore profile for name, role, created date, and last active date.
- The admin email `admin@standardwise.app` still has a temporary bridge so the first admin login can create or update its Firestore profile.
- Staging reads and writes subjects, grades, and standards through Firestore when available.
- If the Firestore subject/standard collections are empty, staging seeds them from the current local sample data.
- Staging reads and writes questions through Firestore when available.
- If the Firestore question collection is empty, staging seeds it from the current local sample data.
- Staging reads and writes feedback through Firestore when available.
- Staging reads and writes answer attempts through Firestore when available.
- Analytics are calculated in the app from the synced answer-attempt data.

Planned Firestore collections:

- `users`
- `subjects`
- `grades`
- `standards`
- `questions`
- `answerAttempts`
- `feedback`

Current staging standards collections:

- `subjects`: `id`, `name`, `isActive`, `updatedAt`
- `grades`: `id`, `name`, `sortOrder`, `updatedAt`
- `standards`: `id`, `subjectID`, `gradeID`, `subjectName`, `gradeName`, `code`, `name`, `description`, `isActive`, `updatedAt`

Current staging questions collection:

- `questions`: `id`, `subjectID`, `gradeID`, `standardID`, `standardCode`, `prompt`, `type`, `choices`, `correctAnswer`, `acceptedAlternateAnswers`, `explanation`, `difficulty`, `isActive`, `createdByAdminID`, `createdAt`, `updatedAt`

Current staging feedback and attempt collections:

- `feedback`: `id`, `userID`, `questionID`, `message`, `status`, `createdAt`, `updatedAt`
- `answerAttempts`: `id`, `userID`, `questionID`, `subjectName`, `gradeName`, `standardCode`, `submittedAnswer`, `isCorrect`, `createdAt`

### Firestore Security Rules

The repo includes a first production-protection rules file at `firestore.rules`.

These rules are designed so:

- Signed-in users can read subjects, grades, standards, and questions.
- Admin users can manage subjects, grades, standards, questions, users, feedback, and answer attempts.
- Regular users can create their own feedback and answer attempts.
- Regular users cannot edit admin-only learning content or read all user analytics data.
- Unknown collections are denied by default.

The Firebase CLI config is included in `firebase.json` and points to project `standardwise-15a83` through `.firebaserc`.

Deploy rules with:

```bash
firebase deploy --only firestore:rules
```

You can also copy the contents of `firestore.rules` into Firebase Console > Firestore > Rules and publish from there.

For staging users, each Firebase Auth user should also have a matching Firestore user document in `users`. The document ID can be the lowercased email address, and the expected lookup field is `emailLowercase`, for example:

```json
{
  "id": "stable-user-uuid",
  "firebaseUID": "firebase-auth-uid",
  "name": "Student User",
  "email": "student@standardwise.app",
  "emailLowercase": "student@standardwise.app",
  "role": "regular",
  "createdAt": "Firestore timestamp",
  "lastActiveAt": "Firestore timestamp"
}
```

## Run the App

1. Open `StandardWise.xcodeproj` in Xcode.
2. Select one of the shared schemes:
   - `StandardWise Local`
   - `StandardWise Staging`
3. Select an iPhone simulator.
4. Build and run.

Use `StandardWise Local` when testing app behavior without Firebase. Use `StandardWise Staging` when testing Firebase login, email activation, Firestore sync, and production-like auth behavior.

## Project Structure

```text
StandardWise/
  Core/
    DesignSystem/
    Models/
    Services/
    Session/
  Features/
    Admin/
    Auth/
    Practice/
  RootView.swift
  StandardWiseApp.swift
```

## Project Docs

- `plan.md` — source of truth for planned features, build order, and progress notes.
- `ARCHITECTURE.md` — app modes, the store/sync pattern, Firestore schema, and security rules summary.
- `PRIVACY.md` — draft privacy policy; needs legal review before publication.
- `RELEASE_CHECKLIST.md` — Firebase, Apple Developer, TestFlight, and App Store preparation checklist.
- `CI_WORKFLOW.md` — GitHub Actions workflow content to add through GitHub once workflow-scope permissions are available.

## Development Plan

Next major work:

- Finish Milestone 24 infrastructure and compliance documentation.
- Finish Milestone 19 testing and quality checks.
- Prepare TestFlight setup after Firebase, Apple Developer, and privacy-policy decisions are ready.
