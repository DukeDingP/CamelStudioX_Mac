//
//  EditorTextView.swift
//  LineNumberTextView
//
//  Created by 戴植锐 on 2018/5/21.
//  Copyright © 2018 戴植锐. All rights reserved.
//

import Cocoa

struct StringInsertion {
    var position: Int = 0
    var character: Character = "\0"
}

public extension NSNotification.Name {
    static let TextDidChangeNotification = NSNotification.Name("TextDidChangeNotification")
}

public class EditorTextView: NSTextView {

    var tabCount = 0
    
    override public func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }
    
    func simulatedKeyDown(keyCode: CGKeyCode, useCommandFlag: Bool) {
        let sourceRef = CGEventSource(stateID: .combinedSessionState)
        if sourceRef == nil {
            NSLog("FakeKey: No event source")
            return
        }
        let keyDownEvent = CGEvent(keyboardEventSource: sourceRef,
                                   virtualKey: keyCode,
                                   keyDown: true)
        if useCommandFlag {
            keyDownEvent?.flags = .maskCommand
        }
        let keyUpEvent = CGEvent(keyboardEventSource: sourceRef,
                                 virtualKey: keyCode,
                                 keyDown: false)
        keyDownEvent?.post(tap: .cghidEventTap)
        keyUpEvent?.post(tap: .cghidEventTap)
    }
    
    func insertCharacter(with insertion: StringInsertion) {
        self.undoManager?.registerUndo(withTarget: self) {
            target in
            target.removeCharacter(with: insertion)
        }
        let position = self.string.index(self.string.startIndex, offsetBy: insertion.position)
        self.string.insert(insertion.character, at: position)
    }
    
    func removeCharacter(with insertion: StringInsertion) {
        self.undoManager?.registerUndo(withTarget: self) {
            target in
            target.insertCharacter(with: insertion)
        }
        let position = self.string.index(self.string.startIndex, offsetBy: insertion.position)
        self.string.remove(at: position)
    }
    
    override public func keyDown(with event: NSEvent) {
        super.keyDown(with: event)
        //debugPrint("keyCode = \(event.keyCode)")
        var upperBound: Int = self.selectedRange().upperBound
        let startIndex = self.string.startIndex
        let endIndex = self.string.index(startIndex, offsetBy: upperBound)
        // [33,30,48,36,51] keyCode for "{", "}", "\t", enter, delete
        if event.keyCode == 36 {                                    // enter pressed!
            self.tabCount = 0
            for character in self.string[startIndex..<endIndex] {   // calculate the number of tab to insert
                if character == "{" {
                    self.tabCount += 1
                } else if character == "}" {
                    self.tabCount -= 1
                }
            }
            if self.string.count - upperBound > 0 {
                if self.string[endIndex...endIndex] == "}" {            // If the next char is "}", make a newline for it.
                    self.insertCharacter(with: StringInsertion(position: upperBound, character: "}"))
                }
            }
            
            for _ in 0..<self.tabCount {                            // Start to insert tab.
                self.insertCharacter(with: StringInsertion(position: upperBound, character: "\t"))
                upperBound += 1
            }
            
        } else if event.keyCode == 33 {                             // "{" pressed!
            self.insertCharacter(with: StringInsertion(position: upperBound, character: "}")) // insert "}"
        } else if let char = event.characters {
            if char == "(" {
                self.insertCharacter(with: StringInsertion(position: upperBound, character: ")")) // insert ")"
            } else if char == "\"" {
                self.insertCharacter(with: StringInsertion(position: upperBound, character: "\""))
            } else if char == "'" {
                self.insertCharacter(with: StringInsertion(position: upperBound, character: "'"))
            }
        }
        self.setSelectedRange(NSMakeRange(upperBound, 0))           // move the cursor to the right position
        NotificationCenter.default.post(name: NSNotification.Name.TextDidChangeNotification, object: self)
    }
    
    //*********** The following part is from LineNumberTextView
    /// Holds the attached line number gutter.
    private var lineNumberGutter: LineNumberGutter?
    
    /// Holds the text color for the gutter. Available in the Inteface Builder.
    @IBInspectable public var lineNumberForegroundColor: NSColor? {
        didSet {
            if let gutter = self.lineNumberGutter,
                let color  = self.lineNumberForegroundColor {
                gutter.foregroundColor = color
            }
        }
    }
    
    /// Holds the background color for the gutter. Available in the Inteface Builder.
    @IBInspectable public var lineNumberBackgroundColor: NSColor? {
        didSet {
            if let gutter = self.lineNumberGutter,
                let color  = self.lineNumberBackgroundColor {
                gutter.backgroundColor = color
            }
        }
    }
    
    
    override public func awakeFromNib() {
        // Get the enclosing scroll view
        guard let scrollView = self.enclosingScrollView else {
            fatalError("Unwrapping the text views scroll view failed!")
        }
        
        if let gutterBG = self.lineNumberBackgroundColor,
            let gutterFG = self.lineNumberForegroundColor {
            self.lineNumberGutter = LineNumberGutter(withTextView: self, foregroundColor: gutterFG, backgroundColor: gutterBG)
        } else {
            self.lineNumberGutter = LineNumberGutter(withTextView: self)
        }
        
        scrollView.verticalRulerView  = self.lineNumberGutter
        scrollView.hasHorizontalRuler = false
        scrollView.hasVerticalRuler   = true
        scrollView.rulersVisible      = true
        
        self.addObservers()
    }
    // used when created not from storyboard
    public func openLineNumber() {
        // Get the enclosing scroll view
        guard let scrollView = self.enclosingScrollView else {
            fatalError("Unwrapping the text views scroll view failed!")
        }
        
        if let gutterBG = self.lineNumberBackgroundColor,
            let gutterFG = self.lineNumberForegroundColor {
            self.lineNumberGutter = LineNumberGutter(withTextView: self, foregroundColor: gutterFG, backgroundColor: gutterBG)
        } else {
            self.lineNumberGutter = LineNumberGutter(withTextView: self)
        }
        
        scrollView.verticalRulerView  = self.lineNumberGutter
        scrollView.hasHorizontalRuler = false
        scrollView.hasVerticalRuler   = true
        scrollView.rulersVisible      = true
        
        self.addObservers()
    }
    /// Add observers to redraw the line number gutter, when necessary.
    internal func addObservers() {
        self.postsFrameChangedNotifications = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(LineNumberTextView.drawGutter), name: NSView.frameDidChangeNotification, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(LineNumberTextView.drawGutter), name: NSText.didChangeNotification, object: self)
    }
    
    /// Set needsDisplay of lineNumberGutter to true.
    @objc internal func drawGutter() {
        if let lineNumberGutter = self.lineNumberGutter {
            lineNumberGutter.needsDisplay = true
        }
    }
}
