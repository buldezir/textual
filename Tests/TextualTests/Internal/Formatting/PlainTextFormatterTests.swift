import Foundation
import SwiftUI
import Testing

@testable import Textual

struct PlainTextFormatterTests {
  @Test func simpleParagraph() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(markdown: "This is a simple paragraph.")
    )

    // when
    let result = formatter.plainText()

    // then
    #expect(result == "This is a simple paragraph.")
  }

  @Test func multipleParagraphs() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(
        markdown: """
          First paragraph.

          Second paragraph.

          Third paragraph.
          """
      )
    )

    // when
    let result = formatter.plainText()

    // then
    #expect(result == "First paragraph.\n\nSecond paragraph.\n\nThird paragraph.")
  }

  @Test func headings() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(
        markdown: """
          # Heading 1

          ## Heading 2

          ### Heading 3
          """
      )
    )

    // when
    let result = formatter.plainText()

    // then
    #expect(result == "Heading 1\n\nHeading 2\n\nHeading 3")
  }

  @Test func unorderedList() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(
        markdown: """
          * First item
          * Second item
          * Third item
          """
      )
    )

    // when
    let result = formatter.plainText()

    // then
    #expect(result == "First item\nSecond item\nThird item")
  }

  @Test func orderedList() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(
        markdown: """
          1. First item
          2. Second item
          3. Third item
          """
      )
    )

    // when
    let result = formatter.plainText()

    // then
    #expect(result == "First item\nSecond item\nThird item")
  }

  @Test func nestedUnorderedList() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(
        markdown: """
          - First item
            - Nested item 1
            - Nested item 2
          - Second item
          """
      )
    )

    // when
    let result = formatter.plainText()

    // then
    #expect(
      result
        == "First item\nNested item 1\nNested item 2\nSecond item"
    )
  }

  @Test func nestedOrderedList() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(
        markdown: """
          1. First item
             1. Nested item 1
             2. Nested item 2
          2. Second item
          """
      )
    )

    // when
    let result = formatter.plainText()

    // then
    #expect(
      result
        == "First item\nNested item 1\nNested item 2\nSecond item"
    )
  }

  @Test func mixedNestedList() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(
        markdown: """
          1. Ordered first
             - Unordered nested
             - Another unordered
          2. Ordered second
          """
      )
    )

    // when
    let result = formatter.plainText()

    // then
    #expect(
      result
        == "Ordered first\nUnordered nested\nAnother unordered\nOrdered second"
    )
  }

  @Test func simpleBlockQuote() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(
        markdown: """
          > This is a quote.
          """
      )
    )

    // when
    let result = formatter.plainText()

    // then
    #expect(result == "This is a quote.")
  }

  @Test func blockQuoteWithParagraphs() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(
        markdown: """
          Before quote.

          > This is a quote.

          After quote.
          """
      )
    )

    // when
    let result = formatter.plainText()

    // then
    #expect(result == "Before quote.\n\nThis is a quote.\n\nAfter quote.")
  }

  // MARK: - Code Blocks

  @Test func codeBlock() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(
        markdown: """
          ```swift
          func hello() {
              print("Hello")
          }
          ```
          """
      )
    )

    // when
    let result = formatter.plainText()

    // then
    #expect(result == "func hello() {\n    print(\"Hello\")\n}\n")
  }

  @Test func codeBlockWithSurroundingText() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(
        markdown: """
          Before code.

          ```
          code line 1
          code line 2
          ```

          After code.
          """
      )
    )

    // when
    let result = formatter.plainText()

    // then
    #expect(result == "Before code.\n\ncode line 1\ncode line 2\n\n\nAfter code.")
  }

  @Test func simpleTable() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(
        markdown: """
          | Header 1 | Header 2 |
          | --- | --- |
          | Cell A1 | Cell A2 |
          | Cell B1 | Cell B2 |
          """
      )
    )
    let expected = """
      Header 1\tHeader 2
      Cell A1\tCell A2
      Cell B1\tCell B2
      """

    // when
    let result = formatter.plainText()

    // then
    #expect(result == expected)
  }

  @Test func complexMixedContent() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(
        markdown: """
          # Main Title

          Introduction paragraph.

          ## Section 1

          - First point
          - Second point
            - Nested point

          ## Section 2

          Some text before table.

          | Column A | Column B |
          | --- | --- |
          | Value 1 | Value 2 |

          ## Conclusion

          Final paragraph.
          """
      )
    )
    let expected = """
      Main Title

      Introduction paragraph.

      Section 1

      First point
      Second point
      Nested point

      Section 2

      Some text before table.

      Column A\tColumn B
      Value 1\tValue 2

      Conclusion

      Final paragraph.
      """

    // when
    let result = formatter.plainText()

    // then
    #expect(result == expected)
  }

  @Test func listAfterParagraph() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(
        markdown: """
          Here is a paragraph.

          - Item 1
          - Item 2
          """
      )
    )

    // when
    let result = formatter.plainText()

    // then
    #expect(result == "Here is a paragraph.\n\nItem 1\nItem 2")
  }

  @Test func partOfAListItem() throws {
    // given: the third item of a list, as a selection inside it carries it
    let formatter = try Formatter(
      NSAttributedString(
        markdown: """
          3. Third item
          """
      )
    )

    // when
    let result = formatter.plainText()

    // then
    #expect(result == "Third item")
  }

  @Test func thematicBreakIsNotText() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(
        markdown: """
          Before.

          ---

          After.
          """
      )
    )

    // when
    let result = formatter.plainText()

    // then
    #expect(result == "Before.\n\nAfter.")
  }

  @Test func hardLineBreak() throws {
    // given
    let formatter = try Formatter(
      NSAttributedString(markdown: "First line\\\nSecond line")
    )

    // when
    let result = formatter.plainText()

    // then
    #expect(result == "First line\nSecond line")
  }

  @Test func emptyString() throws {
    // given
    let formatter = Formatter(NSAttributedString())

    // when
    let result = formatter.plainText()

    // then
    #expect(result == "")
  }
}
