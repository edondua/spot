import SwiftUI

// MARK: - Badge Styles

/// Badge style variants
enum BadgeStyle {
    case filled
    case outlined
    case subtle
}

/// Badge size variants
enum BadgeSize {
    case small
    case medium
    case large

    var fontSize: CGFloat {
        switch self {
        case .small: return 10
        case .medium: return 12
        case .large: return 14
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .small: return 8
        case .medium: return 12
        case .large: return 16
        }
    }

    var verticalPadding: CGFloat {
        switch self {
        case .small: return 4
        case .medium: return 6
        case .large: return 8
        }
    }
}

/// Badge color scheme
enum BadgeColor {
    case primary
    case secondary
    case success
    case error
    case warning
    case info
    case neutral

    var color: Color {
        switch self {
        case .primary: return DesignTokens.Colors.primary
        case .secondary: return DesignTokens.Colors.secondary
        case .success: return DesignTokens.Colors.success
        case .error: return DesignTokens.Colors.error
        case .warning: return DesignTokens.Colors.warning
        case .info: return DesignTokens.Colors.info
        case .neutral: return DesignTokens.Colors.textSecondary
        }
    }
}

// MARK: - Badge Component

/// Spotted Badge - Generic badge component
struct SpottedBadge: View {
    let text: String
    let color: BadgeColor
    let style: BadgeStyle
    let size: BadgeSize
    var icon: String? = nil

    init(
        _ text: String,
        color: BadgeColor = .primary,
        style: BadgeStyle = .filled,
        size: BadgeSize = .medium,
        icon: String? = nil
    ) {
        self.text = text
        self.color = color
        self.style = style
        self.size = size
        self.icon = icon
    }

    var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: size.fontSize - 2))
            }

            Text(text.uppercased())
                .font(.system(size: size.fontSize, weight: .semibold))
        }
        .padding(.horizontal, size.horizontalPadding)
        .padding(.vertical, size.verticalPadding)
        .background(backgroundColor)
        .foregroundColor(foregroundColor)
        .cornerRadius(DesignTokens.CornerRadius.xl)
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                .stroke(borderColor, lineWidth: style == .outlined ? 1.5 : 0)
        )
    }

    private var backgroundColor: Color {
        switch style {
        case .filled:
            return color.color
        case .outlined:
            return Color.clear
        case .subtle:
            return color.color.opacity(0.15)
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .filled:
            return .white
        case .outlined, .subtle:
            return color.color
        }
    }

    private var borderColor: Color {
        style == .outlined ? color.color : Color.clear
    }
}

// MARK: - Specialized Badges

/// Status Badge - For online/offline/away states
struct StatusBadge: View {
    enum Status {
        case online
        case offline
        case away
        case busy

        var color: Color {
            switch self {
            case .online: return DesignTokens.Colors.success
            case .offline: return DesignTokens.Colors.textTertiary
            case .away: return DesignTokens.Colors.warning
            case .busy: return DesignTokens.Colors.error
            }
        }

        var text: String {
            switch self {
            case .online: return "Online"
            case .offline: return "Offline"
            case .away: return "Away"
            case .busy: return "Busy"
            }
        }

        var icon: String {
            switch self {
            case .online: return "circle.fill"
            case .offline: return "circle"
            case .away: return "moon.fill"
            case .busy: return "minus.circle.fill"
            }
        }
    }

    let status: Status
    let showText: Bool

    init(_ status: Status, showText: Bool = true) {
        self.status = status
        self.showText = showText
    }

    var body: some View {
        if showText {
            SpottedBadge(
                status.text,
                color: badgeColor(from: status.color),
                style: .subtle,
                size: .small,
                icon: status.icon
            )
        } else {
            Circle()
                .fill(status.color)
                .frame(width: 8, height: 8)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 1.5)
                )
        }
    }

    private func badgeColor(from color: Color) -> BadgeColor {
        if color == DesignTokens.Colors.success { return .success }
        if color == DesignTokens.Colors.error { return .error }
        if color == DesignTokens.Colors.warning { return .warning }
        return .neutral
    }
}

/// Count Badge - For notification counts
struct CountBadge: View {
    let count: Int
    let max: Int

    init(count: Int, max: Int = 99) {
        self.count = count
        self.max = max
    }

