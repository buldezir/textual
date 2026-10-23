import Foundation

extension Formatter {
  /// The text that was selected, one block to a line: list markers, indentation
  /// and thematic breaks are drawn, not selected, so they stay out of it.
  func plainText() -> String {
    selectedBlockNodes.renderPlainText()
  }
}

// MARK: - Inline rendering

extension Formatter.InlineNode {
  fileprivate func renderPlainText() -> String {
    switch self {
    case .text(let text):
      return text
    case .code(let code):
      return code
    case .strong(let children):
      return children.renderPlainText()
    case .emphasized(let children):
      return children.renderPlainText()
    case .strikethrough(let children):
      return children.renderPlainText()
    case .link(_, let children):
      return children.renderPlainText()
    case .lineBreak:
      return "\n"
    case .attachment(let attachment):
      return attachment.description
    }
  }
}

extension Array where Element == Formatter.InlineNode {
  fileprivate func renderPlainText() -> String {
    self.map {
      $0.renderPlainText()
    }.joined()
  }
}

// MARK: - Block rendering

extension Formatter.BlockNode {
  fileprivate func renderPlainText(tightSpacing: Bool) -> String? {
    switch self {
    case .paragraph(let children):
      return children.renderPlainText()
    case .header(_, let children):
      return children.renderPlainText()
    case .orderedList(let children), .unorderedList(let children):
      return children.map {
        $0.blocks.renderPlainText(tightSpacing: true)
      }.joined(separator: "\n")
    case .codeBlock(_, let code):
      return code
    case .blockQuote(let children):
      return children.renderPlainText(tightSpacing: tightSpacing)
    case .table(_, let children):
      return children.renderPlainText()
    case .thematicBreak:
      return nil
    }
  }
}

extension Array where Element == Formatter.BlockNode {
  fileprivate func renderPlainText(tightSpacing: Bool = false) -> String {
    self.compactMap {
      $0.renderPlainText(tightSpacing: tightSpacing)
    }.joined(separator: tightSpacing ? "\n" : "\n\n")
  }
}

// MARK: - Table rendering

extension Array where Element == Formatter.TableRow {
  /// Cells separated by tabs, as browsers copy tables.
  fileprivate func renderPlainText() -> String {
    self.map {
      $0.cells.map { $0.renderPlainText() }.joined(separator: "\t")
    }.joined(separator: "\n")
  }
}
