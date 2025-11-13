# Contributing to Vibe Screenshoter

Thank you for your interest in contributing to Vibe Screenshoter! This document provides guidelines and instructions for contributing.

## Getting Started

### Prerequisites

- macOS 13.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later
- Git

### Setting Up Development Environment

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/vibe-screenshoter.git
   cd vibe-screenshoter
   ```
3. Build the project:
   ```bash
   swift build
   ```
4. Run tests:
   ```bash
   swift test
   ```

## Development Workflow

### Branch Naming

- Feature: `feature/description-of-feature`
- Bug fix: `fix/description-of-bug`
- Documentation: `docs/description-of-change`
- Refactoring: `refactor/description-of-change`

### Making Changes

1. Create a new branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes following the coding standards (see below)

3. Test your changes:
   ```bash
   swift build
   swift test
   ```

4. Commit your changes:
   ```bash
   git add .
   git commit -m "Brief description of changes"
   ```

5. Push to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

6. Create a Pull Request

## Coding Standards

### Swift Style Guide

We follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/).

Key points:

1. **Naming**:
   - Use descriptive names
   - Use camelCase for variables and functions
   - Use PascalCase for types
   ```swift
   // Good
   let userName = "John"
   func calculateTotalPrice() -> Double { }
   class ScreenshotManager { }
   
   // Bad
   let usrnm = "John"
   func calc_total() -> Double { }
   class screenshot_manager { }
   ```

2. **Indentation**:
   - Use 4 spaces (no tabs)
   - Use consistent indentation

3. **Line Length**:
   - Prefer lines under 120 characters
   - Break long lines logically

4. **Comments**:
   - Use comments to explain "why", not "what"
   - Keep comments up-to-date with code changes
   ```swift
   // Good
   // Using weak self to prevent retain cycle in closure
   handler = { [weak self] in
       self?.process()
   }
   
   // Bad
   // Set handler
   handler = { [weak self] in
       self?.process()
   }
   ```

5. **Access Control**:
   - Use `private` for implementation details
   - Use `internal` (default) for module-level access
   - Use `public` only when necessary
   ```swift
   class ScreenshotManager {
       private var captureWindow: CaptureWindow?
       private var settingsManager: SettingsManager
       
       public func startCapture() { }
   }
   ```

### Architecture Patterns

1. **Separation of Concerns**: Each class should have a single, well-defined responsibility

2. **Delegation**: Use closures or delegates for callbacks

3. **Memory Management**: Always use `[weak self]` in closures that reference self

4. **Error Handling**: Use Swift's error handling mechanisms

### File Organization

Place files in appropriate directories:
- Core logic: `Sources/`
- Tests: `Tests/`
- Documentation: Root directory with `.md` extension

### Git Commit Messages

Follow these guidelines:

1. Use present tense ("Add feature" not "Added feature")
2. Use imperative mood ("Move cursor to..." not "Moves cursor to...")
3. Limit first line to 72 characters
4. Reference issues and pull requests when relevant

Examples:
```
Add text annotation tool to editor

Implement new text tool that allows users to add text
annotations to screenshots with customizable font size
and color.

Fixes #123
```

## Testing

### Writing Tests

1. Create tests in the `Tests/` directory
2. Name test files with `Tests` suffix
3. Use descriptive test names:
   ```swift
   func testSettingsManagerSavesPathCorrectly() {
       // Test implementation
   }
   ```

### Running Tests

```bash
# Run all tests
swift test

# Run with verbose output
swift test --verbose
```

### Test Coverage

Aim for reasonable test coverage, especially for:
- Core business logic
- Data persistence
- Format conversion
- Settings management

## Documentation

### Code Documentation

Use Swift's documentation comments:

```swift
/// Captures a screenshot of the selected screen area.
///
/// - Parameters:
///   - rect: The rectangular area to capture
///   - completion: Callback with the captured image
/// - Returns: True if capture was successful
func captureScreenshot(rect: NSRect, completion: @escaping (NSImage?) -> Void) -> Bool {
    // Implementation
}
```

### README Updates

Update README.md when:
- Adding new features
- Changing build instructions
- Updating requirements

## Pull Request Process

1. **Create PR**:
   - Use a descriptive title
   - Fill out the PR template
   - Link related issues

2. **PR Description**:
   - Describe what changed and why
   - Include screenshots for UI changes
   - List any breaking changes

3. **Code Review**:
   - Address review comments
   - Keep discussions professional and constructive
   - Update PR based on feedback

4. **Merge**:
   - PRs require approval before merging
   - Squash commits if appropriate
   - Delete branch after merge

## Issue Reporting

### Bug Reports

Include:
- macOS version
- Steps to reproduce
- Expected vs actual behavior
- Screenshots/videos if applicable
- Relevant log output

### Feature Requests

Include:
- Use case description
- Proposed solution
- Alternative solutions considered
- Mockups or examples if applicable

## Types of Contributions

### Bug Fixes

- Check existing issues first
- Create an issue if one doesn't exist
- Reference the issue in your PR

### New Features

- Discuss feature in an issue first
- Ensure it aligns with project goals
- Update documentation
- Add tests

### Documentation

- Fix typos and clarify content
- Add examples
- Improve organization
- Update for new features

### Performance

- Profile before and after changes
- Include benchmark results
- Explain the optimization

## Community Guidelines

### Code of Conduct

- Be respectful and inclusive
- Welcome newcomers
- Focus on constructive feedback
- Assume good intentions

### Communication

- Use GitHub issues for bugs and features
- Be patient waiting for responses
- Search before creating new issues
- Stay on topic in discussions

## Recognition

Contributors will be acknowledged in:
- README.md (Contributors section)
- Release notes
- Git commit history

## Questions?

If you have questions:
1. Check existing documentation
2. Search closed issues
3. Create a new issue with the "question" label

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

Thank you for contributing to Vibe Screenshoter! 🎉
