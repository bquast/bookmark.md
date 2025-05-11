//
//  ViewController.swift
//  bookmark.md
//
//  Created by Bastiaan Quast on 5/11/25.
//

import UIKit

class ViewController: UIViewController {

    private var textView: UITextView!

    // --- Font Definitions ---
    let baseFontSize: CGFloat = 16.0
    lazy var titleFont = UIFont.boldSystemFont(ofSize: baseFontSize + 12) // e.g., 28pt bold
    lazy var authorFont = UIFont.systemFont(ofSize: baseFontSize + 6)    // e.g., 22pt
    lazy var chapterFont = UIFont.boldSystemFont(ofSize: baseFontSize + 4) // e.g., 20pt bold
    lazy var sectionFont = UIFont.boldSystemFont(ofSize: baseFontSize + 2) // e.g., 18pt bold
    lazy var normalFont = UIFont.systemFont(ofSize: baseFontSize)
    
    lazy var italicFont: UIFont = {
        if let descriptor = normalFont.fontDescriptor.withSymbolicTraits(.traitItalic) {
            return UIFont(descriptor: descriptor, size: baseFontSize)
        }
        return normalFont // Fallback
    }()
    
    lazy var boldFont: UIFont = { // Used for inline bold if base font isn't already bold
        if let descriptor = normalFont.fontDescriptor.withSymbolicTraits(.traitBold) {
            return UIFont(descriptor: descriptor, size: baseFontSize)
        }
        return UIFont.boldSystemFont(ofSize: baseFontSize) // Fallback
    }()
    // --- End Font Definitions ---

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextView()
        loadAndRenderMarkdown()
    }

    private func setupTextView() {
        textView = UITextView()
        textView.isEditable = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15)
        ])
    }

    private func loadAndRenderMarkdown() {
        // For now, using the example Markdown content.
        // Sourced from: https://raw.githubusercontent.com/mlschmitt/classic-books-markdown/refs/heads/main/Friedrich%20Nietzsche/Thus%20Spoke%20Zarathustra.md
        let markdownText = """
        # Title: Thus Spoke Zarathustra
        ## Author: Friedrich Nietzsche
        ## Year: 1883
        -------
        _Translated By Thomas Common_

        ## FIRST PART. ZARATHUSTRA'S DISCOURSES.

        ## ZARATHUSTRA'S PROLOGUE.

        *1*
        When Zarathustra was thirty years old, he left his home and the lake of his home, and went into the mountains. There he enjoyed his spirit and solitude, and for ten years did not weary of it. But at last his heart changed,--and rising one morning with the rosy dawn, he went before the sun, and spake thus unto it:

        Thou great star! What would be thy happiness if thou hadst not those for whom thou shinest!
        For ten years hast thou climbed hither unto my cave: thou wouldst have wearied of thy light and of the journey, had it not been for me, mine eagle, and my serpent.

        But we awaited thee every morning, took from thee thine overflow and blessed thee for it.
        Lo! I am weary of my wisdom, like the bee that hath gathered too much honey; I need hands outstretched to take it.
        I would fain bestow and distribute, until the wise have once more become joyous in their folly, and the poor happy in their riches.

        Therefore must I descend into the deep: as thou doest in the evening, when thou goest behind the sea, and givest light also to the nether-world, thou exuberant star!
        Like thee must I GO DOWN, as men say, to whom I shall descend. _This is an_ **inline test** _of sorts_.

        Bless me, then, thou tranquil eye, that canst behold even the greatest happiness without envy!
        Bless the cup that is about to overflow, that the water may flow golden out of it, and carry everywhere the reflection of thy bliss!
        Lo! This cup is again going to empty itself, and Zarathustra is again going to be a man. **This is bold.** And this is __also bold__.

        Thus began Zarathustra's down-going.

        *2*
        Zarathustra went down the mountain alone, no one meeting him. When he entered the forest, however, there suddenly stood before him an old man, who had left his holy cot to seek roots. And thus spake the old man to Zarathustra:
        "No stranger to me is this wanderer: many years ago passed he by. Zarathustra he was called; but he hath altered."
        """
        
        textView.attributedText = parseMarkdownRevised(markdownText)
    }

    private func parseMarkdownRevised(_ markdown: String) -> NSAttributedString {
        let finalAttributedString = NSMutableAttributedString()
        let lines = markdown.components(separatedBy: .newlines)
        
        var paragraphBuffer = [String]()

        func flushParagraphBuffer(isFollowedByBlock: Bool = false) {
            if !paragraphBuffer.isEmpty {
                let paragraphText = paragraphBuffer.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
                if !paragraphText.isEmpty {
                    appendFormattedString(text: paragraphText, baseFont: normalFont, paragraphSpacing: baseFontSize * 0.75, to: finalAttributedString)
                    // Add a single newline after a paragraph, letting block elements or explicit empty lines handle larger spacing.
                    finalAttributedString.append(NSAttributedString(string: "\n"))
                }
                paragraphBuffer.removeAll()
            }
        }

        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)

            if trimmedLine.isEmpty {
                flushParagraphBuffer()
                // Add an additional newline for spacing caused by an empty line,
                // but only if the string isn't empty and doesn't already end with double newlines.
                if finalAttributedString.length > 0 && !finalAttributedString.string.hasSuffix("\n\n") {
                     finalAttributedString.append(NSAttributedString(string: "\n"))
                }
                continue
            }

            if trimmedLine.starts(with: "# Title: ") {
                flushParagraphBuffer(isFollowedByBlock: true)
                let content = String(trimmedLine.dropFirst("# Title: ".count))
                appendFormattedString(text: content, baseFont: titleFont, to: finalAttributedString)
                finalAttributedString.append(NSAttributedString(string: "\n\n")) // Space after title
            } else if trimmedLine.starts(with: "## Author: ") {
                flushParagraphBuffer(isFollowedByBlock: true)
                let content = String(trimmedLine.dropFirst("## Author: ".count))
                appendFormattedString(text: content, baseFont: authorFont, to: finalAttributedString)
                finalAttributedString.append(NSAttributedString(string: "\n\n")) // Space after author
            } else if trimmedLine.starts(with: "## Year: ") {
                flushParagraphBuffer(isFollowedByBlock: true)
                // Year is parsed but not rendered visually as per initial requirements.
                // Add a newline for spacing if it was the last thing before other content.
                 if finalAttributedString.length > 0 && !finalAttributedString.string.hasSuffix("\n") {
                    finalAttributedString.append(NSAttributedString(string: "\n"))
                }
            } else if trimmedLine.starts(with: "## ") { // Chapter
                flushParagraphBuffer(isFollowedByBlock: true)
                let content = String(trimmedLine.dropFirst("## ".count))
                appendFormattedString(text: content, baseFont: chapterFont, to: finalAttributedString)
                finalAttributedString.append(NSAttributedString(string: "\n\n")) // Space after chapter
            } else if trimmedLine == "-------" {
                flushParagraphBuffer(isFollowedByBlock: true)
                // Visual separator (e.g., a line) could be added. For now, just space.
                if finalAttributedString.length > 0 && !finalAttributedString.string.hasSuffix("\n\n") {
                     finalAttributedString.append(NSAttributedString(string: "\n"))
                }
            } else if trimmedLine.matchesRegex(#"^\*\d+\*$"#) { // Section e.g. *1*
                flushParagraphBuffer(isFollowedByBlock: true)
                appendFormattedString(text: trimmedLine, baseFont: sectionFont, to: finalAttributedString)
                finalAttributedString.append(NSAttributedString(string: "\n\n")) // Space after section
            } else {
                paragraphBuffer.append(trimmedLine) // Collect lines for a paragraph
            }
        }
        
        flushParagraphBuffer() // Process any remaining paragraph text

        // Clean up excessive trailing newlines
        while finalAttributedString.string.hasSuffix("\n\n\n") {
             finalAttributedString.deleteCharacters(in: NSRange(location: finalAttributedString.length - 1, length: 1))
        }
        // Ensure some padding at the very end if content exists
        if finalAttributedString.length > 0 && !finalAttributedString.string.hasSuffix("\n\n") {
             if !finalAttributedString.string.hasSuffix("\n") {
                 finalAttributedString.append(NSAttributedString(string: "\n"))
             }
            finalAttributedString.append(NSAttributedString(string: "\n"))
        }

        return finalAttributedString
    }

    private func appendFormattedString(text: String, baseFont: UIFont, paragraphSpacing: CGFloat? = nil, to masterAttributedString: NSMutableAttributedString) {
        if text.isEmpty { return }

        var attributes: [NSAttributedString.Key: Any] = [.font: baseFont]
        
        if let pSpacing = paragraphSpacing {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.paragraphSpacing = pSpacing // Space after the paragraph
            // paragraphStyle.lineSpacing = baseFontSize * 0.15 // Optional: Adjust line height within paragraphs
            attributes[.paragraphStyle] = paragraphStyle
        }

        applyInlineStyles(to: text, baseAttributes: attributes, output: masterAttributedString)
    }
    
    private func applyInlineStyles(to text: String, baseAttributes: [NSAttributedString.Key: Any], output: NSMutableAttributedString) {
        let finalStyledText = NSMutableAttributedString()
        var currentIndex = text.startIndex

        // Regex to find **bold**, __bold__, or _italic_
        // Groups: 1 for **content**, 2 for __content__, 3 for _content_
        let combinedPattern = #"(?:\*\*(.+?)\*\*)|(?:__(.+?)__)|(?:_([^_]+?)_)"#
        
        guard let regex = try? NSRegularExpression(pattern: combinedPattern) else {
            finalStyledText.append(NSAttributedString(string: text, attributes: baseAttributes))
            output.append(finalStyledText)
            return
        }

        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))

        for match in matches {
            // Text before this match
            let matchStartOffset = match.range.location
            if matchStartOffset > text.distance(from: text.startIndex, to: currentIndex) {
                let preTextRange = currentIndex..<text.index(text.startIndex, offsetBy: matchStartOffset)
                finalStyledText.append(NSAttributedString(string: String(text[preTextRange]), attributes: baseAttributes))
            }

            var inlineAttributes = baseAttributes
            let currentBaseFont = baseAttributes[.font] as? UIFont ?? self.normalFont
            var contentText = ""
            var matchedFullRange = match.range // The full range of the markdown (e.g., including the ** **)

            if match.range(at: 1).location != NSNotFound { // **bold**
                let contentRangeInMatch = match.range(at: 1)
                contentText = (text as NSString).substring(with: contentRangeInMatch)
                if let descriptor = currentBaseFont.fontDescriptor.withSymbolicTraits([currentBaseFont.fontDescriptor.symbolicTraits, .traitBold]) {
                    inlineAttributes[.font] = UIFont(descriptor: descriptor, size: currentBaseFont.pointSize)
                }
            } else if match.range(at: 2).location != NSNotFound { // __bold__
                let contentRangeInMatch = match.range(at: 2)
                contentText = (text as NSString).substring(with: contentRangeInMatch)
                 if let descriptor = currentBaseFont.fontDescriptor.withSymbolicTraits([currentBaseFont.fontDescriptor.symbolicTraits, .traitBold]) {
                    inlineAttributes[.font] = UIFont(descriptor: descriptor, size: currentBaseFont.pointSize)
                }
            } else if match.range(at: 3).location != NSNotFound { // _italic_
                let contentRangeInMatch = match.range(at: 3)
                contentText = (text as NSString).substring(with: contentRangeInMatch)
                if let descriptor = currentBaseFont.fontDescriptor.withSymbolicTraits([currentBaseFont.fontDescriptor.symbolicTraits, .traitItalic]) {
                    inlineAttributes[.font] = UIFont(descriptor: descriptor, size: currentBaseFont.pointSize)
                }
            }
            
            if !contentText.isEmpty {
                finalStyledText.append(NSAttributedString(string: contentText, attributes: inlineAttributes))
            }
            currentIndex = text.index(text.startIndex, offsetBy: matchedFullRange.upperBound)
        }

        // Text after the last match
        if currentIndex < text.endIndex {
            finalStyledText.append(NSAttributedString(string: String(text[currentIndex...]), attributes: baseAttributes))
        }
        
        output.append(finalStyledText)
    }
}

extension String {
    func matchesRegex(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
}

