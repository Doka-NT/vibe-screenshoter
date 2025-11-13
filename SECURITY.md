# Security Policy

## Supported Versions

We release patches for security vulnerabilities for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Reporting a Vulnerability

We take the security of Vibe Screenshoter seriously. If you believe you have found a security vulnerability, please report it to us as described below.

### Please Do Not

- Open a public GitHub issue for security vulnerabilities
- Disclose the vulnerability publicly before it has been addressed

### Please Do

1. **Report privately**: Email security reports to the repository maintainers via GitHub's private vulnerability reporting feature, or create a security advisory.

2. **Provide details**: Include as much information as possible:
   - Type of vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)
   - Your contact information

3. **Allow time**: Give us reasonable time to address the issue before any public disclosure

### What to Expect

- **Acknowledgment**: We will acknowledge receipt of your report within 48 hours
- **Updates**: We will provide regular updates on our progress
- **Timeline**: We aim to release a fix within 30 days for critical vulnerabilities
- **Credit**: We will credit you in the security advisory (unless you prefer to remain anonymous)

## Security Considerations

### Permissions

Vibe Screenshoter requires the following macOS permissions:

1. **Screen Recording**: Required to capture screenshots
   - Granted via System Settings → Privacy & Security → Screen Recording
   - Used only when user initiates a screenshot
   - No background recording occurs

2. **Accessibility**: Required for global keyboard shortcuts
   - Granted via System Settings → Privacy & Security → Accessibility
   - Used only to register keyboard shortcuts
   - No keystroke logging or monitoring

### Data Privacy

- **No Network Access**: Application does not connect to the internet
- **Local Storage Only**: All data remains on your device
- **No Telemetry**: No usage data or analytics are collected
- **No Cloud Sync**: Files are saved locally to user-specified location

### Data Handling

1. **Clipboard**: Screenshots are copied to clipboard temporarily
2. **File System**: Screenshots saved to user-specified directory only
3. **Settings**: Stored in UserDefaults (local to device)
4. **No Encryption**: Screenshots are stored unencrypted (same as system default)

### Known Security Limitations

1. **No Sandboxing**: Application is not sandboxed (required for global shortcuts)
2. **No Code Signing**: Build requires manual signing for distribution
3. **No Notarization**: Not currently notarized by Apple
4. **Local Storage**: Saved screenshots are not encrypted at rest

### Best Practices for Users

1. **Verify Source**: Only download from official repository
2. **Check Permissions**: Review requested permissions before granting
3. **Secure Screenshots**: Be mindful of sensitive content in screenshots
4. **Update Regularly**: Keep the application updated to latest version
5. **Review Save Location**: Ensure screenshots are saved to secure location

### Development Security

For developers contributing to the project:

1. **Dependencies**: We use minimal dependencies to reduce attack surface
2. **Code Review**: All changes require review before merging
3. **Input Validation**: Validate all user inputs
4. **Memory Safety**: Use Swift's memory safety features
5. **No Secrets**: Never commit credentials or secrets

### Vulnerability Disclosure Timeline

1. **T+0**: Vulnerability reported privately
2. **T+48h**: Acknowledgment sent to reporter
3. **T+7d**: Initial assessment completed
4. **T+30d**: Fix developed and tested (for critical issues)
5. **T+35d**: Security advisory published and fix released
6. **T+90d**: Full details disclosed (if appropriate)

### Security Updates

Security updates will be released as patch versions (e.g., 1.0.1) and will be clearly marked in:
- GitHub Releases
- CHANGELOG.md
- Security Advisories

### Security Features

The application implements several security features:

1. **No External Dependencies**: Reduces supply chain risks
2. **Native APIs**: Uses Apple's secure system APIs
3. **User Control**: All actions require explicit user initiation
4. **Transparent Operation**: All operations visible to user
5. **Minimal Permissions**: Requests only necessary permissions

### Threat Model

**In Scope:**
- Unauthorized access to screenshot data
- Privilege escalation attacks
- Code injection vulnerabilities
- Information disclosure
- Malicious file writing

**Out of Scope:**
- Physical access to device
- Compromised macOS system
- User-initiated malicious actions
- Social engineering attacks

### Contact

For security concerns, please use GitHub's security advisory feature or contact the maintainers directly through GitHub.

### Attribution

We appreciate the security research community and will acknowledge researchers who report vulnerabilities responsibly in our security advisories (unless they prefer to remain anonymous).

---

**Last Updated**: 2024-11-13
**Policy Version**: 1.0
