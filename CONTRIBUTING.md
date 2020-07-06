# Contributing to Listé

## Table of Contents ##
- [Introduction](#introduction)
- [Getting Started](#getting-started)
- [Bugs, Crashes and Errors](#bugs-crashes-and-errors)
	- [Before Submitting A Report](#before-submitting-a-report)
	- [Submitting A Report](#submitting-a-report)
	- [After Submitting A Report](#after-submitting-a-report)
- [Enhancements and Additions](#enhancements-and-additions)
	- [Before Submitting A Feature](#before-submitting-a-feature)
	- [Submitting A Feature](#submitting-a-feature)
	- [After Submitting A Feature](#after-submitting-a-feature)
- [Your First Code](#your-first-code)
- [Pull Requests](#pull-requests)
- [Swift Styleguide](#swift-styleguide)
- [Additional Notes](#additional-notes)

## Introduction
Thank you for your interest in contributing to the project! We'd love to have you on board and suggest changes. Whether you're here to make a minor change like a misspelling in the documentation to significant changes like implementing new features, we'd love to have you here.

While we don't set hard rules for contributing to the project, we strongly advise that you follow this Contributing Guide; at least, review it first before going off to make your first contribution.

## Getting Started
Feel like contributing to the project? Please select from either of the following options. If there's a missing selection, you can also make a suggestion!

Bugs, crashes and errors
Enhancements and additions

### Bugs, Crashes and Errors
Noticed a bug, crash, or error in our project, and feel like you're up to fixing it? First, check out the before submitting a report section below.

#### Before Submitting A Report
Before submitting a report,
- **Check that no similar issue exists.** You can do this by performing a cursory search to see if an issue identical to the problem you're facing exists. If such issues exist, comment on it instead of creating a new one.

#### Submitting A Report
GitHub Issues manage our bug, crashes and error reports. If you have noticed one existing, please create an issue with the **Error Report** template.

Following the template:
- **Give a concise and straightforward title.** Instead of "```Some error```", consider describing the problem in short terms, like "```Project failed to build```".
- **Describe the error in full detail.** If something you interacted with caused the mistake, like clicking on a button, describe where trigger (e.g., the button) is and where it is located. If possible, also include the error message that came together with the problem.
- **Explain what you expected to see.** Your explanation allows us to understand how this problem affects the app in general.
You may provide more context with the following, although not wholly needed:
- **Describe the device used.** Is your device physical or simulated? Physical devices refer to running the app on a physical iPhone; simulated devices refer to running the app on the Simulator.
- **Is the problem reliably reproduced?** If the problem occurs only sometimes, let us know that in your description section.

#### After Submitting A Report
After submitting a report, we expect that you'll continue to contribute to the issue until it closes or until someone else takes over. If you do not have the time to stay on your contribution, add a comment stating that you would like other maintainers or contributors to handle the problem.

### Enhancements and Additions
Noticed something missing, or something you'd like to add, to the project? We'd love your contribution, no matter how small it is. First, check out the before submitting a feature section below.

#### Before Submitting A Feature
- **Check that no similar suggestions exist.** You can do this by performing a cursory search to see if an issue identical to the problem you're facing exists. If such issues exist, comment on it instead of creating a new one.
- **Weigh the importance of the suggestion.** We generally do not have many issues (considering this repository is small-scaled 😭), but in the *unlikely* event that many issues exist, weigh out your contribution and see if it can merge with another issue.

#### Submitting A Feature
GitHub issues manage our enhancement and addition requests. If you have noticed one existing, please create an issue with the **Enhancement Request** template.

Following the template:
- **Give a concise and straightforward title.** Instead of "```New feature```", consider describing the problem in short terms, like "```Add more lists```".
- **Describe how this enhancement can be useful.** You can choose to describe this from an end-user point of view.
- **Explain why the current features are not satisfactory.** Explain why all the features in the current version of the app do not meet your expectations or perform as well as your enhancement.
You may provide more context with the following, although not wholly needed:
- **Is the enhancement required?** If you'd like to, you can do some research. Although that's probably not necessary, we'll accept almost all contributions.

#### After Submitting A Feature
After submitting a feature, we expect that you'll continue to contribute to the issue until it closes or until someone else takes over. If you do not have the time to stay on your contribution, add a comment stating that you would like other maintainers or contributors to handle the problem.

## Your First Code
While we can't guarantee there'll be ```for-beginners``` issues, Listé serves to be a great introduction for newcomers to app development and programming. Therefore:

**If you're a contributor**, make sure to document variables and functions with Swift's documentation comments (```///```) and comments (```//```) for everything else. Here's a piece of code that you can take as an example:

```swift
/// Explain what this function does.
///
/// - Parameters:
/// 	- foo: A description of `foo`.
///
/// - Returns: A description of what this function returns.
func someFunction() {
	/// A description of the variable.
	var someVariable = "Hello, world!"

	// Prints the value of someVariable.
	print(someVariable)
}
```

**If you're a newcomer**, take time to review through the code. If you'd like to ask any questions, go ahead and create an issue! We're all here to help.

## Pull Requests
While we probably won't have a template for pull requests, keep the main points of the above as a guideline. Describe the issue, use Markdown to separate your sections, and make your idea worth reading!

## Styleguides
### Git Commit Messages
Use the present tense.
> 🔴 ```Added feature```

> 🟢 ```Add feature```

Use the imperative mood.
> 🔴 ```Moves cursor```

> 🟢 ```Move cursor```

Limit lines to 72 characters or less.
The devs here use [WordCounter](wordcounter.net) to check our line lengths.

### Swift Styleguide
We aren't using any methods of linting at the moment. However, we're having our eyes on [SwiftLint](https://github.com/realm/swiftlint).


## Additional Notes
We want to thank you for your hard effort reading this guide, and we hoped that you're not as tired as we are while writing this. Have fun contributing to the project!

With love,
Apprendré.