import SwiftUI

// MARK: - Typography System

/// Spotted app typography system following iOS Human Interface Guidelines
/// Supports Dynamic Type for accessibility
enum Typography {

    // MARK: - Display Styles (Large Titles)

    /// Display Large - 34pt, Bold
    /// Use for: Main screen titles, hero text
    static let displayLarge = Font.system(size: 34, weight: .bold, design: .rounded)

    /// Display Medium - 28pt, Bold
    /// Use for: Section titles, card headers
    static let displayMedium = Font.system(size: 28, weight: .bold, design: .rounded)

    /// Display Small - 24pt, Bold
    /// Use for: Subsection titles
    static let displaySmall = Font.system(size: 24, weight: .bold, design: .rounded)

    // MARK: - Heading Styles

    /// Heading 1 - 22pt, Bold
    /// Use for: Major section headings
    static let heading1 = Font.system(size: 22, weight: .bold)

    /// Heading 2 - 20pt, Semibold
    /// Use for: Card titles, list section headers
    static let heading2 = Font.system(size: 20, weight: .semibold)

    /// Heading 3 - 18pt, Semibold
    /// Use for: Subheadings, prominent labels
    static let heading3 = Font.system(size: 18, weight: .semibold)

    /// Heading 4 - 16pt, Semibold
    /// Use for: Small headings, emphasized text
    static let heading4 = Font.system(size: 16, weight: .semibold)

    // MARK: - Body Styles

    /// Body Large - 17pt, Regular
    /// Use for: Primary body text, main content
    static let bodyLarge = Font.system(size: 17, weight: .regular)

    /// Body Large Emphasized - 17pt, Semibold
    /// Use for: Emphasized body text
    static let bodyLargeEmphasized = Font.system(size: 17, weight: .semibold)

    /// Body Medium - 15pt, Regular
    /// Use for: Secondary body text, descriptions
    static let bodyMedium = Font.system(size: 15, weight: .regular)

    /// Body Medium Emphasized - 15pt, Semibold
    /// Use for: Emphasized secondary text
    static let bodyMediumEmphasized = Font.system(size: 15, weight: .semibold)

    /// Body Small - 13pt, Regular
    /// Use for: Tertiary content, fine print
    static let bodySmall = Font.system(size: 13, weight: .regular)

    // MARK: - Label Styles

    /// Label Large - 16pt, Semibold
    /// Use for: Button text, prominent labels
    static let labelLarge = Font.system(size: 16, weight: .semibold)

    /// Label Medium - 14pt, Semibold
    /// Use for: Form labels, list item labels
    static let labelMedium = Font.system(size: 14, weight: .semibold)

    /// Label Small - 12pt, Semibold
    /// Use for: Small labels, tags, badges
    static let labelSmall = Font.system(size: 12, weight: .semibold)

    /// Label Tiny - 10pt, Semibold
    /// Use for: Extremely small labels, timestamps
    static let labelTiny = Font.system(size: 10, weight: .semibold)

    // MARK: - Caption Styles

    /// Caption Large - 14pt, Regular
    /// Use for: Image captions, supplementary text
    static let captionLarge = Font.system(size: 14, weight: .regular)

    /// Caption Medium - 12pt, Regular
    /// Use for: Timestamps, metadata
    static let captionMedium = Font.system(size: 12, weight: .regular)

    /// Caption Small - 11pt, Regular
    /// Use for: Very small descriptive text
    static let captionSmall = Font.system(size: 11, weight: .regular)

    // MARK: - Specialized Styles

    /// Button Large - 18pt, Bold
    /// Use for: Primary CTA buttons
    static let buttonLarge = Font.system(size: 18, weight: .bold)

    /// Button Medium - 16pt, Semibold
    /// Use for: Secondary buttons
    static let buttonMedium = Font.system(size: 16, weight: .semibold)

    /// Button Small - 14pt, Semibold
    /// Use for: Tertiary buttons, text buttons
    static let buttonSmall = Font.system(size: 14, weight: .semibold)

    /// Tab Bar - 10pt, Medium
    /// Use for: Tab bar labels
    static let tabBar = Font.system(size: 10, weight: .medium)

    /// Navigation Bar Title - 17pt, Semibold
    /// Use for: Navigation bar titles
    static let navigationTitle = Font.system(size: 17, weight: .semibold)
}

// MARK: - Typography View Modifiers

extension View {

    // MARK: - Display

    func displayLarge() -> some View {
        self.font(Typography.displayLarge)
    }

    func displayMedium() -> some View {
        self.font(Typography.displayMedium)
    }

    func displaySmall() -> some View {
        self.font(Typography.displaySmall)
    }

    // MARK: - Heading

    func heading1() -> some View {
        self.font(Typography.heading1)
    }

    func heading2() -> some View {
        self.font(Typography.heading2)
    }

    func heading3() -> some View {
        self.font(Typography.heading3)
    }

    func heading4() -> some View {
        self.font(Typography.heading4)
    }

    // MARK: - Body

    func bodyLarge() -> some View {
        self.font(Typography.bodyLarge)
    }

    func bodyLargeEmphasized() -> some View {
        self.font(Typography.bodyLargeEmphasized)
    }

    func bodyMedium() -> some View {
        self.font(Typography.bodyMedium)
    }

    func bodyMediumEmphasized() -> some View {
        self.font(Typography.bodyMediumEmphasized)
    }

    func bodySmall() -> some View {
        self.font(Typography.bodySmall)
    }

    // MARK: - Label

    func labelLarge() -> some View {
        self.font(Typography.labelLarge)
    }

    func labelMedium() -> some View {
        self.font(Typography.labelMedium)
    }

    func labelSmall() -> some View {
        self.font(Typography.labelSmall)
    }

    func labelTiny() -> some View {
        self.font(Typography.labelTiny)
    }

    // MARK: - Caption

    func captionLarge() -> some View {
        self.font(Typography.captionLarge)
    }

    func captionMedium() -> some View {
        self.font(Typography.captionMedium)
    }

    func captionSmall() -> some View {
        self.font(Typography.captionSmall)
    }
}

// MARK: - Usage Examples
/*

 // Display
 Text("Welcome to Spotted")
     .displayLarge()

 // Headings
 Text("Discover People")
     .heading1()

 Text("Near You")
     .heading2()

 // Body
 Text("This is the main content text that users will read.")
     .bodyLarge()

 Text("This is secondary descriptive text.")
     .bodyMedium()

 // Labels
 Text("BUTTON TEXT")
     .labelLarge()

 Text("Form Field Label")
     .labelMedium()

 // Captions
 Text("Posted 2 hours ago")
     .captionMedium()

 */