    var body: some View {
        Text(displayText)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, count > 9 ? 6 : 0)
            .frame(minWidth: 18, minHeight: 18)
            .background(DesignTokens.Colors.error)
            .clipShape(Circle())
    }

    private var displayText: String {
        if count > max {
            return "\(max)+"
        }
        return "\(count)"
    }
}

/// Tag - Interactive tag/chip component
struct SpottedTag: View {
    let text: String
    let isSelected: Bool
    let onTap: (() -> Void)?

    init(_ text: String, isSelected: Bool = false, onTap: (() -> Void)? = nil) {
        self.text = text
        self.isSelected = isSelected
        self.onTap = onTap
    }

    var body: some View {
        Group {
            if let onTap = onTap {
                Button(action: {
                    HapticFeedback.impact(.light)
                    onTap()
                }) {
                    tagContent
                }
            } else {
                tagContent
            }
        }
    }

    private var tagContent: some View {
        Text(text)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(isSelected ? .white : DesignTokens.Colors.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                isSelected ?
                    LinearGradient(
                        colors: [DesignTokens.Colors.primary, DesignTokens.Colors.secondary],
                        startPoint: .leading,
                        endPoint: .trailing
                    ) :
                    LinearGradient(
                        colors: [DesignTokens.Colors.backgroundSecondary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
            )
            .cornerRadius(DesignTokens.CornerRadius.xl)
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                    .stroke(
                        isSelected ? Color.clear : DesignTokens.Colors.border,
                        lineWidth: 1
                    )
            )
    }
}

/// Removable Tag - Tag with close button
struct RemovableTag: View {
    let text: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(DesignTokens.Colors.textPrimary)

            Button(action: {
                HapticFeedback.impact(.light)
                onRemove()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(DesignTokens.Colors.textTertiary)
            }
        }
        .padding(.leading, 16)
        .padding(.trailing, 12)
        .padding(.vertical, 8)
        .background(DesignTokens.Colors.backgroundSecondary)
        .cornerRadius(DesignTokens.CornerRadius.xl)
    }
}

/// Verification Badge - For verified profiles
struct VerificationBadge: View {
    let size: CGFloat

    init(size: CGFloat = 20) {
        self.size = size
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(DesignTokens.Colors.info)
                .frame(width: size, height: size)

            Image(systemName: "checkmark")
                .font(.system(size: size * 0.6, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

/// Premium Badge - For premium users
struct PremiumBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "crown.fill")
                .font(.system(size: 12))

            Text("PREMIUM")
                .font(.system(size: 11, weight: .bold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 255/255, green: 215/255, blue: 0/255),
                    Color(red: 255/255, green: 165/255, blue: 0/255)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(DesignTokens.CornerRadius.xl)
        .shadow(color: Color.yellow.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview("Badges") {
    ScrollView {
        VStack(spacing: DesignTokens.Spacing.lg) {
            Text("Badge Components")
                .heading1()

            // Standard badges
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Text("Standard Badges")
                    .heading3()

                HStack(spacing: DesignTokens.Spacing.sm) {
                    SpottedBadge("New", color: .primary, style: .filled, size: .small)
                    SpottedBadge("Premium", color: .secondary, style: .filled, size: .medium)
                    SpottedBadge("Featured", color: .success, style: .filled, size: .large)
                }

                HStack(spacing: DesignTokens.Spacing.sm) {
                    SpottedBadge("Active", color: .success, style: .outlined, size: .medium)
                    SpottedBadge("Pending", color: .warning, style: .outlined, size: .medium)
                    SpottedBadge("Error", color: .error, style: .outlined, size: .medium)
                }

                HStack(spacing: DesignTokens.Spacing.sm) {
                    SpottedBadge("Trending", color: .primary, style: .subtle, size: .medium, icon: "flame.fill")
                    SpottedBadge("Verified", color: .info, style: .subtle, size: .medium, icon: "checkmark.seal.fill")
                }
            }

            Divider()

            // Status badges
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Text("Status Badges")
                    .heading3()

                VStack(alignment: .leading, spacing: 8) {
                    StatusBadge(.online)
                    StatusBadge(.away)
                    StatusBadge(.busy)
                    StatusBadge(.offline)
                }

                HStack(spacing: 12) {
                    StatusBadge(.online, showText: false)
                    StatusBadge(.away, showText: false)
                    StatusBadge(.busy, showText: false)
                    StatusBadge(.offline, showText: false)
                }
            }

            Divider()

            // Count badges
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Text("Count Badges")
                    .heading3()

                HStack(spacing: DesignTokens.Spacing.md) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 32))
                            .foregroundColor(DesignTokens.Colors.textSecondary)

                        CountBadge(count: 5)
                            .offset(x: 8, y: -8)
                    }

                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "message.fill")
                            .font(.system(size: 32))
                            .foregroundColor(DesignTokens.Colors.textSecondary)

                        CountBadge(count: 42)
                            .offset(x: 8, y: -8)
                    }

                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "tray.fill")
                            .font(.system(size: 32))
                            .foregroundColor(DesignTokens.Colors.textSecondary)

                        CountBadge(count: 150)
                            .offset(x: 8, y: -8)
                    }
                }
            }

            Divider()

            // Tags
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Text("Tags")
                    .heading3()

                FlowLayout(spacing: 8) {
                    SpottedTag("Coffee Lover")
                    SpottedTag("Hiking", isSelected: true)
                    SpottedTag("Photography")
                    SpottedTag("Music", isSelected: true)
                    SpottedTag("Travel")
                }

                Text("Removable Tags")
                    .labelMedium()
                    .foregroundColor(DesignTokens.Colors.textSecondary)
                    .padding(.top, 8)

                FlowLayout(spacing: 8) {
                    RemovableTag(text: "Fitness") { print("Remove Fitness") }
                    RemovableTag(text: "Cooking") { print("Remove Cooking") }
                    RemovableTag(text: "Art") { print("Remove Art") }
                }
            }

            Divider()

            // Special badges
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Text("Special Badges")
                    .heading3()

                HStack(spacing: DesignTokens.Spacing.md) {
                    VerificationBadge(size: 24)
                    PremiumBadge()
                }
            }
        }
        .padding()
    }
}

