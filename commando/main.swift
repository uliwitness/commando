import Cocoa

class Options: Codable {
	var version: Int = 1
	var command: String = ""
	var options = [OptionController]()
}

class OptionController: NSObject, Codable {
	var name: String?
	var title: String?
	var value: String?
	var type: String?
	var active: Bool = false
	var field: NSTextField?
	var checkbox: NSButton?

	private enum CodingKeys: String, CodingKey {
		case name
		case title
		case type
	}
	
	func create(in contentView: NSView, prevValue: inout NSView?) {
		switch(type) {
		case "text":
			field = addTextField(title ?? "Label:", value: value ?? "", to: contentView, prevValue: &prevValue)
			active = true
		case "file":
			let views = addPathField(title ?? "Label:", value: "", to: contentView, prevValue: &prevValue)
			views.button.action = #selector(OptionController.pickFile(_:))
			field = views.field
			active = true
		case "files":
			let views = addPathField(title ?? "Label:", value: "", to: contentView, prevValue: &prevValue)
			views.button.action = #selector(OptionController.pickFiles(_:))
			field = views.field
			active = true
		case "directory":
			let views = addPathField(title ?? "Label:", value: "", to: contentView, prevValue: &prevValue)
			views.button.action = #selector(OptionController.pickFolder(_:))
			field = views.field
			active = true
		case "directories":
			let views = addPathField(title ?? "Label:", value: "", to: contentView, prevValue: &prevValue)
			views.button.action = #selector(OptionController.pickFolders(_:))
			field = views.field
			active = true
		case "boolean":
			checkbox = addCheckBox(title ?? "Option", to: contentView, prevValue: &prevValue)
			checkbox?.target = self
			checkbox?.action = #selector(OptionController.doCheckboxClicked(_:))
			active = value == "true"
			checkbox?.state = active ? .on : .off
		default:
			print("error: Unknown type \(type ?? "(nil)").")
		}
	}
	
	func readFromUI() {
		if let field = field {
			value = field.stringValue
		} else if type == "boolean" {
			active = (checkbox?.state ?? .off) == .on
		}
	}
	
	@objc func pickFile(_ sender: AnyObject) {
		let picker = NSOpenPanel()
		picker.canChooseFiles = true
		picker.canChooseDirectories = false
		picker.allowsMultipleSelection = false
		picker.begin { response in
			guard response == .OK else { return }
			
			self.value = picker.url?.path
			self.field?.stringValue = self.value ?? ""
		}
	}
	
	@objc func pickFiles(_ sender: AnyObject) {
		let picker = NSOpenPanel()
		picker.canChooseFiles = true
		picker.canChooseDirectories = false
		picker.allowsMultipleSelection = true
		picker.begin { response in
			guard response == .OK else { return }
			
			self.value = "\"\(picker.urls.map { $0.path }.joined(separator: "\" \""))\""
			self.field?.stringValue = self.value ?? ""
		}
	}
	
	@objc func pickFolder(_ sender: AnyObject) {
		let picker = NSOpenPanel()
		picker.canChooseFiles = false
		picker.canChooseDirectories = true
		picker.allowsMultipleSelection = true
		picker.begin { response in
			guard response == .OK else { return }
			
			self.value = picker.url?.path
			self.field?.stringValue = self.value ?? ""
		}
	}
	
	@objc func pickFolders(_ sender: AnyObject) {
		let picker = NSOpenPanel()
		picker.canChooseFiles = false
		picker.canChooseDirectories = true
		picker.allowsMultipleSelection = false
		picker.begin { response in
			guard response == .OK else { return }
			
			self.value = "\"\(picker.urls.map { $0.path }.joined(separator: "\" \""))\""
			self.field?.stringValue = self.value ?? ""
		}
	}

	private func addTextField(_ label: String, value: String = "", to contentView: NSView, prevValue: inout NSView?) -> NSTextField {
		let label1 = NSTextField(labelWithString: label)
		label1.alignment = .right
		let editField1 = NSTextField(string: value)
		contentView.pin(label: label1, value: editField1, prevValue: &prevValue, insets: prevValue == nil ? pinToTop : pinToPrevious)
		return editField1
	}
	
	private func addPathField(_ label: String, value: String = "", to contentView: NSView, prevValue: inout NSView?) -> (field: NSTextField, button: NSButton) {
		let label1 = NSTextField(labelWithString: label)
		label1.alignment = .right
		let editField1 = NSTextField(string: value)
		var insets = prevValue == nil ? pinToTop : pinToPrevious
		insets.right = dontPin
		contentView.pin(label: label1, value: editField1, prevValue: &prevValue, insets: insets)
		let chooseButton = NSButton(title: "Choose…", target: nil, action: nil)
		chooseButton.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(chooseButton)
		chooseButton.leadingAnchor.constraint(equalTo: editField1.trailingAnchor, constant: 8.0).isActive = true
		chooseButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.0).isActive = true
		chooseButton.firstBaselineAnchor.constraint(equalTo: editField1.firstBaselineAnchor).isActive = true
		chooseButton.target = self
		return (button: chooseButton, field: editField1)
	}
	
	private func addCheckBox(_ label: String, to contentView: NSView, prevValue: inout NSView?) -> NSButton {
		let label3 = NSView()
		let checkBox3 = NSButton(checkboxWithTitle: label, target: nil, action: nil)
		checkBox3.setContentHuggingPriority(NSLayoutConstraint.Priority(800), for: .vertical)
		contentView.pin(label: label3, value: checkBox3, prevValue: &prevValue, insets: prevValue == nil ? pinToTop : pinToPrevious)
		return checkBox3
	}

	private func isTextFieldType() -> Bool {
		return type == "text" || type == "file" || type == "files" || type == "directory" || type == "directories"
	}
	
	var commandString: String {
		var result = ""
		if active && (!isTextFieldType() || (value ?? "") != "") {
			if let name = name, !name.isEmpty {
				result.append(" \(name)")
			}
			if let value = value, !value.isEmpty {
				result.append(" \"\(value)\"")
			}
		}
		return result
	}
	
	@objc func doCheckboxClicked(_ sender: NSButton) {
		active = sender.state == .on
	}
}

