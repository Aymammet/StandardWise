# GitHub Actions CI Workflow

The repo previously could not push a file under `.github/workflows/` because
the active GitHub credential did not have the `workflow` scope. Until that is
fixed, keep the workflow here and add it through GitHub's web editor, or
reauthenticate GitHub from Xcode/Git with a token that includes the `workflow`
scope.

When ready, create this file in GitHub:

`.github/workflows/ios-build.yml`

```yaml
name: iOS Build

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    name: Build StandardWise
    runs-on: macos-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode.app

      - name: Build Local
        run: |
          xcodebuild \
            -project StandardWise.xcodeproj \
            -scheme "StandardWise Local" \
            -destination 'generic/platform=iOS Simulator' \
            CODE_SIGNING_ALLOWED=NO \
            build

      - name: Build Staging
        run: |
          xcodebuild \
            -project StandardWise.xcodeproj \
            -scheme "StandardWise Staging" \
            -destination 'generic/platform=iOS Simulator' \
            CODE_SIGNING_ALLOWED=NO \
            build
```

After adding it:

- Confirm the first run starts on GitHub.
- If the hosted Xcode version does not support the current iOS target, pin a
  compatible macOS runner image or adjust the project deployment settings.
- Keep signing disabled for CI simulator builds unless a signed archive job is
  added later.
