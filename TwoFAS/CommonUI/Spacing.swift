import SwiftUI

// MARK: - Spacing

/// Design system spacing scale.
///
/// Use directly wherever SwiftUI accepts a spacing value:
/// ```swift
/// view.padding(.M)
/// view.padding(.horizontal, .XL)
/// view.margin(.top, .S)
///
/// VStack(spacing: Spacing.M.value) { ... }
/// EdgeInsets(vertical: .L, horizontal: .M)
/// ```
public enum Spacing: CGFloat, CaseIterable {
    case XS     = 2
    case S      = 4
    case M      = 8
    case L      = 12
    case XL     = 16
    case XXL    = 20
    case XXXL   = 24
    case XXXXL  = 28
    case XXXXXL = 32

    /// Raw `CGFloat` value — use when a plain number is required,
    /// e.g. `VStack(spacing: Spacing.M.value)`.
    public var value: CGFloat { rawValue }
}

// MARK: - View + padding

public extension View {

    /// Applies equal padding on all edges.
    func padding(_ spacing: Spacing) -> some View {
        padding(spacing.value)
    }

    /// Applies padding to the specified edges.
    func padding(_ edges: Edge.Set, _ spacing: Spacing) -> some View {
        padding(edges, spacing.value)
    }

    /// Applies equal margin (padding) on all edges.
    func margin(_ spacing: Spacing) -> some View {
        padding(spacing.value)
    }

    /// Applies margin (padding) to the specified edges.
    func margin(_ edges: Edge.Set, _ spacing: Spacing) -> some View {
        padding(edges, spacing.value)
    }
}

// MARK: - Stack initializers

public extension VStack {
    init(alignment: HorizontalAlignment = .center, spacing: Spacing, @ViewBuilder content: () -> Content) {
        self.init(alignment: alignment, spacing: spacing.value, content: content)
    }
}

public extension HStack {
    init(alignment: VerticalAlignment = .center, spacing: Spacing, @ViewBuilder content: () -> Content) {
        self.init(alignment: alignment, spacing: spacing.value, content: content)
    }
}

public extension LazyVStack {
    init(alignment: HorizontalAlignment = .center, spacing: Spacing, pinnedViews: PinnedScrollableViews = .init(), @ViewBuilder content: () -> Content) {
        self.init(alignment: alignment, spacing: spacing.value, pinnedViews: pinnedViews, content: content)
    }
}

public extension LazyHStack {
    init(alignment: VerticalAlignment = .center, spacing: Spacing, pinnedViews: PinnedScrollableViews = .init(), @ViewBuilder content: () -> Content) {
        self.init(alignment: alignment, spacing: spacing.value, pinnedViews: pinnedViews, content: content)
    }
}

// MARK: - EdgeInsets

public extension EdgeInsets {

    /// Uniform insets on all sides.
    init(_ spacing: Spacing) {
        let v = spacing.value
        self.init(top: v, leading: v, bottom: v, trailing: v)
    }

    /// Separate vertical and horizontal insets.
    init(vertical: Spacing, horizontal: Spacing) {
        self.init(
            top: vertical.value,
            leading: horizontal.value,
            bottom: vertical.value,
            trailing: horizontal.value
        )
    }

    /// Independent insets per axis.
    init(top: Spacing, leading: Spacing, bottom: Spacing, trailing: Spacing) {
        self.init(
            top: top.value,
            leading: leading.value,
            bottom: bottom.value,
            trailing: trailing.value
        )
    }
}