class AppDelegate: NSObject, NSApplicationDelegate {
	let mainMenu = NSMenu(title: "Main Menu")
	var prevValue: NSView?
	var contentView: NSView!
	var panel: NSPanel!
	var lastMenu: NSMenu?
	var syntaxDescription = Options()

	override init() {
		NSApplication.shared.mainMenu = mainMenu
		
		super.init()

		var dataURL: URL?

		// Read -description argument
		if let jsonPath = UserDefaults.standard.string(forKey: "description") {
			dataURL = URL(fileURLWithPath: jsonPath)
		} else if let commandName = ProcessInfo.processInfo.arguments.last {
			let pathString = ProcessInfo.processInfo.environment["COMMANDO_PATH"]
			var paths: [String] = pathString?.split(separator: ":").map({ String($0) }) ?? []
			
			if paths.isEmpty {
				paths = ["/usr/local/etc/commando", "/etc/commando", "\(Bundle.main.executableURL!.deletingLastPathComponent().path)/descriptions"]
			}
			
			for path in paths {
				let url = URL(fileURLWithPath: path).appendingPathComponent("\(commandName).json")
				if FileManager.default.fileExists(atPath: url.path) {
					dataURL = url
					break
				}
			}
			
			if dataURL == nil {
				print("Couldn't find a description for command \(commandName).")
				exit(1)
			}
		} else {
			print("Missing command name or command -description argument.")
			exit(1)
		}

		NSApplication.shared.setActivationPolicy(.regular)
		
		createMenus()
		buildUIForDescription(dataURL!)
	}
	
	func buildUIForDescription(_ url: URL) {
		panel = NSPanel(contentRect: NSRect(x: 100, y: 100, width: 512, height: 342), styleMask: [.titled], backing: .buffered, defer: true)
		contentView = panel.contentView
		contentView.setContentHuggingPriority(NSLayoutConstraint.Priority(750.0), for: .vertical)
		contentView.setContentCompressionResistancePriority(NSLayoutConstraint.Priority(750.0), for: .horizontal)
		contentView.setContentCompressionResistancePriority(NSLayoutConstraint.Priority(750.0), for: .vertical)

		let decoder = JSONDecoder()
		syntaxDescription = try! decoder.decode(Options.self, from: Data(contentsOf: url))
	
		syntaxDescription.options.forEach { $0.create(in: self.contentView, prevValue: &self.prevValue) }
	
		let okButton = addButton("OK")
		okButton.target = self
		okButton.action = #selector(AppDelegate.doOK(_:))
		okButton.keyEquivalent = "\r"

		let cancelButton = addButton("Cancel")
		cancelButton.target = NSApplication.shared
		cancelButton.action = #selector(NSApplication.terminate(_:))
		cancelButton.keyEquivalent = "\u{1B}"
	}
	
