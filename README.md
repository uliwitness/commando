#  Commando

## What is it?

Commando is vaguely inspired by Apple MPW's Commando feature that let you build simple GUIs for your command line tools.

Commando is a command line tool that takes a syntax description file for a command line invocation, shows a window with controls for configuring these options, and then returns what settings were chosen in that GUI in a form that should make it easy to build the command line from it and call it.

## Usage

	commando <commandName>
	commando -description <commandDescriptionJsonFilePath>

Presents a UI for the given command and if the user presses the "OK" button prints the command line invocation that the specified choices in the UI correspond to to standard output.

**where**

* `commandName` - Name of a command to look up a command description for and display the corresponding UI. Command descriptions will be looked up in the paths specified in the `COMMANDO_PATH` environment variable. If that variable is not set, the default paths will be searched in the following order: `/usr/local/etc/commando/`, `/etc/commando/`, and a `descriptions` folder next to the commando binary itself.
* `commandDescriptionJsonFilePath` - Show a UI for whatever command is described in the given JSON file.

## License

	Copyright 2019 by Uli Kusterer.

	This software is provided 'as-is', without any express or implied
	warranty. In no event will the authors be held liable for any damages
	arising from the use of this software.

	Permission is granted to anyone to use this software for any purpose,
	including commercial applications, and to alter it and redistribute it
	freely, subject to the following restrictions:

	1. The origin of this software must not be misrepresented; you must not
	claim that you wrote the original software. If you use this software
	in a product, an acknowledgment in the product documentation would be
	appreciated but is not required.

	2. Altered source versions must be plainly marked as such, and must not be
	misrepresented as being the original software.

	3. This notice may not be removed or altered from any source
	distribution.
