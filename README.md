# StandardWise

StandardWise is a SwiftUI iOS app for standards-based student practice. Students select a subject, grade, and learning standard, generate a matching question, answer it, and receive immediate feedback. Admin users can manage questions, subjects, standards, users, feedback, and analytics from a separate admin area.

## Current Status

The app is in active development. The local prototype is working, and Firebase has been added for staging authentication plus shared Firestore data for users, standards, questions, feedback, and answer attempts.

## Current Features

- Role-based login for admin and regular users.
- Student practice screen with Subject, Grade, and Standard dropdowns.
- Question generation from the current local question bank.
- Multiple-choice and typed-answer questions.
- Answer checking with correct and incorrect feedback.
- Question explanations after answer checking.
- Student feedback submission for questions.
- Admin dashboard with sections for questions, standards, users, feedback, and analytics.
- Admin question management with add, edit, archive, search, and filters.
- Admin standards management with add/edit/archive support for subjects and standards.
- Local mode tracking for users, answer attempts, feedback, and analytics.
- Staging mode sync for users, standards, questions, feedback, and answer attempts.
- Shared Xcode schemes for Local and Staging runs.

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

Use `StandardWise Local` when testing app behavior without Firebase. Use `StandardWise Staging` when testing Firebase login.

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

## Development Plan

The source of truth for planned features and build order is `plan.md`.

Next major work after README:

- Testing and quality checks.
- Continue Firebase production data migration.
- Test and deploy Firebase security rules.