	func createAppMenu() {
		let appMenu = addMenu("")
		_ = appMenu.addItem(withTitle: "About Commando", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
		_ = appMenu.addItem(NSMenuItem.separator())
		_ = appMenu.addItem(withTitle: "Preferences…", action: nil, keyEquivalent: "")
		_ = appMenu.addItem(NSMenuItem.separator())
		let servicesMenuItem = appMenu.addItem(withTitle: "Services", action: nil, keyEquivalent: "")
		let servicesMenu = NSMenu(title: "Services")
		NSApplication.shared.servicesMenu = servicesMenu
		servicesMenuItem.submenu = servicesMenu
		_ = appMenu.addItem(NSMenuItem.separator())
		_ = appMenu.addItem(withTitle: "Hide Commando", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
		let hideOthersItem = appMenu.addItem(withTitle: "Hide Others", action: #selector(NSApplication.hideOtherApplications(_:)), keyEquivalent: "h")
		hideOthersItem.keyEquivalentModifierMask = [.command, .option]
		_ = appMenu.addItem(withTitle: "Show All", action: #selector(NSApplication.unhideAllApplications(_:)), keyEquivalent: "")
		_ = appMenu.addItem(NSMenuItem.separator())
		_ = appMenu.addItem(withTitle: "Quit Commando", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
	}
	
	func createFileMenu() {
		let fileMenu = addMenu("File")
		_ = fileMenu.addItem(withTitle: "New", action: nil, keyEquivalent: "n")
		_ = fileMenu.addItem(NSMenuItem.separator())
		_ = fileMenu.addItem(withTitle: "Open…", action: nil, keyEquivalent: "o")
		let recentsMenuItem = fileMenu.addItem(withTitle: "Open Recent", action: nil, keyEquivalent: "")
		let recentsMenu = NSMenu(title: "Open Recent")
		_ = recentsMenu.addItem(withTitle: "Clear Menu", action: #selector(NSDocumentController.clearRecentDocuments(_:)), keyEquivalent: "o")
		recentsMenuItem.submenu = recentsMenu
		_ = fileMenu.addItem(NSMenuItem.separator())
		_ = fileMenu.addItem(withTitle: "Close Window", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
	}
	
	func createEditMenu() {
		let editMenu = addMenu("Edit")
		_ = editMenu.addItem(withTitle: "Undo", action: NSSelectorFromString("undo:"), keyEquivalent: "z")
		_ = editMenu.addItem(withTitle: "Redo", action: NSSelectorFromString("redo:"), keyEquivalent: "Z")
		_ = editMenu.addItem(NSMenuItem.separator())
		_ = editMenu.addItem(withTitle: "Cut", action: NSSelectorFromString("cut:"), keyEquivalent: "x")
		_ = editMenu.addItem(withTitle: "Copy", action: NSSelectorFromString("copy:"), keyEquivalent: "c")
		_ = editMenu.addItem(withTitle: "Paste", action: NSSelectorFromString("paste:"), keyEquivalent: "v")
		_ = editMenu.addItem(withTitle: "Clear", action: NSSelectorFromString("delete:"), keyEquivalent: "")
		_ = editMenu.addItem(NSMenuItem.separator())
		_ = editMenu.addItem(withTitle: "Select All", action: NSSelectorFromString("selectAll:"), keyEquivalent: "a")
	}

	func createHelpMenu() {
		let helpMenu = addMenu("Help")
		NSApplication.shared.helpMenu = helpMenu
		_ = helpMenu.addItem(withTitle: "Commando Help", action: NSSelectorFromString("showHelp:"), keyEquivalent: "?")
	}

	func createMenus() {
		createAppMenu()
		createFileMenu()
		createEditMenu()
		createHelpMenu()
	}
	
	func applicationDidFinishLaunching(_ notification: Notification) {
		panel.layoutIfNeeded()
		panel.center()
		panel.makeKeyAndOrderFront(self)
		
		NSApplication.shared.activate(ignoringOtherApps: true)
	}
	
	@objc func doOK(_ sender: AnyObject) {
		syntaxDescription.options.forEach { $0.readFromUI() }

		var command = syntaxDescription.command
		for option in syntaxDescription.options {
			command.append(option.commandString)
		}
		print(command)
		
		NSApplication.shared.terminate(self)
	}
}

extension AppDelegate {
	private func addMenu(_ title: String) -> NSMenu {
		let owningItem = mainMenu.addItem(withTitle: title, action: nil, keyEquivalent: "")
		let actualMenu = NSMenu(title: title)
		owningItem.submenu = actualMenu
		
		return actualMenu
	}
	
	func addButton(_ title: String) -> NSButton {
		let okButton = NSButton(title: title, target: nil, action: nil)
		contentView.pin(button: okButton, prevButton: &prevValue)
		return okButton
	}
}

var app = NSApplication.shared
var appDelegate = AppDelegate()
app.delegate = appDelegate

app.run()
