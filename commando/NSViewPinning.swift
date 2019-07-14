//
//  NSViewPinning.swift
//  commando
//
//  Created by Uli Kusterer on 12.07.19.
//  Copyright © 2019 Uli Kusterer. All rights reserved.
//

import Cocoa

let dontPin = CGFloat(Double.leastNormalMagnitude)
let pinToTop = NSEdgeInsets(top: 20.0, left: 20.0, bottom: dontPin, right: 20.0)
let pinToPrevious = NSEdgeInsets(top: 12.0, left: 20.0, bottom: dontPin, right: 20.0)
let pinToBottom = NSEdgeInsets(top: 12.0, left: 20.0, bottom: 20.0, right: 20.0)
let pinAllSides = NSEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)

extension NSView {
	/// Make a view resize with this view.
	func pin(view: NSView, insets: NSEdgeInsets = pinAllSides, insert: Bool = true) {
		if insert {
			self.addSubview(view)
		}
		
		view.translatesAutoresizingMaskIntoConstraints = false
	
		if insets.left != dontPin {
			view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: insets.left).isActive = true
		}
		if insets.top != dontPin {
			view.topAnchor.constraint(equalTo: self.topAnchor, constant: insets.top).isActive = true
		}
		if insets.bottom != dontPin {
			view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: insets.bottom).isActive = true
		}
		if insets.right != dontPin {
			view.rightAnchor.constraint(equalTo: self.rightAnchor, constant: insets.right).isActive = true
		}
	}

	/// Pin a label and a view into this view, aligning the left edges of all values.
	func pin(label: NSView, value: NSView, prevValue: inout NSView?, spacing: CGFloat = 8, insets: NSEdgeInsets = pinToPrevious, insert: Bool = true) {
		
		label.translatesAutoresizingMaskIntoConstraints = false
		value.translatesAutoresizingMaskIntoConstraints = false

		if insert {
			self.addSubview(label)
			self.addSubview(value)
		}

		label.firstBaselineAnchor.constraint(equalTo: value.firstBaselineAnchor).isActive = true
		if spacing != dontPin {
			value.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: spacing).isActive = true
		}
		
		if insets.left != dontPin {
			label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: insets.left).isActive = true
		}
		if insets.top != dontPin {
			value.topAnchor.constraint(equalTo: prevValue?.bottomAnchor ?? self.topAnchor, constant: insets.top).isActive = true
		}
		if insets.bottom != dontPin {
			value.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -insets.bottom).isActive = true
		}
		if insets.right != dontPin {
			value.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -insets.right).isActive = true
		}
		
		if let safePrevValue = prevValue {
			safePrevValue.leadingAnchor.constraint(equalTo: value.leadingAnchor).isActive = true
		}
		
		prevValue = value
	}
	
	func pin(button: NSButton, prevButton prevView: inout NSView?, spacing: CGFloat = 8, insets: NSEdgeInsets = pinAllSides, insert: Bool = true) {
		button.translatesAutoresizingMaskIntoConstraints = false

		if insert {
			self.addSubview(button)
		}
		if let prevButton = prevView as? NSButton, prevButton.bezelStyle == .rounded {
			button.trailingAnchor.constraint(equalTo: prevButton.leadingAnchor, constant: -spacing).isActive = true
			button.topAnchor.constraint(equalTo: prevButton.topAnchor).isActive = true
			button.bottomAnchor.constraint(equalTo: prevButton.bottomAnchor).isActive = true
			prevButton.widthAnchor.constraint(equalTo: button.widthAnchor).isActive = true
		} else {
			button.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -insets.right).isActive = true
			button.topAnchor.constraint(equalTo: prevView!.bottomAnchor, constant: insets.top).isActive = true
			button.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -insets.bottom).isActive = true
		}
		
		prevView = button
	}
}
