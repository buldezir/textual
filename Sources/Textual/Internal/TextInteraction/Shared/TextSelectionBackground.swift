import SwiftUI

// MARK: - Overview
//
// `TextSelectionBackground` draws selection highlights behind a `Text` fragment.
//
// The platform selection interaction stores a `TextSelectionModel` in the environment at fragment
// scope. This modifier reads the fragment’s anchored `Text.Layout` and forwards it to the AppKit
// selection view so it can convert the current selected range into highlight rectangles.

struct TextSelectionBackground: ViewModifier {
  @Environment(\.textSelectionColor) private var color

  func body(content: Content) -> some View {
    #if TEXTUAL_ENABLE_TEXT_SELECTION && canImport(AppKit) && !targetEnvironment(macCatalyst)
      if let color {
        // A colour of its own goes over the text: see `textSelectionColor(_:)`.
        content
          .overlayPreferenceValue(Text.LayoutKey.self) { value in
            highlight(value, color: color)
              .allowsHitTesting(false)
          }
      } else {
        content
          .backgroundPreferenceValue(Text.LayoutKey.self) { value in
            highlight(value, color: Color(nsColor: .selectedTextBackgroundColor))
          }
      }
    #else
      content
    #endif
  }

  #if TEXTUAL_ENABLE_TEXT_SELECTION && canImport(AppKit) && !targetEnvironment(macCatalyst)
    @ViewBuilder
    private func highlight(_ value: Text.LayoutKey.Value, color: Color) -> some View {
      if let anchoredLayout = value.first {
        GeometryReader { geometry in
          AppKitTextSelectionView(
            layout: anchoredLayout.layout,
            origin: geometry[anchoredLayout.origin],
            color: color
          )
        }
      }
    }
  #endif
}
