# Contributing to 2FAS for iOS

Thank you for considering contributing to the 2FAS open source project. Your support is greatly appreciated and will help us make this project even better. There are many ways you can help, from reporting bugs and improving the documentation to contributing code changes.

## Reporting Bugs

Before you submit a bug report, please search the [existing issues](https://github.com/twofas/2fas-ios/issues) to see if the problem has already been reported. If it has, please add any additional information you have to the existing issue.

If you can't find an existing issue for your problem, please open a new issue and include the following information:

- A clear and descriptive title for the issue
- A description of the problem, including any error messages or logs
- Steps to reproduce the problem
- Any relevant details about your setup, such as the version of iOS you are using

## Contributing Code

We welcome meaningful code contributions to the 2FAS for iOS project. If you are interested in contributing, please follow these steps:

1. Fork this repository to your own GitHub account
2. Clone the repository to your local machine
3. Copy example Keys.swift from TwoFAS/opensource folder to TwoFAS/Protection (override the encrypted file)
4. Copy IconDescriptionDatabaseImpl+Database.swift and ServiceDefinitionDatabaseImpl+Database.swift from TwoFAS/opensource to TwoFAS/Content/Sources (override files). Remove all files with "*DatabaseImpl+Database[number].swift" in it.
5. Copy Assets.car from TwoFAS/opensource to TwoFAS/Content/Assets (override the file)
6. Create a new branch for your changes (e.g. `feature/new-login-screen`)
7. Make your changes
8. Check them using swiftlint (there should be no warnings from swiftlint or compiler)
9. Check if Unit Tests are passing
10. Commit them to your branch
11. Push your branch to your fork on GitHub
12. Open a pull request from your branch to the `develop` branch of this repository. Remember to resolve any merge conflicts

Please make sure your pull request includes the following:

- A clear and descriptive title
- A description of the changes you have made
- Any relevant issue numbers (e.g. "Fixes #123")
- A list of any dependencies your changes require
- Tests for any new or changed code

We will review your pull request and provide feedback as soon as possible. Thank you for your contribution!

By sharing ideas and code with the 2FAS community, either through GitHub or Discord, you agree that these contributions become the property of the 2FAS community and may be implemented into the 2FAS open source code.
