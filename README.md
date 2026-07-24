# StandardWise

StandardWise is a SwiftUI iOS app for standards-based student practice. Students select a subject, grade, and learning standard, generate a matching question, answer it, and receive immediate feedback. Admin users can manage questions, subjects, standards, users, feedback, and analytics from a separate admin area.

## Current Status

The app is in active development. The main local prototype is working, and Firebase has been added for staging authentication. Most learning content and admin-created data still run through local app stores until the Firestore migration is completed.

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
- Local tracking for users, answer attempts, feedback, and analytics.
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

Firebase is connected for staging authentication. The app includes:

- `FirebaseCore`
- `FirebaseAuth`
- `FirebaseFirestore`
- `GoogleService-Info.plist`

Current staging behavior:

- Login uses Firebase Authentication.
- Username existence checking is being moved toward a Firestore `users` collection.
- Subjects, standards, questions, feedback, answer attempts, and analytics still use local app data.

Planned Firestore collections:

- `users`
- `subjects`
- `standards`
- `questions`
- `answerAttempts`
- `feedback`

For future staging users, each Firebase Auth user should also have a matching Firestore user document. The expected user lookup field is `emailLowercase`, for example:

```json
{
  "email": "student@standardwise.app",
  "emailLowercase": "student@standardwise.app",
  "role": "regular",
  "name": "Student User"
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
- Move subjects, standards, questions, feedback, answer attempts, and analytics from local app state into Firestore.
