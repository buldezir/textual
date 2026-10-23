import SwiftUI

// MARK: - Overview
//
// `TextSelectionInteraction` manages the text selection model lifecycle for multiple `Text` fragments.
//
// Selection is opt-in through the `textSelection` environment value. When enabled, the modifier
// observes text layout changes via `overlayTextLayoutCollection` and creates or updates a
// `TextSelectionModel`. The model is then passed to the platform-specific implementation
// (`PlatformTextSelectionInteraction`), which presents the appropriate selection UI for macOS
// or iOS. This separation keeps model management in shared code while platform interactions
// remain independent.

struct TextSelectionInteraction: ViewModifier {
  #if TEXTUAL_ENABLE_TEXT_SELECTION
    @Environment(\.textSelection) private var textSelection
    @Environment(TextSelectionCoordinator.self) private var coordinator: TextSelectionCoordinator?

    @State private var model = TextSelectionModel()
  #endif

  func body(content: Content) -> some View {
    #if TEXTUAL_ENABLE_TEXT_SELECTION
      if textSelection.allowsSelection {
        content
          .overlayTextLayoutCollection { layoutCollection in
            // Not `onChange`: when the layout changes more than once in a frame, as
            // text that fits in a frame does while it settles, SwiftUI runs the
            // action once and drops the rest, which can leave the model without
            // the text, so clicks find neither text nor links. A representable's
            // update runs on every update, with the latest layout.
            TextLayoutCollectionUpdater(
              model: model,
              coordinator: coordinator,
              layoutCollection: layoutCollection
            )
          }
          .modifier(PlatformTextSelectionInteraction(model: model))
      } else {
        content
      }
    #else
      content
    #endif
  }
}

#if TEXTUAL_ENABLE_TEXT_SELECTION
  extension EnvironmentValues {
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    @Entry var textSelection: any TextSelectability.Type = DisabledTextSelectability.self
  }
#endif

extension EnvironmentValues {
  @Entry var textSelectionColor: Color? = nil
}

#if TEXTUAL_ENABLE_TEXT_SELECTION
  /// Hands the model the latest layout collection. Its view takes no events,
  /// which go to the selection overlay.
  private struct TextLayoutCollectionUpdater {
    let model: TextSelectionModel
    let coordinator: TextSelectionCoordinator?
    let layoutCollection: any TextLayoutCollection

    func update() {
      model.setCoordinator(coordinator)
      model.setLayoutCollection(layoutCollection)
    }
  }

  #if canImport(AppKit) && !targetEnvironment(macCatalyst)
    extension TextLayoutCollectionUpdater: NSViewRepresentable {
      func makeNSView(context: Context) -> PassthroughView {
        update()
        return PassthroughView()
      }

      func updateNSView(_: PassthroughView, context: Context) {
        update()
      }

      final class PassthroughView: NSView {
        override func hitTest(_: NSPoint) -> NSView? { nil }
      }
    }
  #else
    extension TextLayoutCollectionUpdater: UIViewRepresentable {
      func makeUIView(context: Context) -> UIView {
        update()
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
      }

      func updateUIView(_: UIView, context: Context) {
        update()
      }
    }
  #endif
#endif