// MARK: - Flow Layout Helper

/// Flow layout for wrapping tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let width = proposal.replacingUnspecifiedDimensions().width
        let height = rows.reduce(0) { $0 + $1.height + spacing } - spacing
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY

        for row in rows {
            var x = bounds.minX

            for index in row.range {
                let size = subviews[index].sizeThatFits(.unspecified)
                subviews[index].place(at: CGPoint(x: x, y: y), proposal: .unspecified)
                x += size.width + spacing
            }

            y += row.height + spacing
        }
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        let width = proposal.replacingUnspecifiedDimensions().width
        var rows: [Row] = []
        var currentRow = Row()

        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)

            if currentRow.width + size.width > width, !currentRow.range.isEmpty {
                rows.append(currentRow)
                currentRow = Row()
            }

            currentRow.add(index: index, width: size.width, height: size.height, spacing: spacing)
        }

        if !currentRow.range.isEmpty {
            rows.append(currentRow)
        }

        return rows
    }

    private struct Row {
        var range: Range<Int> = 0..<0
        var width: CGFloat = 0
        var height: CGFloat = 0

        mutating func add(index: Int, width: CGFloat, height: CGFloat, spacing: CGFloat) {
            if range.isEmpty {
                range = index..<(index + 1)
                self.width = width
                self.height = height
            } else {
                range = range.lowerBound..<(index + 1)
                self.width += width + spacing
                self.height = max(self.height, height)
            }
        }
    }
}

// MARK: - Usage Examples
/*

 // Basic badge
 SpottedBadge("New", color: .primary, style: .filled)

 // Badge with icon
 SpottedBadge("Verified", color: .success, style: .subtle, icon: "checkmark.seal.fill")

 // Status indicator
 StatusBadge(.online)
 StatusBadge(.online, showText: false) // Just the dot

 // Count badge on icon
 ZStack(alignment: .topTrailing) {
     Image(systemName: "bell.fill")
         .font(.system(size: 24))

     CountBadge(count: 5)
         .offset(x: 4, y: -4)
 }

 // Interactive tag
 @State private var isSelected = false

 SpottedTag("Music", isSelected: isSelected) {
     isSelected.toggle()
 }

 // Removable tag
 RemovableTag(text: "Coffee") {
     removeInterest("Coffee")
 }

 // Verification badge
 VerificationBadge(size: 20)

 // Premium badge
 PremiumBadge()

 */
