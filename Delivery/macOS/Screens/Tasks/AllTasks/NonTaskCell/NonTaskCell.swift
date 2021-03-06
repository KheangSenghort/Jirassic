//
//  NonTaskCell.swift
//  Jirassic
//
//  Created by Baluta Cristian on 07/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class NonTaskCell: NSTableRowView, CellProtocol {

    @IBOutlet var statusImage: NSImageView?
    @IBOutlet fileprivate var statusImageWidthContraint: NSLayoutConstraint!
    @IBOutlet fileprivate var dateStartTextField: TimeBox!
    @IBOutlet fileprivate var dateStartTextFieldLeadingContraint: NSLayoutConstraint!
	@IBOutlet fileprivate var dateEndTextField: TimeBox!
	@IBOutlet fileprivate var notesTextField: NSTextField!
	@IBOutlet fileprivate var notesTextFieldTrailingContraint: NSLayoutConstraint!
	@IBOutlet fileprivate var butRemove: NSButton!
	@IBOutlet fileprivate var butAdd: NSButton!
    
    fileprivate var trackingArea: NSTrackingArea?
	
	var didEndEditingCell: ((_ cell: CellProtocol) -> ())?
	var didRemoveCell: ((_ cell: CellProtocol) -> ())?
	var didAddCell: ((_ cell: CellProtocol) -> ())?
	var didCopyContentCell: ((_ cell: CellProtocol) -> ())?
    
    fileprivate var _data: TaskCreationData?
	var data: TaskCreationData {
		get {
            if let dateStart = _data?.dateStart {
                let newHM = Date.parseHHmm(self.dateStartTextField.stringValue)
                let date = dateStart.dateByUpdating(hour: newHM.hour, minute: newHM.min)
                _data?.dateStart = date
            }
            let newHM = Date.parseHHmm(self.dateEndTextField.stringValue)
            let dateEnd = _data!.dateEnd.dateByUpdating(hour: newHM.hour, minute: newHM.min)
            _data?.dateEnd = dateEnd
            
            _data?.notes = self.notesTextField.stringValue
            
            return _data!
		}
        set {
            _data = newValue
            if let dateStart = newValue.dateStart {
                self.dateStartTextField.stringValue = dateStart.HHmm()
                self.dateStartTextField.isHidden = false
                self.dateStartTextFieldLeadingContraint.constant = 14
            } else {
                self.dateStartTextField.isHidden = true
                self.dateStartTextFieldLeadingContraint.constant = 14 - 36 - 4
            }
            self.dateEndTextField.stringValue = newValue.dateEnd.HHmm()
			self.notesTextField.stringValue = newValue.notes
		}
	}
	var duration: String {
		get {
			return ""
		}
        set {
            
        }
    }
    var isDark: Bool = false
    var isEditable: Bool = true
    var isIgnored: Bool = false {
        didSet {
            self.notesTextField!.alphaValue = isIgnored ? 0.5 : 1.0
        }
    }
    var color: NSColor = NSColor.black {
        didSet {
            self.notesTextField!.textColor = color
        }
    }
	
	override func awakeFromNib() {
        super.awakeFromNib()
        
		butRemove.isHidden = true
		butAdd.isHidden = true
        butRemove.wantsLayer = true
        dateStartTextField.didEndEditing = {
            self.didEndEditingCell?(self)
        }
        dateEndTextField.didEndEditing = {
            self.didEndEditingCell?(self)
        }
        if AppDelegate.sharedApp().theme.isDark {
            notesTextField!.textColor = NSColor.white
        }
	}
	
	override func drawBackground (in dirtyRect: NSRect) {
        
		NSColor(calibratedWhite: 1.0, alpha: 0.0).setFill()
		let selectionPath = NSBezierPath(roundedRect: dirtyRect, xRadius: 0, yRadius: 0)
		selectionPath.fill()
	}
}

extension NonTaskCell {
	
	@IBAction func handleRemoveButton (_ sender: NSButton) {
		self.didRemoveCell?(self)
	}
	
	@IBAction func handleAddButton (_ sender: NSButton) {
		self.didAddCell?(self)
	}
}

extension NonTaskCell {
    
	override func mouseEntered (with theEvent: NSEvent) {
        
		self.butRemove.isHidden = false
        self.butAdd.isHidden = false
        self.dateStartTextField.isEditable = true
        self.dateEndTextField.isEditable = true
		self.notesTextFieldTrailingContraint.constant = 80
		self.setNeedsDisplay(self.frame)
	}
	
//    override func mouseMoved(with event: NSEvent) {
//        
//        let locationInWindow = event.locationInWindow
//        let locationInView = self.convert(locationInWindow, from: nil)
//        RCLog(locationInView)
//        if dateStartTextField.frame.contains(locationInView) {
//            dateStartTextField.font = NSFont.systemFont(ofSize: 14)
//        }
//    }
    
	override func mouseExited (with theEvent: NSEvent) {
        
		self.butRemove.isHidden = true
        self.butAdd.isHidden = true
        self.dateStartTextField.isEditable = false
        self.dateEndTextField.isEditable = false
		self.notesTextFieldTrailingContraint.constant = 10
		self.setNeedsDisplay(self.frame)
	}
	
	func ensureTrackingArea() {
        
		if trackingArea == nil {
			trackingArea = NSTrackingArea(rect: NSZeroRect,
				options: [
                    NSTrackingArea.Options.inVisibleRect,
                    NSTrackingArea.Options.activeAlways,
                    NSTrackingArea.Options.mouseEnteredAndExited
                ],
				owner: self,
				userInfo: nil)
		}
	}
	
	override func updateTrackingAreas() {
		super.updateTrackingAreas()
        
		self.ensureTrackingArea()
		if !self.trackingAreas.contains(self.trackingArea!) {
			self.addTrackingArea(self.trackingArea!)
		}
	}
}
