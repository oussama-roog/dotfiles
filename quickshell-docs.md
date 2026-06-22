### Install Quickshell on Guix

Source: https://quickshell.org/docs/v0.3.0/guide/install-setup

Install Quickshell from the standard Guix repository using the `guix install` command.

```bash
guix install quickshell
```

--------------------------------

### Install Quickshell on Gentoo using GURU overlay

Source: https://quickshell.org/docs/v0.3.0/guide/install-setup

Add the GURU overlay to your Gentoo system and install Quickshell from the `gui-apps/quickshell` package.

```bash
# Add GURU overlay
emerge eselect-repository
eselect repository enable guru
emerge --sync guru

emerge gui-apps/quickshell
```

--------------------------------

### PopupWindow Usage Example

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/PopupWindow

This example demonstrates how to create and configure a PopupWindow, anchoring it to a parent panel and centering it.

```APIDOC
## PopupWindow

Popup window that can display in a position relative to a floating or panel window.

### Example
```
PanelWindow {
  id: toplevel

  anchors {
    bottom: true
    left: true
    right: true
  }

  PopupWindow {
    anchor.window: toplevel
    anchor.rect.x: parentWindow.width / 2 - width / 2
    anchor.rect.y: parentWindow.height
    width: 500
    height: 500
    visible: true
  }
}
```

## Properties

### `parentWindow`
- **Type**: QtObject
- **Description**: The parent window of this popup. Changing this property reparents the popup. (Deprecated in favor of `anchor.window`)

### `relativeY`
- **Type**: int
- **Description**: The Y position of the popup relative to the parent window. (Deprecated in favor of `anchor.rect.y`)

### `screen`
- **Type**: ShellScreen (readonly)
- **Description**: The screen that the window currently occupies. This may be modified to move the window to the given screen.

### `visible`
- **Type**: bool
- **Description**: If the window is shown or hidden. Defaults to false. The popup will not be shown until `anchor` is valid, regardless of this property.

### `grabFocus`
- **Type**: bool
- **Description**: If true, the popup window will be dismissed and `grabFocus` will change to false if the user clicks outside of the popup or it is otherwise closed. Changes to this property while the window is open will only take effect after the window is hidden and shown again. Under Hyprland, HyprlandFocusGrab provides more advanced functionality such as detecting clicks outside without closing the popup.

### `relativeX`
- **Type**: int
- **Description**: The X position of the popup relative to the parent window. (Deprecated in favor of `anchor.rect.x`)

### `anchor`
- **Type**: PopupAnchor (readonly)
- **Description**: The popup’s anchor / positioner relative to another item or window. The popup will not be shown until it has a valid anchor relative to a window and `visible` is true. You can set properties of the anchor like so:
```
PopupWindow {
  anchor.window: parentwindow
  // or
  anchor {
    window: parentwindow
  }
}
```
```

--------------------------------

### Install Quickshell on Debian

Source: https://quickshell.org/docs/v0.3.0/guide/install-setup

Install Quickshell from the Debian unstable or testing repositories using apt.

```bash
sudo apt install quickshell
```

--------------------------------

### Install Quickshell on Fedora

Source: https://quickshell.org/docs/v0.3.0/guide/install-setup

Install the release version of Quickshell on Fedora using the dnf package manager.

```bash
sudo dnf install quickshell
```

--------------------------------

### QML Import Examples

Source: https://quickshell.org/docs/v0.3.0/guide/qml-language

Provides concrete examples of different QML import statements, including module imports, versioned imports, and aliased imports.

```qml
import QtQuick
import QtQuick.Controls 6.0
import Quickshell as QS
import QtQuick.Layouts 6.0 as L
import "jsfile.js" as JsFile
```

--------------------------------

### I3IpcListener Example

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.I3/I3IpcListener

This example demonstrates how to create an I3IpcListener, subscribe to 'input' events, and handle incoming IPC events by calling a function with the event data.

```javascript
I3IpcListener {
  subscriptions: ["input"]
  onIpcEvent: function (event) {
    handleInputEvent(event.data)
  }
}
```

--------------------------------

### Install Quickshell on Arch Linux

Source: https://quickshell.org/docs/v0.3.0/guide/install-setup

Install the release version of Quickshell from the Arch Linux package repository using pacman.

```bash
pacman -S quickshell
```

--------------------------------

### Implicit QML Import Example

Source: https://quickshell.org/docs/v0.3.0/guide/qml-language

Shows how QML automatically imports types from neighboring files if their names start with an uppercase letter.

```qml
root
+|-MyButton.qml
+|-shell.qml
```

--------------------------------

### Create a Basic Panel Window

Source: https://quickshell.org/docs/v0.3.0/guide/introduction

Use PanelWindow to create a simple bar or widget. This example displays 'hello world' in the center of the panel.

```QML
import Quickshell // for PanelWindow
import QtQuick // for Text

PanelWindow {
  anchors {
    top: true
    left: true
    right: true
  }

  implicitHeight: 30

  Text {
    // center the bar in its parent component (the window)
    anchors.centerIn: parent

    text: "hello world"
  }
}
```

--------------------------------

### Install Quickshell on Ubuntu using DankLinux PPA

Source: https://quickshell.org/docs/v0.3.0/guide/install-setup

Add the DankLinux PPA to your Ubuntu system and install either the latest release (`quickshell`) or the master branch (`quickshell-git`) version of Quickshell.

```bash
# Add DankLinux PPA
sudo add-apt-repository ppa:avengemedia/danklinux
sudo apt update

sudo apt install quickshell
# OR
sudo apt install quickshell-git
```

--------------------------------

### Hyprland Keybind Configuration

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Hyprland/GlobalShortcut

Example of how to bind a global shortcut in Hyprland's configuration file.

```APIDOC
## Hyprland Keybind Configuration Example

Use the following format in your Hyprland configuration file to bind a global shortcut:

```
bind = <modifiers>, <key>, global, <appid>:<name>
```

**Example:**

```
bind = SUPER, P, global, myapp:my_shortcut_name
```
```

--------------------------------

### Install Quickshell-git on Arch Linux (AUR)

Source: https://quickshell.org/docs/v0.3.0/guide/install-setup

Install the development version of Quickshell from the AUR using an AUR helper like yay. Be aware that AUR packages may break with Qt updates.

```bash
yay -S quickshell-git
```

--------------------------------

### QML Document Structure Example

Source: https://quickshell.org/docs/v0.3.0/guide/qml-language

Illustrates the basic structure of a QML document, including imports, object declarations, properties, bindings, signals, and functions.

```qml
// QML Import statement
import QtQuick 6.0

// Javascript import statement
import "myjs.js" as MyJs

// Root Object
Item {
  // Id assignment

  id: root
  // Property declaration
  property int myProp: 5;

  // Property binding
  width: 100

  // Property binding
  height: width

  // Multiline property binding
  prop: {
    // ...
    5
  }

  // Object assigned to a property
  objProp: Object {
    // ...
  }

  // Object assigned to the parent's default property
  AnotherObject {
    // ...
  }

  // Signal declaration
  signal foo(bar: int)

  // Signal handler
  onSignal: console.log("received signal!")

  // Property change signal handler
  onWidthChanged: console.log(`width is now ${width}!
`)

  // Multiline signal handler
  onOtherSignal: {
    console.log("received other signal!");
    console.log(`5 * 2 is ${dub(5)}`);
    // ...
  }

  // Attached property signal handler
  Component.onCompleted: MyJs.myfunction()

  // Function
  function dub(x: int): int {
    return x * 2
  }

  // Inline component
  component MyComponent: Object {
    // ...
  }
}
```

--------------------------------

### Nested Regions Example

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/Region

Demonstrates how to create a nested region for complex shapes, including a cutout using the Intersection.Subtract mode.

```Quickshell
Region {
  width: 100; height: 100;

  Region {
    x: 50; y: 50;
    width: 50; height: 50;
    intersection: Intersection.Subtract
  }
}
```

--------------------------------

### Load Component with Properties and Signal Handlers using BoundComponent

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/BoundComponent

This example demonstrates how to use BoundComponent to load a component from a source URL. It shows how to set initial properties ('color') and define signal handlers ('onClicked') that will be applied to the loaded component. This is useful for managing component initialization and dependencies.

```qml
BoundComponent {
  source: "MyComponent.qml"

  // this is the same as assigning to `color` on MyComponent if loaded normally.
  property color color: "red";

  // this will be triggered when the `clicked` signal from the MouseArea is sent.
  function onClicked() {
    color = "blue";
  }
}
```

--------------------------------

### Neovim Configuration for QML Language Server

Source: https://quickshell.org/docs/v0.3.0/guide/install-setup

Set up the qmlls language server in Neovim using nvim-lspconfig. Ensure tree-sitter highlighting is installed for QML.

```lua
require("lspconfig").qmlls.setup {}
```

--------------------------------

### Basic Process Execution

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/Process

Starts a process with a command and captures its standard output. The `onStreamFinished` signal can be used to process output as it becomes available.

```javascript
Process {
  running: true
  command: [ "some-command", "arg" ]
  stdout: StdioCollector {
    onStreamFinished: console.log(`line read: ${this.text}`)
  }
}
```

--------------------------------

### Process Object Configuration

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/Process

Example of how to configure a Process object, including setting the command to run, enabling stdout collection, and defining behavior when the process state changes.

```APIDOC
## Process: QtObject 
`import Quickshell.Io`
#### Example
```
Process {
  running: true
  command: [ "some-command", "arg" ]
  stdout: StdioCollector {
    onStreamFinished: console.log(`line read: ${this.text}`)
  }
}
```
```

--------------------------------

### QML Lambda Callback Example

Source: https://quickshell.org/docs/v0.3.0/guide/qml-language

This example demonstrates an overcomplicated click counter using a lambda callback passed to a function, updating a label with the click count.

```qml
ColumnLayout {
  property int clicks: 0

  function incrementAndCall(callback) {
    clicks += 1;
    callback(clicks);
  }

  Button {
    text: "click me"
    onClicked: incrementAndCall(clicks => {
        label.text = `the button was clicked ${clicks} time(s)!`;
    })
  }

  Text {
    id: label
    text: "the button has not been clicked"
  }
}
```

--------------------------------

### SocketServer Configuration Example

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/SocketServer

Configure a SocketServer with a specific path and a handler that logs connection changes and messages. The handler uses a SplitParser to process incoming data.

```javascript
SocketServer {
  active: true
  path: "/path/too/socket.sock"
  handler: Socket {
    onConnectedChanged: {
      console.log(connected ? "new connection!" : "connection dropped!")
    }
    parser: SplitParser {
      onRead: message => console.log(`read message from socket: ${message}`)
    }
  }
}
```

--------------------------------

### Container Item with Anchors

Source: https://quickshell.org/docs/v0.3.0/guide/size-position

This example demonstrates reducing boilerplate code by using QtQuick Anchors to achieve common position and size bindings. It is equivalent to the first example but uses anchors for positioning and sizing.

```javascript
Item {
  property real margin: 5

  implicitWidth: child.implicitWidth + margin * 2
  implicitHeight: child.implicitHeight + margin * 2

  Rectangle {
    id: child

    // "Fill" the space occupied by the parent, setting width
    anchors.fill: parent
    // Add a margin to all anchored sides.
    anchors.margins: parent.margin

    implicitWidth: 50
    implicitHeight: 50
  }
}
```

--------------------------------

### QML Property Binding Examples

Source: https://quickshell.org/docs/v0.3.0/guide/qml-language

Demonstrates various ways to bind properties in QML, including simple expressions, complex calculations, and multi-line expressions with or without explicit return statements.

```qml
Item {
  // simple expression
  property: 5

  // complex expression
  property: 5 * 20 + this.otherProperty

  // multiline expression
  property: {
    const foo = 5;
    const bar = 10;
    foo * bar
  }

  // multiline expression with return
  property: {
    // ...
    return 5;
  }
}
```

--------------------------------

### Enable Fedora COPR and Install Quickshell

Source: https://quickshell.org/docs/v0.3.0/guide/install-setup

Enable the errornointernet/quickshell COPR repository on Fedora to install either the latest release (`quickshell`) or the master branch (`quickshell-git`) versions.

```bash
sudo dnf copr enable errornointernet/quickshell

sudo dnf install quickshell
# or
sudo dnf install quickshell-git
```

--------------------------------

### Define IpcHandler for a Rectangle

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/IpcHandler

This example demonstrates how to create an IpcHandler for a Rectangle object, exposing functions to set and get its color, angle, and radius, as well as a signal for radius changes. Ensure all function signatures and signal definitions include explicit types.

```javascript
FloatingWindow {
  Rectangle {
    id: rect
    anchors.centerIn: parent
    width: 100
    height: 100
    color: "red"
  }

  IpcHandler {
    target: "rect"

    function setColor(color: color): void { rect.color = color; }
    function getColor(): color { return rect.color; }

    function setAngle(angle: real): void { rect.rotation = angle; }
    function getAngle(): real { return rect.rotation; }

    function setRadius(radius: int): void {
      rect.radius = radius;
      this.radiusChanged(radius);
    }

    function getRadius(): int { return rect.radius; }

		signal radiusChanged(newRadius: int);
  }
}
```

--------------------------------

### Start a Detached Process

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/Process

Launches a new instance of the process detached from Quickshell. The subprocess will not be tracked or killed by Quickshell.

```javascript
process.startDetached();
```

--------------------------------

### RetainableLock Usage Example

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/RetainableLock

This example demonstrates how to use RetainableLock to keep a retainable object alive for the duration of the lock.

```APIDOC
## RetainableLock

### Description
A RetainableLock provides extra safety and ease of use for locking Retainable objects. A retainable object can be locked by multiple locks at once, and each lock re-exposes relevant properties of the retained objects.

### Properties
* **object** (QtObject) - The object to lock. Must be Retainable.
* **locked** (bool) - If the object should be locked.
* **retained** (bool, readonly) - If the object is currently in a retained state.

### Signals
* **aboutToDestroy** ()
* **dropped** ()

### Example
The code below will keep a retainable object alive for as long as the RetainableLock exists.
```
RetainableLock {
  object: aRetainableObject
  locked: true
}
```
```

--------------------------------

### Asynchronous Popup Window Loading with LazyLoader

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/LazyLoader

This example demonstrates how to use LazyLoader to asynchronously load a PopupWindow. The popup is prepared in the background, allowing the main bar to display immediately. Accessing the popup's item before it's fully loaded will block the UI thread.

```QML
import QtQuick
import QtQuick.Controls
import Quickshell

ShellRoot {
  PanelWindow {
    id: window
    height: 50

    anchors {
      bottom: true
      left: true
      right: true
    }

    LazyLoader {
      id: popupLoader

      // start loading immediately
      loading: true

      // this window will be loaded in the background during spare
      // frame time unless active is set to true, where it will be
      // loaded in the foreground
      PopupWindow {
        // position the popup above the button
        parentWindow: window
        relativeX: window.width / 2 - width / 2
        relativeY: -height

        // some heavy component here

        width: 200
        height: 200
      }
    }

    Button {
      anchors.centerIn: parent
      text: "show popup"

      // accessing popupLoader.item will force the loader to
      // finish loading on the UI thread if it isn't finished yet.
      onClicked: popupLoader.item.visible = !popupLoader.item.visible
    }
  }
}
```

--------------------------------

### play

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Mpris/MprisPlayer

Resumes or starts media playback. This is equivalent to setting the player's playback status to 'Playing'.

```APIDOC
## play

### Description
Resume or start media playback.
Equivalent to setting the playback status to `Playing`.

### Signature
`play () : void`
```

--------------------------------

### Quickshell Scope Example

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/Scope

Demonstrates the structure of a Quickshell Scope within Variants. All elements defined inside this Scope will inherit its reload behavior.

```javascript
ShellRoot {
  Variants {
    variants: ...

    Scope {
      // everything in here behaves the same as if it was defined
      // directly in `Variants` reload-wise.
    }
  }
}
```

--------------------------------

### Bind Global Shortcut in Hyprland

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Hyprland/GlobalShortcut

Example of how to bind a global shortcut in Hyprland's configuration file. This format is used to associate a key combination with a specific application ID and shortcut name.

```bash
bind = <modifiers>, <key>, global, <appid>:<name>
```

--------------------------------

### Example: Using Default Property

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Widgets/WrapperManager

Demonstrates how to set the visual child using the default property of a WrapperWidget. This is suitable when the child is the primary item within the widget.

```javascript
WrapperWidget { // a widget that uses WrapperManager
  // Putting the item inline uses the default property of WrapperWidget.
  Text { text: "Hello" }

  // Scope does not extend Item, so it can be placed in the
  // default property without issue.
  Scope {}
}
```

--------------------------------

### Update Process Output at an Interval

Source: https://quickshell.org/docs/v0.3.0/guide/introduction

Use a Timer to repeatedly trigger a Process, ensuring dynamic content updates. This example creates a clock that updates every second.

```QML
import Quickshell
import Quickshell.Io
import QtQuick

PanelWindow {
  anchors {
    top: true
    left: true
    right: true
  }

  implicitHeight: 30

  Text {
    id: clock
    anchors.centerIn: parent

    Process {
      // give the process object an id so we can talk
      // about it from the timer
      id: dateProc

      command: ["date"]
      running: true

      stdout: StdioCollector {
        onStreamFinished: clock.text = this.text
      }
    }

    // use a timer to rerun the process at an interval
    Timer {
      // 1000 milliseconds is 1 second
      interval: 1000

      // start the timer immediately
      running: true

      // run the timer again when it ends
      repeat: true

      // when the timer is triggered, set the running property of the
      // process to true, which reruns it if stopped.
      onTriggered: dateProc.running = true
    }
  }
}
```

--------------------------------

### ColorQuantizer Configuration Example

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/ColorQuantizer

Configure the ColorQuantizer to process an image. Set the source image path, quantization depth, and optionally rescale the image for faster processing. The depth determines the number of colors produced (2^depth).

```javascript
ColorQuantizer {
  id: colorQuantizer
  source: Qt.resolvedUrl("./yourImage.png")
  depth: 3 // Will produce 8 colors (2³)
  rescaleSize: 64 // Rescale to 64x64 for faster processing
}
```

--------------------------------

### Example: Implementing Custom Wrapper Type

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Widgets/WrapperManager

Illustrates how to create a custom wrapper component using WrapperManager. It involves creating a WrapperManager instance and aliasing its 'child' property.

```javascript
Item { // your wrapper component
  WrapperManager { id: wrapperManager }

  // Allows consumers of your wrapper component to use the child property.
  property alias child: wrapperManager.child

  // The rest of your component logic. You can use
  // `wrapperManager.child` or `this.child` to refer to the selected child.
}
```

--------------------------------

### HyprlandFocusGrab Example

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Hyprland/HyprlandFocusGrab

Demonstrates how to use HyprlandFocusGrab to take and remove exclusive focus from a window. The button's text dynamically updates to reflect the grab's active state.

```qml
import Quickshell
import Quickshell.Hyprland
import QtQuick.Controls

ShellRoot {
  FloatingWindow {
    id: window

    Button {
      anchors.centerIn: parent
      text: grab.active ? "Remove exclusive focus" : "Take exclusive focus"
      onClicked: grab.active = !grab.active
    }

    HyprlandFocusGrab {
      id: grab
      windows: [ window ]
    }
  }
}
```

--------------------------------

### QML Property Access Scope Examples

Source: https://quickshell.org/docs/v0.3.0/guide/qml-language

Illustrates property access rules in QML, showing how to access properties of the current object, the root object, and other objects using their `id` or `parent` properties. It also points out illegal access attempts.

```qml
Item {
  property string rootDefinition

  Item {
    id: mid
    property string midDefinition

    Text {
      property string innerDefinition

      // legal - innerDefinition is defined on the current object
      text: innerDefinition

      // legal - innerDefinition is accessed via `this` to refer to the current object
      text: this.innerDefinition

      // legal - width is defined for Text
      text: width

      // legal - rootDefinition is defined on the root object
      text: rootDefinition

      // illegal - midDefinition is not defined on the root or current object
      text: midDefinition

      // legal - midDefinition is accessed via `mid`'s id.
      text: mid.midDefinition

      // legal - midDefinition is accessed via `parent`
      text: parent.midDefinition
    }
  }
}
```

--------------------------------

### Set PopupWindow Anchor Window

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/PopupWindow

This example shows how to set the anchor window for a PopupWindow. You can either use dot notation or a block to define the anchor properties.

```javascript
PopupWindow {
  anchor.window: parentwindow
  // or
  anchor {
    window: parentwindow
  }
}
```

--------------------------------

### Setting a Clickthrough Mask with Region

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/QsWindow

This example demonstrates how to set a clickthrough mask for a ShellWindow using a Region. Clicks outside the specified 'rect' item will pass through to windows behind it.

```javascript
ShellWindow {
  // The mask region is set to `rect`, meaning only `rect` is clickable.
  // All other clicks pass through the window to ones behind it.
  mask: Region { item: rect }

  Rectangle {
    id: rect

    anchors.centerIn: parent
    width: 100
    height: 100
  }
}
```

--------------------------------

### Icon Path Retrieval

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/Quickshell

Functions to get the system path for icons, with options for checking existence and providing fallbacks.

```APIDOC
## iconPath (icon)

### Description
Returns a string usable for a for a given system icon. By default, icons are loaded from the theme selected by the qt platform theme, which means they should match with all other qt applications on your system. If you want to use a different icon theme, you can put `//@ pragma IconTheme <name>` at the top of your root config file or set the `QS_ICON_THEME` variable to the name of your icon theme.

### Parameters
#### Path Parameters
- **icon** (string) - Required - The name of the icon.

### Return Value
string - The system path to the icon.
```

```APIDOC
## iconPath (icon, check)

### Description
Setting the `check` parameter of `iconPath` to true will return an empty string if the icon does not exist, instead of an image showing a missing texture.

### Parameters
#### Path Parameters
- **icon** (string) - Required - The name of the icon.
- **check** (bool) - Required - If true, return an empty string if the icon does not exist.

### Return Value
string - The system path to the icon, or an empty string if `check` is true and the icon is not found.
```

```APIDOC
## iconPath (icon, fallback)

### Description
Setting the `fallback` parameter of `iconPath` will attempt to load the fallback icon if the requested one could not be loaded.

### Parameters
#### Path Parameters
- **icon** (string) - Required - The name of the icon.
- **fallback** (string) - Required - The name of the fallback icon.

### Return Value
string - The system path to the icon, or the fallback icon's path if the requested icon could not be loaded.
```

--------------------------------

### Example: Using Explicit Child Property

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Widgets/WrapperManager

Shows how to specify the visual child using the 'child' property when a widget has multiple Item-based children. This is necessary to resolve ambiguity.

```javascript
WrapperWidget {
  Text {
    id: text
    text: "Hello"
  }

  Text {
    id: otherText
    text: "Other Text"
  }

  // Both text and otherText extend Item, so one must be specified.
  child: text
}
```

--------------------------------

### Generated JSON from JsonAdapter

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/JsonAdapter

This JSON structure represents the data managed by the JsonAdapter example, showing how QML properties map to JSON keys and values.

```json
{
   "myStringProperty": "default value",
   "stringList": [
     "default",
     "value"
   ],
   "subObject": {
     "subObjectProperty": "default value"
   },
   "inlineJson": {
     "a": "b"
   }
}
```

--------------------------------

### Getting Icon Path with Fallback

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/Quickshell

Retrieve a system icon path using `iconPath`, providing a fallback icon name if the primary icon cannot be loaded.

```javascript
Quickshell.iconPath("icon-name", "fallback-icon-name");
```

--------------------------------

### Emacs Configuration for QML Language Server

Source: https://quickshell.org/docs/v0.3.0/guide/install-setup

Configure Emacs to use the qml-ts-mode and qmlls language server. Ensure lsp-mode is installed and qmlls is available in your PATH.

```emacs-lisp
(use-package qml-ts-mode
  :after lsp-mode
  :config
  (add-to-list 'lsp-language-id-configuration '(qml-ts-mode . "qml-ts"))
  (lsp-register-client
   (make-lsp-client :new-connection (lsp-stdio-connection '("qmlls"))
                    :activation-fn (lsp-activate-on "qml-ts")
                    :server-id 'qmlls))
  (add-hook 'qml-ts-mode-hook (lambda () 
                                (setq-local electric-indent-chars '(?\n ?\( ?\) ?{ ?} ?\[ ?\] ?; ?,))
                                (lsp-deferred))))
```

--------------------------------

### FileView Example: Reading a JSON as text

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/FileView

Demonstrates how to use FileView to read a JSON file and parse its content as text. The `blockLoading` property is set to true to ensure the file is fully loaded before parsing.

```APIDOC
## FileView: QtObject 
`import Quickshell.Io`
A reader for small to medium files that don’t need seeking/cursor access, suitable for most text files.
#### Example: Reading a JSON as text
```
FileView {
  id: jsonFile
  path: Qt.resolvedUrl("./your.json")
  // Forces the file to be loaded by the time we call JSON.parse().
  // see blockLoading's property documentation for details.
  blockLoading: true
}

readonly property var jsonData: JSON.parse(jsonFile.text())
```

Also see JsonAdapter for an alternative way to handle reading and writing JSON files.
```

--------------------------------

### Inverting a Clickthrough Mask with Intersection.Xor

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/QsWindow

This example shows how to invert the clickthrough mask of a ShellWindow by setting the intersection mode to 'Xor'. Clicks within the 'rect' item will now pass through to windows behind it.

```javascript
ShellWindow {
  // The mask region is set to `rect`, but the intersection mode is set to `Xor`.
  // This inverts the mask causing all clicks inside `rect` to be passed to the window
  // behind this one.
  mask: Region { item: rect; intersection: Intersection.Xor }

  Rectangle {
    id: rect

    anchors.centerIn: parent
    width: 100
    height: 100
  }
}
```

--------------------------------

### Reusable Container with Binding

Source: https://quickshell.org/docs/v0.3.0/guide/size-position

This example shows how to create a reusable container component using `Binding` to control the child item's actual size and position. It sets the item's visual children list to the passed item.

```javascript
Item {
  id: wrapper
  property real margin: 5
  required default property Item child

  // Set the item's visual children list to just the passed item.
  children: [child]

  implicitWidth: child.implicitWidth + margin * 2
  implicitHeight: child.implicitHeight + margin * 2

  // Bind the child's position and size.
  // Note that this syntax is exclusive to the Binding type.
  Binding { wrapper.child.x: wrapper.margin }
  Binding { wrapper.child.y: wrapper.margin }
  Binding { wrapper.child.width: wrapper.width - wrapper.margin * 2 }
  Binding { wrapper.child.height: wrapper.height - wrapper.margin * 2 }
}
```

--------------------------------

### Create and Control a Wayland Session Lock

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Wayland/WlSessionLock

This example demonstrates how to create a WlSessionLock with a button to unlock the screen. The lock is activated by setting `lock.locked = true` after the component is defined. If the lock is destroyed or the application exits without unlocking, the screen remains locked.

```javascript
WlSessionLock {
  id: lock

  WlSessionLockSurface {
    Button {
      text: "unlock me"
      onClicked: lock.locked = false
    }
  }
}

// ...
lock.locked = true
```

--------------------------------

### IpcHandler Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/IpcHandler

This section describes the properties available on an IpcHandler that can be read using `qs ipc prop get`.

```APIDOC
## IpcHandler Properties

Properties of an `IpcHandler` can be read using `qs ipc prop get` if they are of an IPC-compatible type.

### Properties

- **enabled** (`bool`): Determines if the handler can receive calls. Defaults to `true`.
- **target** (`string`): The unique identifier for this handler, making it accessible. This property is required and can be changed at runtime.
```

--------------------------------

### Avoid Binding Loops with childrenRect

Source: https://quickshell.org/docs/v0.3.0/guide/size-position

This example demonstrates a common mistake where `childrenRect.width` and `childrenRect.height` are used to set implicit sizes, leading to binding loops. Avoid using `childrenRect` for implicit size calculations.

```qml
Item {
  implicitWidth: childrenRect.width
  implicitHeight: childrenRect.height

  Rectangle {
    anchors.fill: parent

    implicitWidth: 50
    implicitHeight: 50
  }
}
```

--------------------------------

### Create Window Instance on Every Screen

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/Quickshell

This snippet demonstrates how to create an instance of a window on each connected screen. The window will be created or destroyed as screens are added or removed.

```qml
ShellRoot {
  Variants {
    // see Variants for details
    variants: Quickshell.screens
    PanelWindow {
      property var modelData
      screen: modelData
    }
  }
}
```

--------------------------------

### Getting Icon Path

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/Quickshell

Retrieve a system icon path using `iconPath`. The `check` parameter can be set to true to return an empty string if the icon does not exist.

```javascript
Quickshell.iconPath("icon-name", true);
```

--------------------------------

### Handle CheckBox State Changes

Source: https://quickshell.org/docs/v0.3.0/guide/qml-language

Use the `on<PropertyName>Changed` signal handler to react to property changes. This example demonstrates handling the `checkStateChanged` signal of a CheckBox.

```QML
ColumnLayout {
  CheckBox {
    text: "check me"

    onCheckStateChanged: {
      label.text = labelText(checkState == Qt.Checked);
    }
  }

  Text {
    id: label
    text: labelText(false)
  }

  function labelText(checked): string {
    return `the checkbox is checked: ${checked}`;
  }
}
```

--------------------------------

### Dynamically Set WlrLayershell Layer in PanelWindow

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Wayland/WlrLayershell

Dynamically set WlrLayershell specific properties for platform compatibility. This example shows how to set the layer after the PanelWindow component has completed.

```qml
PanelWindow {
  Component.onCompleted: {
    if (this.WlrLayershell != null) {
      this.WlrLayershell.layer = WlrLayer.Bottom;
    }
  }
}
```

--------------------------------

### Reusable MarginWrapperManager Component

Source: https://quickshell.org/docs/v0.3.0/guide/size-position

This example illustrates creating a reusable component using `MarginWrapperManager`. It exposes `margin` and `child` properties for external access and customization, while `MarginWrapperManager` handles the internal size and position logic.

```qml
Item {
  // A bidirectional binding to manager.margin,
  // where the default value is set.
  property alias margin: manager.margin

  // MarginWrapperManager tries to automatically detect
  // the primary child of the container, but exposing the
  // child property allows us to both access the child
  // externally and override it if automatic detection fails.
  property alias child: manager.margin

  // MarginWrapperManager automatically manages the implicit size
  // of the container and actual size of the child.
  MarginWrapperManager {
    id: manager
    margin: 5 // the default value of margin
  }
}
```

--------------------------------

### Getting Environment Variable

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/Quickshell

Retrieve the string value of an environment variable using `env`. Returns null if the variable is not set.

```javascript
Quickshell.env("VARIABLE_NAME");
```

--------------------------------

### Container Item with Margin

Source: https://quickshell.org/docs/v0.3.0/guide/size-position

This example demonstrates a container item that adds a margin to its child rectangle, managing its implicit and actual size accordingly. It ensures proper interaction with other container types.

```javascript
Item {
  property real margin: 5

  // Set the implicit size of the containing item to the size of
  // the contained item, plus the margin on each side.
  implicitWidth: child.implicitWidth + margin * 2
  implicitHeight: child.implicitHeight + margin * 2

  Rectangle {
    id: child

    // Set the size of the child item relative to the actual size
    // of the parent item. If the parent item is constrained
    // or stretched the child's position and size will be similarly
    // constrained.
    x: parent.margin
    y: parent.margin
    width: parent.width - parent.margin * 2
    height: parent.height - parent.margin * 2

    // The child's implicit / desired size, which will be respected
    // by the container item as long as it is not constrained
    // or stretched.
    implicitWidth: 50
    implicitHeight: 50
  }
}
```

--------------------------------

### QML Module Import Syntax

Source: https://quickshell.org/docs/v0.3.0/guide/qml-language

Demonstrates various ways to import QML modules, including versioned modules, relative paths, Quickshell modules, and JavaScript files.

```qml
import <Module> [Major.Minor] [as <Namespace>]
```

```qml
import "<directory>" [as <Namespace>]
```

```qml
import qs.<path> [as <Namespace>]
```

```qml
import "<filename>" as <Namespace>
```

--------------------------------

### Using reloadableId for State Preservation

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/Reloadable

This example demonstrates how to use `reloadableId` within a `Variants` structure to ensure that a `FloatingWindow` maintains its state across different configuration revisions. The identifier helps the reloader match the object in the previous widget tree to the current one.

```javascript
Variants {
  // multiple variants of the same object tree
  variants: [ { foo: 1 }, { foo: 2 } ]

  // any non `Reloadable` object
  QtObject {
    FloatingWindow {
      // this FloatingWindow will now be matched to the same one in the previous
      // widget tree for its variant. "myFloatingWindow" refers to both the variant in
      // `foo: 1` and `foo: 2` for each tree.
      reloadableId: "myFloatingWindow"

      // ...
    }
  }
}
```

--------------------------------

### Concise CheckBox State Binding

Source: https://quickshell.org/docs/v0.3.0/guide/qml-language

Bind a property directly to another property's value for concise reactive updates. This example binds the Text's content to the CheckBox's state without an explicit signal handler.

```QML
ColumnLayout {
  CheckBox {
    id: checkbox
    text: "check me"
  }

  Text {
    id: label
    text: labelText(checkbox.checkState == Qt.Checked)
  }

  function labelText(checked): string {
    return `the checkbox is checked: ${checked}`;
  }
}
```

--------------------------------

### Switching to QApplication for QtWidgets Support

Source: https://quickshell.org/docs/v0.3.0/guide/advanced

Use the UseQApplication pragma to switch Quickshell's default QGuiApplication to a QApplication. This enables the use of QtWidgets controls and styles like qqc2-desktop-style.

```qml
//@ pragma UseQApplication
```

--------------------------------

### Run a Process and Display Output

Source: https://quickshell.org/docs/v0.3.0/guide/introduction

Utilize the Process object to execute commands and StdioCollector to capture their output. The Text element updates when the process finishes.

```QML
import Quickshell
import Quickshell.Io // for Process
import QtQuick

PanelWindow {
  anchors {
    top: true
    left: true
    right: true
  }

  implicitHeight: 30

  Text {
    // give the text an ID we can refer to elsewhere in the file
    id: clock

    anchors.centerIn: parent

    // create a process management object
    Process {
      // the command it will run, every argument is its own string
      command: ["date"]

      // run the command immediately
      running: true

      // process the stdout stream using a StdioCollector
      // Use StdioCollector to retrieve the text the process sends
      // to stdout.
      stdout: StdioCollector {
        // Listen for the streamFinished signal, which is sent
        // when the process closes stdout or exits.
        onStreamFinished: clock.text = this.text // `this` can be omitted
      }
    }
  }
}
```

--------------------------------

### Inline Expression Binding

Source: https://quickshell.org/docs/v0.3.0/guide/qml-language

Embed JavaScript expressions directly within property assignments for dynamic updates. This example uses an inline block to determine the text content based on a checkbox's state.

```QML
ColumnLayout {
  CheckBox {
    id: checkbox
    text: "check me"
  }

  Text {
    id: label
    text: {
      const checked = checkbox.checkState == Qt.Checked;
      return `the checkbox is checked: ${checked}`;
    }
  }
}
```

--------------------------------

### ColorQuantizer Initialization and Usage

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/ColorQuantizer

Demonstrates how to initialize and use the ColorQuantizer to extract colors from an image. You can set the source image, the depth of color quantization (which determines the number of colors), and a rescale size for faster processing.

```APIDOC
## ColorQuantizer

### Description
A color quantization utility used for getting prevalent colors in an image, by averaging out the image’s color data recursively.

### Properties
*   **depth** (real) - Max depth for the color quantization. Each level of depth represents another binary split of the color space. Determines the number of colors (2^depth).
*   **imageRect** (rect) - Rectangle that the source image is cropped to. Can be set to `undefined` to reset.
*   **source** (unknown) - Path to the image you’d like to run the color quantization on.
*   **rescaleSize** (real) - The size to rescale the image to. If 0, no scaling is performed. Recommended for performance.

### Readonly Properties
*   **colors** (list<color>) - Access the colors resulting from the color quantization performed. The amount of colors returned is 2^depth.

### Example
```
ColorQuantizer {
  id: colorQuantizer
  source: Qt.resolvedUrl("./yourImage.png")
  depth: 3 // Will produce 8 colors (2³)
  rescaleSize: 64 // Rescale to 64x64 for faster processing
}
```
```

--------------------------------

### Constructing State Path

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/Quickshell

Construct a path within the Quickshell state directory using `statePath`.

```javascript
Quickshell.statePath("my_state_file.json");
```

--------------------------------

### Manual Binding with Qt.binding in QML

Source: https://quickshell.org/docs/v0.3.0/guide/qml-language

Illustrates creating a manual binding at runtime using `Qt.binding`. This is useful for dynamically attaching bindings based on events or conditions.

```qml
Item {
  Text {
    id: boundText
    text: "not bound to anything"
  }

  Button {
    text: "bind the above text"
    onClicked: {
      if (boundText.text == "not bound to anything") {
        text = "press me";
        boundText.text = Qt.binding(() => `button is pressed: ${this.pressed}`);
      }
    }
  }
}
```

--------------------------------

### DesktopEntry.execute()

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/DesktopEntry

Executes the desktop entry application. This is a convenience method that wraps `Quickshell.execDetached()` with the entry's command and working directory.

```APIDOC
## DesktopEntry.execute ()

### Description
Run the application. Currently ignores `runInTerminal` and `command` field codes. This is equivalent to calling `Quickshell.execDetached()` with `command` and `workingDirectory` as shown below:

```
Quickshell.execDetached({
  command: desktopEntry.command,
  workingDirectory: desktopEntry.workingDirectory,
});
```

### Method
execute

### Parameters
None

### Response
- **void**: This function does not return a value.
```

--------------------------------

### Defining Data, State, and Cache Directories

Source: https://quickshell.org/docs/v0.3.0/guide/advanced

Use DataDir, StateDir, and CacheDir pragmas to define custom directories for Quickshell's data, state, and cache. The path can include $BASE/, which resolves to the XDG base directory.

```qml
//@ pragma DataDir <dir>
```

```qml
//@ pragma StateDir <dir>
```

```qml
//@ pragma CacheDir <dir>
```

--------------------------------

### Version and Icon Checking

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/Quickshell

Functions to check Qt and Quickshell versions, and the availability of icons.

```APIDOC
## hasQtVersion (major, minor)

### Description
Check if Qt’s version is at least `major.minor`.

### Parameters
#### Path Parameters
- **major** (int) - Required - The major version number.
- **minor** (int) - Required - The minor version number.

### Return Value
bool - True if Qt version is sufficient, false otherwise.
```

```APIDOC
## hasThemeIcon (icon)

### Description
Check if specified icon has an available icon in your icon theme.

### Parameters
#### Path Parameters
- **icon** (string) - Required - The name of the icon to check.

### Return Value
bool - True if the icon is available, false otherwise.
```

```APIDOC
## hasVersion (major, minor, features)

### Description
Check if Quickshell’s version is at least `major.minor` and the listed unreleased features are available. If Quickshell is newer than the given version it is assumed that all unreleased features are present. The unreleased feature list may be omitted.

### Parameters
#### Path Parameters
- **major** (int) - Required - The major version number.
- **minor** (int) - Required - The minor version number.
- **features** (list) - Optional - A list of unreleased features to check for.

### Return Value
bool - True if Quickshell version and features meet the criteria, false otherwise.
```

```APIDOC
## hasVersion (major, minor)

### Description
Check if Quickshell’s version is at least `major.minor`.

### Parameters
#### Path Parameters
- **major** (int) - Required - The major version number.
- **minor** (int) - Required - The minor version number.

### Return Value
bool - True if Quickshell version is sufficient, false otherwise.
```

--------------------------------

### Using JsonAdapter with FileView

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/JsonAdapter

Demonstrates how to configure FileView with JsonAdapter to manage JSON data. It includes settings for watching file changes and writing adapter updates back to the file. Property changes trigger console logs.

```qml
FileView {
  path: "/path/to/file"

  // when changes are made on disk, reload the file's content
  watchChanges: true
  onFileChanged: reload()

  // when changes are made to properties in the adapter, save them
  onAdapterUpdated: writeAdapter()

  JsonAdapter {
    property string myStringProperty: "default value"
    onMyStringPropertyChanged: {
      console.log("myStringProperty was changed via qml or on disk")
    }

    property list<string> stringList: [ "default", "value" ]

    property JsonObject subObject: JsonObject {
      property string subObjectProperty: "default value"
      onSubObjectPropertyChanged: console.log("same as above")
    }

    // works the same way as subObject
    property var inlineJson: { "a": "b" }
  }
}
```

--------------------------------

### Using ScriptModel with Quickshell Object Models

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/ScriptModel

Demonstrates how to use ScriptModel with unique values from Quickshell's ObjectModels, such as DesktopEntries.applications.values, after filtering.

```qml
ScriptModel {
  values: DesktopEntries.applications.values.filter(...)
}
```

--------------------------------

### Process Environment Configuration

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/Process

Sets up the environment for a process, including clearing existing variables and adding new ones. Use `null` to remove variables, unless `clearEnvironment` is true, in which case `null` passes the system value.

```javascript
clearEnvironment: true
environment: ({
  ADDED: "value",
  PASSED_FROM_SYSTEM: null,
})
```

--------------------------------

### Constructing Shell Path

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/Quickshell

Construct a path within the Quickshell configuration directory using `shellPath`.

```javascript
Quickshell.shellPath("my_config.ini");
```

--------------------------------

### Display System Time with Quickshell

Source: https://quickshell.org/docs/v0.3.0/guide/introduction

This snippet demonstrates how to use the SystemClock integration to display formatted system time. The `precision` property can be set to `SystemClock.Minutes` to conserve battery if seconds are not needed.

```qml
pragma Singleton

import Quickshell
import QtQuick

Singleton {
  id: root
  // an expression can be broken across multiple lines using {}
  readonly property string time: {
    // The passed format string matches the default output of
    // the `date` command.
    Qt.formatDateTime(clock.date, "ddd MMM d hh:mm:ss AP t yyyy")
  }

  SystemClock {
    id: clock
    precision: SystemClock.Seconds
  }
}
```

--------------------------------

### startDetached

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/Process

Launches an instance of the process detached from Quickshell. The subprocess will not be tracked and will not be killed by Quickshell.

```APIDOC
## startDetached ()

### Description
Launches an instance of the process detached from Quickshell. The subprocess will not be tracked, `process.running` will be false, and the subprocess will not be killed by Quickshell.

### Notes
This function is equivalent to Quickshell.execDetached().
```

--------------------------------

### Nix Flake Configuration for Quickshell

Source: https://quickshell.org/docs/v0.3.0/guide/install-setup

Configure Quickshell using a Nix flake, specifying inputs and ensuring system dependency compatibility. The `follows` attribute is crucial for matching Nixpkgs versions.

```nix
{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    quickshell = {
      # add ?ref=<tag> to track a tag
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";

      # THIS IS IMPORTANT
      # Mismatched system dependencies will lead to crashes and other issues.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
```

--------------------------------

### Basic Shell Structure

Source: https://quickshell.org/docs/v0.3.0/guide/introduction

Defines the root scope for a Quickshell application, importing necessary modules.

```qml
// shell.qml
import Quickshell

Scope {
  Bar {}
}
```

--------------------------------

### SocketServer Configuration

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/SocketServer

This snippet shows how to configure and use the SocketServer component, including setting its path, activating it, and defining a connection handler with a custom parser.

```APIDOC
## SocketServer

### Description
Manages a Unix domain socket server.

### Properties
* **path** (string) - The path to create the socket server at. Setting this property while the server is active will have no effect.
* **active** (bool) - If the socket server is currently active. Defaults to false. Setting this to false will destroy all active connections and delete the socket file on disk. If path is empty setting this property will have no effect.
* **handler** (Component) - Connection handler component. Must create a Socket. The created socket should not set `connected` or `closed` and the incoming socket connection will be dropped (they will be set by the socket server.) Setting `connected` to false on the created socket after connection will close and delete it.

### Example
```
SocketServer {
  active: true
  path: "/path/too/socket.sock"
  handler: Socket {
    onConnectedChanged: {
      console.log(connected ? "new connection!" : "connection dropped!")
    }
    parser: SplitParser {
      onRead: message => console.log(`read message from socket: ${message}`)
    }
  }
}
```
```

--------------------------------

### Execute a Process with Arguments

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/Process

Launches a process with specified arguments, stopping any currently running process. Arguments must be in separate values. Use `["sh", "-c", <your command>]` to execute commands with the system shell.

```javascript
process.exec({
  command: ["echo", "hello"],
  workingDirectory: "/tmp",
  environment: {
    "MY_VAR": "my_value"
  },
  clearEnvironment: false
});
```

--------------------------------

### PanelWindow with WlrLayershell

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Wayland/WlrLayershell

Demonstrates how to use WlrLayershell with PanelWindow to attach a window to screen edges using the zwlr_layer_shell_v1 protocol.

```APIDOC
## PanelWindow with WlrLayershell

`PanelWindow` can be backed by `WlrLayershell` for platform-specific layer-shell functionality.

### Basic Usage
```
PanelWindow {
  // When PanelWindow is backed with WlrLayershell this will work
  WlrLayershell.layer: WlrLayer.Bottom
}
```

### Dynamic Property Setting
To maintain platform compatibility, layer-shell specific properties can be set dynamically.

```
PanelWindow {
  Component.onCompleted: {
    if (this.WlrLayershell != null) {
      this.WlrLayershell.layer = WlrLayer.Bottom;
    }
  }
}
```
```

--------------------------------

### Constructing Data Path

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/Quickshell

Construct a path within the Quickshell data directory using `dataPath`.

```javascript
Quickshell.dataPath("my_data_file.txt");
```

--------------------------------

### Constructing Cache Path

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/Quickshell

Construct a path within the Quickshell cache directory using `cachePath`.

```javascript
Quickshell.cachePath("my_cache_file.dat");
```

--------------------------------

### SystemClock Configuration

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/SystemClock

This snippet demonstrates how to instantiate and configure a SystemClock object, setting its precision and accessing its date property for display.

```APIDOC
## SystemClock

### Description
SystemClock is a view into the system’s clock. It updates at hour, minute, or second intervals depending on its precision property.

### Properties
*   **precision** (SystemClock) - The precision the clock should measure at. Defaults to `SystemClock.Seconds`.
*   **hours** (int, readonly) - The current hour.
*   **date** (date, readonly) - The current date and time. Can be formatted using `Qt.formatDateTime()`.
*   **minutes** (int, readonly) - The current minute, or 0 if precision is `SystemClock.Hours`.
*   **seconds** (int, readonly) - The current second, or 0 if precision is `SystemClock.Hours` or `SystemClock.Minutes`.
*   **enabled** (bool) - If the clock should update. Defaults to true. Setting to false pauses the clock.

### Variants
*   **Seconds**: Represents second-level precision.
*   **Hours**: Represents hour-level precision.
*   **Minutes**: Represents minute-level precision.

### Example Usage
```
SystemClock {
  id: clock
  precision: SystemClock.Seconds
}

Text {
  text: Qt.formatDateTime(clock.date, "hh:mm:ss - yyyy-MM-dd")
}
```

### Notes
Clock updates will trigger within 50ms of the system clock changing. If a date object is needed, use the `date` property directly instead of constructing a new one, as the time of a newly constructed object could be off by up to a second.
```

--------------------------------

### SystemTrayItem Methods

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.SystemTray/SystemTrayItem

This section details the methods available for interacting with a SystemTrayItem. These methods allow for triggering primary and secondary activation actions, displaying menus, and handling scroll events.

```APIDOC
## SystemTrayItem Methods

### activate ()

#### Description
Primary activation action, generally triggered via a left click.

#### Method
`activate()`

### display (parentWindow, relativeX, relativeY)

#### Description
Display a platform menu at the given location relative to the parent window.

#### Method
`display(parentWindow: QtObject, relativeX: int, relativeY: int)`

### scroll (delta, horizontal)

#### Description
Scroll action, such as changing volume on a mixer.

#### Method
`scroll(delta: int, horizontal: bool)`

### secondaryActivate ()

#### Description
Secondary activation action, generally triggered via a middle click.

#### Method
`secondaryActivate()`
```

--------------------------------

### DesktopAction.execute()

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/DesktopAction

Executes the desktop action. This is equivalent to calling Quickshell.execDetached() with specific parameters.

```APIDOC
## Functions
  * execute () : void
Run the application. Currently ignores  and field codes.
This is equivalent to calling Quickshell.execDetached() with  and .
```

--------------------------------

### activate()

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.I3/I3Workspace

Activates the workspace, making it the current focus. This is equivalent to dispatching a command to switch to the workspace.

```APIDOC
## activate()

### Description
Activates the workspace. This is equivalent to running `I3.dispatch(`workspace number ${workspace.number}`);`.

### Method
`activate()`

### Returns
- **void**: This function does not return any value.
```

--------------------------------

### Execute Desktop Entry Application

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/DesktopEntry

Use this function to run the application associated with the desktop entry. It is equivalent to calling Quickshell.execDetached with the entry's command and working directory.

```javascript
Quickshell.execDetached({
  command: desktopEntry.command,
  workingDirectory: desktopEntry.workingDirectory,
});
```

--------------------------------

### activate

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Hyprland/HyprlandWorkspace

Activates the workspace, making it the current workspace on its monitor. This is equivalent to dispatching a Hyprland IPC command.

```APIDOC
## activate ()

### Description
Activates the workspace, making it the current workspace on its monitor.

### Method Signature
`activate(): void`

### Usage
This function can be called directly on a HyprlandWorkspace object to switch to that workspace.

### Example
```javascript
// Assuming 'workspace' is a HyprlandWorkspace object
workspace.activate();
```

### Underlying IPC Command
This function is a convenience wrapper for the Hyprland IPC command:
```
HyprlandIpc.dispatch(`workspace ${workspace.name}`);
```
```

--------------------------------

### Show Registered IPC Targets and Functions

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/IpcHandler

Use 'qs ipc show' to list all available IPC targets and their associated functions and signals. This command helps in understanding what can be controlled remotely.

```bash
$ qs ipc show
target rect
  function setColor(color: color): void
  function getColor(): color
  function setAngle(angle: real): void
  function getAngle(): real
  function setRadius(radius: int): void
  function getRadius(): int
  signal radiusChanged(newRadius: int)
```

--------------------------------

### exec

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/Process

Launches a process with the given arguments, stopping any currently running process. The context parameter can be a list of command arguments or a JS object with command, environment, clearEnvironment, and workingDirectory fields.

```APIDOC
## exec (context)

### Description
Launches a process with the given arguments, stopping any currently running process.

### Parameters
#### Path Parameters
- **context** (Object | Array) - Required - Can be a list of command arguments or a JS object with the following fields:
    * `command`: A list containing the command and all its arguments.
    * `environment`: Changes to make to the process environment.
    * `clearEnvironment`: Removes all variables from the environment if true.
    * `workingDirectory`: The working directory the command should run in.

### Notes
- Passed parameters will change the values currently set in the process.
- This does not run command in a shell. All arguments to the command must be in separate values in the list, e.g. `["echo", "hello"]` and not `["echo hello"]`.
- Shell scripts must be run by your shell, e.g. `["sh", "script.sh"]` instead of `["script.sh"]` unless the script has a shebang.
- You can use `["sh", "-c", <your command>]` to execute your command with the system shell.
- Calling this function is equivalent to running:
```
process.running = false;
process.command = ...
process.environment = ...
process.clearEnvironment = ...
process.workingDirectory = ...
process.running = true;
```
```

--------------------------------

### monitorFor

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Hyprland/Hyprland

Retrieves the HyprlandMonitor object corresponding to a quickshell screen.

```APIDOC
  * monitorFor (screen) : HyprlandMonitor
screen: ShellScreen
Get the HyprlandMonitor object that corresponds to a quickshell screen.
```

--------------------------------

### raise

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Mpris/MprisPlayer

Brings the media player window to the front of the window stack. This function may only be called if the player is in a state where it can be raised.

```APIDOC
## raise

### Description
Bring the media player to the front of the window stack.
May only be called if the player is in a state where it can be raised.

### Signature
`raise () : void`
```

--------------------------------

### QML Object Declaration

Source: https://quickshell.org/docs/v0.3.0/guide/qml-language

Illustrates the basic syntax for declaring a QML object, which is an instance of a type from an imported module.

```qml
Name {
  id: foo
  // properties, functions, signals, etc...
}
```

--------------------------------

### Sorting a Copied List with ScriptModel

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/ScriptModel

Shows how to use ScriptModel with a sorted list by first copying the original list using spread syntax to avoid modifying the read-only Quickshell list in-place.

```qml
ScriptModel {
  values: [...DesktopEntries.applications.values].sort(...)
}
```

--------------------------------

### I3IpcListener Configuration

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.I3/I3IpcListener

This snippet shows how to declare and configure an I3IpcListener, specifying which events to subscribe to and how to handle incoming IPC events.

```APIDOC
## I3IpcListener: QtObject 
`import Quickshell.I3`

#### Example
```
I3IpcListener {
  subscriptions: ["input"]
  onIpcEvent: function (event) {
    handleInputEvent(event.data)
  }
}
```

## Properties
  * subscriptions  : list <string>
List of I3/Sway events to subscribe to.

## Signals
  * ipcEvent (event)
event: I3Event
_No details provided_
```

--------------------------------

### QML Property Definition Syntax

Source: https://quickshell.org/docs/v0.3.0/guide/qml-language

Illustrates how to define properties within QML objects, including normal, readonly, and bound properties. It shows the basic syntax for property declaration.

```qml
Item {
  // normal property
  property int foo: 3

  // readonly property
  readonly property string bar: "hi!"

  // bound property
  property var things: [ "foo", "bar" ]
}
```

--------------------------------

### Displaying System Clock with Seconds Precision

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/SystemClock

Configure SystemClock to update every second and format the date and time for display. Ensure to use Qt.formatDateTime for proper string formatting.

```javascript
SystemClock {
  id: clock
  precision: SystemClock.Seconds
}

Text {
  text: Qt.formatDateTime(clock.date, "hh:mm:ss - yyyy-MM-dd")
}
```

--------------------------------

### Setting Anchor Properties for QsMenuAnchor

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/QsMenuAnchor

Demonstrates how to set properties of the anchor for a QsMenuAnchor. This is useful for positioning the menu relative to another window. The anchor must be valid for the menu to be displayed.

```javascript
QsMenuAnchor {
  anchor.window: parentwindow
  // or
  anchor {
    window: parentwindow
  }
}
```

--------------------------------

### Respecting System Style with RespectSystemStyle Pragma

Source: https://quickshell.org/docs/v0.3.0/guide/advanced

Add the RespectSystemStyle pragma to prevent Quickshell from defaulting to the Fusion style, allowing it to follow the system's QtQuick Controls style. A specific style can be enforced using an Env pragma.

```qml
//@ pragma RespectSystemStyle
```

```qml
//@ pragma Env QT_QUICK_CONTROLS_STYLE = MyStyle
```

--------------------------------

### GlobalShortcut Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Hyprland/GlobalShortcut

Properties available for configuring and inspecting global shortcuts.

```APIDOC
## GlobalShortcut Properties

### `triggerDescription` (string)
Have not seen this used ever, but included for completeness. Safe to ignore.

### `name` (string)
The name of the shortcut. You cannot change this at runtime.

### `appid` (string)
The appid of the shortcut. Defaults to `quickshell`. You cannot change this at runtime.
If you have more than one shortcut we recommend subclassing GlobalShortcut to set this.

### `description` (string)
The description of the shortcut that appears in `hyprctl globalshortcuts`. You cannot change this at runtime.

### `pressed` (bool, readonly)
If the keybind is currently pressed.
```

--------------------------------

### Implicit Component Definition and Default Properties

Source: https://quickshell.org/docs/v0.3.0/guide/introduction

Demonstrates a more concise way to define components by placing them directly in the 'delegate' property and omitting the 'delegate:' prefix when using default properties.

```javascript
import Quickshell
import Quickshell.Io
import QtQuick

Scope {
  id: root
  property string time

  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData

      anchors {
        top: true
        left: true
        right: true
      }

      implicitHeight: 30

      Text {
        anchors.centerIn: parent
        text: root.time
      }
    }
  }

  Process {
    id: dateProc
    command: ["date"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: root.time = this.text
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: dateProc.running = true
  }
}
```

--------------------------------

### openUri

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Mpris/MprisPlayer

Opens a given URI in the media player. Note that many players may ignore this command, especially if the URI format is not recognized or compatible.

```APIDOC
## openUri

### Description
Open the given URI in the media player.
Many players will silently ignore this, especially if the uri does not match expected formats.

### Parameters
#### Path Parameters
- **uri** (string) - Required - The URI to open.
```

--------------------------------

### SystemTray Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.SystemTray/SystemTray

Accessing the properties of the SystemTray singleton allows you to retrieve information about the system tray icons.

```APIDOC
## SystemTray Properties

### Description

Access the `items` property to get a read-only `ObjectModel` containing all system tray icons.

### Property

- `items` (ObjectModel<SystemTrayItem>): A read-only object model listing all system tray icons.
```

--------------------------------

### Monitor for Screen

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.I3/I3

Returns the i3/Sway monitor associated with a given screen.

```APIDOC
## monitorFor (screen)

### Description
Return the i3/Sway monitor associated with `screen`.

### Parameters
#### Path Parameters
- **screen** (ShellScreen) - Required - The screen object to associate with a monitor.

### Response
#### Success Response (I3Monitor)
Returns the associated I3Monitor object.
```

--------------------------------

### Path Manipulation Functions

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/Quickshell

Functions for constructing paths relative to Quickshell's cache, data, configuration, and state directories.

```APIDOC
## cachePath (path)

### Description
Equivalent to `${Quickshell.cacheDir}/${path}`.

### Parameters
#### Path Parameters
- **path** (string) - Required - The path to append to the cache directory.

### Return Value
string - The full path within the cache directory.
```

```APIDOC
## dataPath (path)

### Description
Equivalent to `${Quickshell.dataDir}/${path}`.

### Parameters
#### Path Parameters
- **path** (string) - Required - The path to append to the data directory.

### Return Value
string - The full path within the data directory.
```

```APIDOC
## shellPath (path)

### Description
Equivalent to `${Quickshell.configDir}/${path}`.

### Parameters
#### Path Parameters
- **path** (string) - Required - The path to append to the configuration directory.

### Return Value
string - The full path within the configuration directory.
```

```APIDOC
## statePath (path)

### Description
Equivalent to `${Quickshell.stateDir}/${path}`.

### Parameters
#### Path Parameters
- **path** (string) - Required - The path to append to the state directory.

### Return Value
string - The full path within the state directory.
```

--------------------------------

### Create Reusable Panel Windows with Variants

Source: https://quickshell.org/docs/v0.3.0/guide/introduction

Use the Variants type to create instances of a Component, such as PanelWindow, based on a data model like Quickshell.screens. This is useful for creating bars that adapt to the number of connected monitors.

```qml
import Quickshell
import Quickshell.Io
import QtQuick

Variants {
  model: Quickshell.screens;

  delegate: Component {
    PanelWindow {
      // the screen from the screens list will be injected into this
      // property
      required property var modelData

      // we can then set the window's screen to the injected property
      screen: modelData

      anchors {
        top: true
        left: true
        right: true
      }

      implicitHeight: 30

      Text {
        id: clock
        anchors.centerIn: parent

        Process {
          id: dateProc
          command: ["date"]
          running: true

          stdout: StdioCollector {
            onStreamFinished: clock.text = this.text
          }
        }

        Timer {
          interval: 1000
          running: true
          repeat: true
          onTriggered: dateProc.running = true
        }
      }
    }
  }
}
```

--------------------------------

### Connect to QML Signals using `Connections`

Source: https://quickshell.org/docs/v0.3.0/guide/qml-language

The `Connections` object provides an alternative to implicit signal handlers or direct `.connect` calls, useful for connecting to signals of Singleton objects or when defining handlers is inconvenient.

```qml
Item {
  Button {
    id: myButton
    text "click me"
  }

  Connections {
    target: myButton

    function onClicked() {
      // ...
    }
  }
}
```

--------------------------------

### SystemTrayItem Signals

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.SystemTray/SystemTrayItem

This section details the signals emitted by the SystemTrayItem. The `ready` signal is emitted when the system tray item is ready.

```APIDOC
## SystemTrayItem Signals

### ready ()

#### Description
Emitted when the system tray item is ready.

#### Signal
`ready()`
```

--------------------------------

### Create a White Bar Attached to the Bottom of the Screen

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/PanelWindow

This snippet demonstrates how to create a PanelWindow anchored to the bottom of the screen with text centered within it. Ensure Quickshell is imported before use.

```javascript
PanelWindow {
  anchors {
    left: true
    bottom: true
    right: true
  }

  Text {
    anchors.centerIn: parent
    text: "Hello!"
  }
}
```

--------------------------------

### I3 Dispatch Command

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.I3/I3

Executes an I3/Sway command.

```APIDOC
## dispatch (request)

### Description
Executes an I3/Sway command.

### Parameters
#### Path Parameters
- **request** (string) - Required - The command to execute.

### Response
#### Success Response (void)
Indicates the command was processed.
```

--------------------------------

### QsMenuOpener Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/QsMenuOpener

QsMenuOpener exposes properties to access the associated menu and its children.

```APIDOC
## QsMenuOpener: QtObject 
`import Quickshell`
Provides access to children of a QsMenuEntry
## Properties
  * menu  : QsMenuHandle
The menu to retrieve children from.
  * children  : ObjectModel <QsMenuEntry> readonly
The children of the given menu.
```

--------------------------------

### Displaying Menu Item Icon

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/QsMenuEntry

This snippet shows how to use the `icon` property of a QsMenuEntry to display an icon in an Image component. Ensure the image source size matches the rendered size for optimal quality.

```javascript
Image {
  source: menuItem.icon
  // To get the best image quality, set the image source size to the same size
  // as the rendered image.
  sourceSize.width: width
  sourceSize.height: height
}
```

--------------------------------

### Setting Icon Theme with IconTheme Pragma

Source: https://quickshell.org/docs/v0.3.0/guide/advanced

Specify the Qt icon theme using the IconTheme pragma. This can also be configured via the QS_ICON_THEME environment variable.

```qml
//@ pragma IconTheme <theme>
```

--------------------------------

### Create a Centered Panel PopupWindow

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/PopupWindow

This snippet demonstrates how to create a panel window and position a PopupWindow centered over it. Ensure the parent window is defined before the PopupWindow.

```javascript
PanelWindow {
  id: toplevel

  anchors {
    bottom: true
    left: true
    right: true
  }

  PopupWindow {
    anchor.window: toplevel
    anchor.rect.x: parentWindow.width / 2 - width / 2
    anchor.rect.y: parentWindow.height
    width: 500
    height: 500
    visible: true
  }
}
```

--------------------------------

### Version Gating with hasQtVersion

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/Quickshell

Use `hasQtVersion` to conditionally execute code based on the Qt version. The preprocessor directive `//@ if` is used for this purpose.

```javascript
//@ if hasVersion(6, 10)
...
//@ endif
```

--------------------------------

### Pipewire Singleton

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Pipewire/Pipewire

The Pipewire singleton provides access to various Pipewire objects and their states. It is the main entry point for interacting with the Pipewire service.

```APIDOC
## Pipewire: QtObject
singleton
`import Quickshell.Services.Pipewire`
Contains links to all pipewire objects.

### Properties

* **links** : ObjectModel <PwLink> readonly
  All links present in pipewire. Links connect pipewire nodes to each other, and can be used to determine their relationship. If you already have a node you want to check for connections to, use PwNodeLinkTracker instead of filtering this list. Multiple links may exist between the same nodes. See for a deduplicated list containing only one entry per link between nodes.

* **defaultAudioSource** : PwNode readonly
  The default audio source (input) or `null`.
  This is the default source currently in use by pipewire, and the one applications are currently using. To set the default source, use .
  When the default source changes, this property may breifly become null. This depends on your hardware.

* **nodes** : ObjectModel <PwNode> readonly
  All nodes present in pipewire.
  This list contains every node on the system. To find a useful subset, filtering with the following properties may be helpful:
    * - if the node is an application or hardware device.
    * - if the node is a sink or source.
    * - if non null the node is an audio node.

* **ready** : bool readonly
  This property is true if quickshell has completed its initial sync with the pipewire server. If true, nodes, links and sync/source preferences will be in a good state. You can use the pipewire object before it is ready, but some nodes/links may be missing, and preference metadata may be null.

* **preferredDefaultAudioSource** : PwNode
  The preferred default audio source (input) or `null`.
  This is a hint to pipewire telling it which source should be the default when possible. may differ when it is not possible for pipewire to pick this node.
  See for the current default source, regardless of preference.

* **preferredDefaultAudioSink** : PwNode
  The preferred default audio sink (output) or `null`.
  This is a hint to pipewire telling it which sink should be the default when possible. may differ when it is not possible for pipewire to pick this node.
  See for the current default sink, regardless of preference.

* **linkGroups** : ObjectModel <PwLinkGroup> readonly
  All link groups present in pipewire.
  The same as but deduplicated. If you already have a node you want to check for connections to, use PwNodeLinkTracker instead of filtering this list.

* **defaultAudioSink** : PwNode readonly
  The default audio sink (output) or `null`.
  This is the default sink currently in use by pipewire, and the one applications are currently using. To set the default sink, use .
  When the default sink changes, this property may breifly become null. This depends on your hardware.
```

--------------------------------

### connectWithPsk

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Networking/WifiNetwork

Attempts to connect to the Wi-Fi network using a provided Pre-Shared Key (PSK).

```APIDOC
## connectWithPsk (psk)

### Description
Attempt to connect to the network with the given PSK. If the PSK is wrong, a signal will be emitted with `NoSecrets`.

The networking backend may store the PSK for future use with Network.connect(). As such, calling that function first is recommended to avoid having to show a prompt if not required.

PSKs should only be provided when the security type is one of `WpaPsk`, `Wpa2Psk`, or `Sae`.

### Parameters
#### Path Parameters
- **psk** (string) - Required - The Pre-Shared Key for the Wi-Fi network.
```

--------------------------------

### Bar Component Using Singleton

Source: https://quickshell.org/docs/v0.3.0/guide/introduction

Simplifies the Bar component by removing the explicit 'Time' instance, relying on the global singleton.

```qml
// Bar.qml
import Quickshell

Scope {
  // no more time object

  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData

      anchors {
        top: true
        left: true
        right: true
      }

      implicitHeight: 30

      ClockWidget {
        anchors.centerIn: parent

        // no more time binding
      }
    }
  }
}
```

--------------------------------

### QsMenuEntry Display Function

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/QsMenuEntry

Displays a platform menu at a specified location relative to a parent window.

```APIDOC
## Function: display
Displays a platform menu at the given location relative to the parent window.

### Parameters
* parentWindow: QtObject
* relativeX: int
* relativeY: int

### Returns
* void
```

--------------------------------

### Activate an I3/Sway Workspace

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.I3/I3Workspace

Activates a specific workspace by its number. This is equivalent to running the command directly in i3/Sway.

```javascript
I3.dispatch(`workspace number ${workspace.number}`);
```

--------------------------------

### DesktopEntries.applications

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/DesktopEntries

Provides read-only access to all desktop entries of type Application that are not marked as Hidden or NoDisplay.

```APIDOC
## applications : ObjectModel <DesktopEntry> readonly

### Description
All desktop entries of type Application that are not Hidden or NoDisplay.

### Properties
- **applications** (ObjectModel<DesktopEntry>) - Readonly - A collection of desktop entries.
```

--------------------------------

### Windowset Functions

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.WindowManager/Windowset

This section details the functions available for interacting with a Windowset. These functions allow for activation, deactivation, removal, and projection changes.

```APIDOC
## activate ()

### Description
Activate the windowset, making it the current workspace on a workspace based WM, or activating the tag on a tag based WM.

### Method
`activate()`

### Parameters
None

### Response
`void`

## deactivate ()

### Description
Deactivate the windowset, hiding it.

### Method
`deactivate()`

### Parameters
None

### Response
`void`

## remove ()

### Description
Remove or destroy the windowset.

### Method
`remove()`

### Parameters
None

### Response
`void`

## setProjection (projection)

### Description
Move the windowset to a different projection. A projection represents the set of screens a workspace spans.

### Method
`setProjection(projection: WindowsetProjection)`

### Parameters
#### Path Parameters
- **projection** (WindowsetProjection) - Required - The target projection to move the windowset to.

### Response
`void`
```

--------------------------------

### DesktopAction Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/DesktopAction

Properties of a DesktopAction.

```APIDOC
## Properties
  * name  : string
  * icon  : string
  * execString  : string
  * command  : list <string>
  * id  : string readonly
```

--------------------------------

### write

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/Process

Writes data to the process's stdin. Does nothing if the process is not running.

```APIDOC
## write (data)

### Description
Writes to the process’s stdin.

### Parameters
#### Path Parameters
- **data** (string) - Required - The data to write to the process's stdin.
```

--------------------------------

### Process Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/Process

Details on the configurable properties of the Process object, including stdout, running state, environment variables, command execution, and working directory.

```APIDOC
## Properties [?]
  * stdout  : DataStreamParser
The parser for stdout. If the parser is null the process’s stdout channel will be closed and no further data will be read, even if a new parser is attached.
  * running  : bool
If the process is currently running. Defaults to false.
Setting this property to true will start the process if command has at least one element. Setting it to false will send SIGTERM. To immediately kill the process, use signal() with SIGKILL. The process will be killed when quickshell dies.
If you want to run the process in a loop, use the onRunningChanged signal handler to restart the process.
```
Process {
  running: true
  onRunningChanged: if (!running) running = true
}
```

See startDetached() to prevent the process from being killed by Quickshell if Quickshell is killed or the configuration is reloaded.
  * clearEnvironment  : bool
If the process’s environment should be cleared prior to applying . Defaults to false.
If true, all environment variables will be removed before the  object is applied, meaning the variables listed will be the only ones visible to the process. This changes the behavior of `null` to pass in the system value of the variable if present instead of removing it.
```
clearEnvironment: true
environment: ({
  ADDED: "value",
  PASSED_FROM_SYSTEM: null,
})
```

If the process is already running changing this property will affect the next started process. If the property has been changed after starting a process it will return the new value, not the one for the currently running process.
  * command  : list <string>
The command to execute. Each argument is its own string, which means you don’t have to deal with quoting anything.
If the process is already running changing this property will affect the next started process. If the property has been changed after starting a process it will return the new value, not the one for the currently running process.
This does not run command in a shell. All arguments to the command must be in separate values in the list, e.g. `["echo", "hello"]` and not `["echo hello"]`.
Additionally, shell scripts must be run by your shell, e.g. `["sh", "script.sh"]` instead of `["script.sh"]` unless the script has a shebang.
You can use `["sh", "-c", <your command>]` to execute your command with the system shell.
  * processId  : variant readonly
The process ID of the running process or `null` if  is false.
  * environment  : unknown
Environment of the executed process.
This is a javascript object (json). Environment variables can be added by setting them to a string and removed to null (except when  is true, in which case this behavior is inverted, see  for details).
```
environment: ({
  ADDED: "value",
  REMOVED: null,
  "i'm different": "value",
})
```

You need to wrap the returned object in () otherwise it won’t parse due to javascript ambiguity.
If the process is already running changing this property will affect the next started process. If the property has been changed after starting a process it will return the new value, not the one for the currently running process.
  * stderr  : DataStreamParser
The parser for stderr. If the parser is null the process’s stdout channel will be closed and no further data will be read, even if a new parser is attached.
  * stdinEnabled  : bool
If stdin is enabled. Defaults to false. If this property is false the process’s stdin channel will be closed and write() will do nothing, even if set back to true.
  * workingDirectory  : string
The working directory of the process. Defaults to quickshell’s working directory.
If the process is already running changing this property will affect the next started process. If the property has been changed after starting a process it will return the new value, not the one for the currently running process.
```

--------------------------------

### Connect to QML Signals using `connect`

Source: https://quickshell.org/docs/v0.3.0/guide/qml-language

Signals have a `connect` method that allows invoking a function or another signal when the signal is emitted. This is useful for decoupling event sources from their handlers.

```qml
ColumnLayout {
  property int clicks: 0

  function updateText() {
    clicks += 1;
    label.text = `the button has been clicked ${clicks} times!`;
  }

  Button {
    id: button
    text: "click me"
  }

  Text {
    id: label
    text: "the button has not been clicked"
  }

  Component.onCompleted: {
    button.clicked.connect(updateText)
  }
}
```

--------------------------------

### QsWindow Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/QsWindow

This section details the properties available for QsWindow objects, which can be used to manage window behavior and appearance.

```APIDOC
## QsWindow Properties

### backingWindowVisible
- **Type**: bool
- **Readonly**: true
- **Description**: Indicates if the window is currently displayed. Prefer `visible` for general use.

### height
- **Type**: int
- **Description**: The actual height of the window. Setting this property is deprecated; use the appropriate method instead.

### visible
- **Type**: bool
- **Default**: true
- **Description**: Controls whether the window is shown or hidden.

### implicitWidth
- **Type**: int
- **Description**: The desired width of the window.

### implicitHeight
- **Type**: int
- **Description**: The desired height of the window.

### contentItem
- **Type**: Item
- **Readonly**: true
- **Description**: The content item associated with the window.

### mask
- **Type**: Region
- **Default**: null
- **Description**: Defines the clickable area of the window. If null, the entire window is clickable. Can be used with `intersection` mode to invert clickability.

### devicePixelRatio
- **Type**: real
- **Readonly**: true
- **Description**: The ratio between logical pixels and monitor pixels for the current window.

### data
- **Type**: list <QtObject>
- **Default**: readonly
- **Description**: No details provided.

### surfaceFormat
- **Type**: opaque:bool
- **Description**: Sets the surface format, specifically whether the surface should be opaque. This cannot be changed after the window is created.

### screen
- **Type**: ShellScreen
- **Description**: The screen the window currently occupies. Can be modified to move the window to a different screen.

### updatesEnabled
- **Type**: bool
- **Default**: true
- **Description**: Determines if the window receives render updates. Disabling this can save GPU resources for static windows.

### width
- **Type**: int
- **Description**: The actual width of the window. Setting this property is deprecated; use the appropriate method instead.

### windowTransform
- **Type**: QtObject
- **Readonly**: true
- **Description**: Receives updates when factors affecting the window's position and transform change. Useful for forcing binding updates.

### color
- **Type**: color
- **Default**: white
- **Description**: The background color of the window. If opaque before becoming visible, it cannot become transparent later unless `opaque` is false.
```

--------------------------------

### Setting Environment Variables with Env Pragmas

Source: https://quickshell.org/docs/v0.3.0/guide/advanced

Configure Qt and Quickshell environment variables using Env and DefaultEnv pragmas. These affect the Quickshell instance but not spawned processes.

```qml
//@ pragma Env VAR = VAL
//@ pragma DefaultEnv VAR = VAL
```

--------------------------------

### dispatch

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Hyprland/Hyprland

Executes a Hyprland dispatcher command.

```APIDOC
## Functions
  * dispatch (request) : void
request: string
Execute a hyprland dispatcher.
```

--------------------------------

### Bluetooth Object

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Bluetooth/Bluetooth

The Bluetooth singleton object provides access to Bluetooth functionalities.

```APIDOC
## Bluetooth: QtObject 
singleton
`import Quickshell.Bluetooth`
Provides access to bluetooth devices and adapters.

### Properties
* **devices** : ObjectModel <BluetoothDevice> readonly
A list of all connected bluetooth devices across all adapters. See for the devices connected to a single adapter.
* **adapters** : ObjectModel <BluetoothAdapter> readonly
A list of all bluetooth adapters. See for the default.
* **defaultAdapter** : BluetoothAdapter readonly
The default bluetooth adapter. Usually there is only one.
```

--------------------------------

### Version Gating with hasVersion

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/Quickshell

Use `hasVersion` to conditionally execute code based on Quickshell's version and available features. The preprocessor directive `//@ if` is used for this purpose.

```javascript
//@ if hasVersion(0, 3, ["feature"])
...
//@ endif
```

--------------------------------

### HyprlandWindow Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Hyprland/HyprlandWindow

This section details the properties available on the HyprlandWindow object, which can be attached to QsWindow instances to control Hyprland-specific window behaviors.

```APIDOC
## HyprlandWindow Properties

### opacity

* **Type**: `real`
* **Description**: A multiplier for the window’s overall opacity, ranging from 1.0 (fully opaque) to 0.0 (fully transparent). This affects both the window content and any visual effects applied, such as blur.
* **Default**: `1.0`

### visibleMask

* **Type**: `Region`
* **Description**: A hint to the compositor specifying which regions of the surface should be rendered. This is useful for optimizing performance by avoiding the rendering of large empty areas, particularly when blur effects are active. The mask should encompass all non-transparent pixels of the window.

```

--------------------------------

### SystemTrayItem Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.SystemTray/SystemTrayItem

This section outlines the properties of a SystemTrayItem. These properties provide information about the item's status, appearance, and menu availability.

```APIDOC
## SystemTrayItem Properties

### status

#### Description
Represents the current status of the system tray item.

#### Type
`Status` (readonly)

### tooltipDescription

#### Description
A description shown in the tooltip for the system tray item.

#### Type
`string` (readonly)

### title

#### Description
Text that describes the application associated with the system tray item.

#### Type
`string` (readonly)

### category

#### Description
Categorization of the system tray item.

#### Type
`Category` (readonly)

### tooltipTitle

#### Description
The title shown in the tooltip for the system tray item.

#### Type
`string` (readonly)

### icon

#### Description
Icon source string, usable as an Image source for the system tray item.

#### Type
`string` (readonly)

### hasMenu

#### Description
Indicates if this tray item has an associated menu accessible via `display()`.

#### Type
`bool` (readonly)

### onlyMenu

#### Description
Indicates if this tray item only offers a menu and activation will do nothing.

#### Type
`bool` (readonly)

### menu

#### Description
A handle to the menu associated with this tray item, if any. Can be displayed with QsMenuAnchor or QsMenuOpener.

#### Type
`unknown` (readonly)

### id

#### Description
A name unique to the application, such as its name.

#### Type
`string` (readonly)
```

--------------------------------

### ShellScreen Functions

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/ShellScreen

This section details the available functions for the ShellScreen object.

```APIDOC
## ShellScreen Functions

### toString ()

- **Returns**: (string) A string representation of the ShellScreen object.
```

--------------------------------

### IpcHandler Functions and Signals

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/IpcHandler

This section details how to define and use functions and signals within an IpcHandler. Functions can be called remotely if they have at most 10 arguments, and both arguments and return types must be explicitly specified. Signals can be observed using 'qs ipc wait' or 'qs ipc listen'.

```APIDOC
## IpcHandler

Exposes functions and properties of a Qt object for remote access via `qs ipc`.

### Handler Functions

Functions exposed via `IpcHandler` can be called using `qs ipc call`.

**Requirements:**
- Maximum of 10 arguments.
- Argument and return types must be explicitly specified.

**Supported Types:**
- **Arguments:** `string`, `int`, `bool`, `real`, `color`
- **Return Types:** `void`, `string`, `int`, `bool`, `real`, `color`

### Signals

Signals can be observed remotely using `qs ipc wait` (for a single emission) or `qs ipc listen` (for continuous listening).

**Argument:** Signals can have zero or one argument of the supported IPC types.

### Example Usage

```javascript
IpcHandler {
  target: "rect"

  function setColor(color: color): void { rect.color = color; }
  function getColor(): color { return rect.color; }

  function setAngle(angle: real): void { rect.rotation = angle; }
  function getAngle(): real { return rect.rotation; }

  function setRadius(radius: int): void { rect.radius = radius; this.radiusChanged(radius); }
  function getRadius(): int { return rect.radius; }

  signal radiusChanged(newRadius: int);
}
```

### Command Line Interaction

**Show available IPC targets and functions:**
```bash
$ qs ipc show
```

**Call an IPC function:**
```bash
$ qs ipc call <target> <function_name> [arguments...]

# Example calls:
$ qs ipc call rect setColor orange
$ qs ipc call rect setAngle 40.5
$ qs ipc call rect setRadius 30
```

**Get return values:**
```bash
$ qs ipc call rect getColor
# Expected output: #ffffa500

$ qs ipc call rect getAngle
# Expected output: 40.5

$ qs ipc call rect getRadius
# Expected output: 30
```
```

--------------------------------

### Find Monitor by Name

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.I3/I3

Finds an I3Monitor using its name.

```APIDOC
## findMonitorByName (name)

### Description
Find an I3Monitor using its name, returns null if the monitor doesn’t exist.

### Parameters
#### Path Parameters
- **name** (string) - Required - The name of the monitor to find.

### Response
#### Success Response (I3Monitor)
Returns the found I3Monitor object or null if not found.
```

--------------------------------

### ScriptModel vs. Direct JavaScript Expression

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/ScriptModel

Compares using a direct JavaScript expression as a model, which causes delegate re-creation on changes, with using ScriptModel, which only adds/removes delegates as needed, preserving animations.

```qml
Repeater {
  model: myList.filter(entry => entry.name.startsWith(filterText))
  delegate: // ...
}
```

```qml
Repeater {
  model: ScriptModel {
    values: myList.filter(entry => entry.name.startsWith(filterText))
  }

  delegate: // ...
```

--------------------------------

### Activate Hyprland Workspace

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Hyprland/HyprlandWorkspace

Use this function to activate a specific workspace. This is equivalent to dispatching a Hyprland IPC command.

```javascript
HyprlandIpc.dispatch("workspace ${workspace.name}");
```

--------------------------------

### Reading a JSON file as text

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/FileView

Use this snippet to load a JSON file as plain text. Set `blockLoading` to true to ensure the file is fully loaded before parsing. This is useful for configuration files or data that must be available before the UI is fully interactive.

```javascript
FileView {
  id: jsonFile
  path: Qt.resolvedUrl("./your.json")
  // Forces the file to be loaded by the time we call JSON.parse().
  // see blockLoading's property documentation for details.
  blockLoading: true
}

readonly property var jsonData: JSON.parse(jsonFile.text())
```

--------------------------------

### QML Lambda Syntax

Source: https://quickshell.org/docs/v0.3.0/guide/qml-language

Lambdas provide a concise syntax for defining functions that can be assigned to properties or passed as callbacks. They support zero or more parameters and single or multiline expressions.

```qml
<params> => <expression>

// params can take the following forms:
() => ... // 0 parameters
<name> => ... // 1 parameter
(<name>[, ...]) => ... // 1+ parameters

// the expression can be either a single or multiline expression.
... => <result>
... => {
  return <result>;
}
```

--------------------------------

### Environment and Process Management

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/Quickshell

Functions for accessing environment variables and launching detached processes.

```APIDOC
## env (variable)

### Description
Returns the string value of an environment variable or null if it is not set.

### Parameters
#### Path Parameters
- **variable** (string) - Required - The name of the environment variable.

### Return Value
variant - The string value of the environment variable or null.
```

```APIDOC
## execDetached (context)

### Description
Launch a process detached from Quickshell.

### Parameters
#### Path Parameters
- **context** (object | list) - Required - Can be a list of command arguments or a JS object with command details.
  - `command`: (list) A list containing the command and all its arguments.
  - `environment`: (object) Changes to make to the process environment.
  - `clearEnvironment`: (bool) Removes all variables from the environment if true.
  - `workingDirectory`: (string) The working directory the command should run in.

### Notes
This does not run the command in a shell. All arguments to the command must be in separate values in the list, e.g. `["echo", "hello"]` and not `["echo hello"]`. Shell scripts must be run by your shell, e.g. `["sh", "script.sh"]` instead of `["script.sh"]` unless the script has a shebang. You can use `["sh", "-c", <your command>]` to execute your command with the system shell. This function is equivalent to Process.startDetached().
```

--------------------------------

### toString Function

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Bluetooth/BluetoothDeviceState

Converts a BluetoothDeviceState to its string representation.

```APIDOC
## Functions [?]
  * toString (state) : string
state: BluetoothDeviceState
_No details provided_
```

--------------------------------

### Define a Custom QML Type

Source: https://quickshell.org/docs/v0.3.0/guide/qml-language

Create reusable QML components by defining a new type in a QML file. Properties defined at the root level become visible to consumers of the type.

```QML
// MyText.qml
Rectangle {
  required property string text

  color: "red"
  implicitWidth: textObj.implicitWidth
  implicitHeight: textObj.implicitHeight

  Text {
    id: textObj
    anchors.fill: parent
    text: parent.text
  }
}
```

```QML
// AnotherComponent.qml
Item {
  MyText {
    // The `text` property of `MyText` is required, so we must set it.
    text: "Hello World!"

    // `anchors` is a property of `Item` which `Rectangle` subclasses,
    // so it is available on MyText.
    anchors.centerIn: parent

    // `color` is a property of `Rectangle`. Even though MyText sets it
    // to "red", we can override it here.
    color: "blue"

    // `textObj` is has an `id` within MyText.qml but is not a property
    // so we cannot access it.
    textObj.color: "red" // illegal
  }
}
```

--------------------------------

### Singleton Time Component

Source: https://quickshell.org/docs/v0.3.0/guide/introduction

Defines a singleton 'Time' component, making its instance globally accessible and simplifying state management.

```qml
// Time.qml

// with this line our type becomes a Singleton
pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// your singletons should always have Singleton as the type
Singleton {
  id: root
  property string time

  Process {
    id: dateProc
    command: ["date"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: root.time = this.text
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: dateProc.running = true
  }
}
```

--------------------------------

### WindowManager Functions

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.WindowManager/WindowManager

Provides functions for interacting with window management, such as retrieving screen-specific projections.

```APIDOC
## WindowManager Functions

### `screenProjection(screen)`

- **Parameters**:
  - `screen` (ShellScreen) - The screen for which to retrieve the projection.
- **Returns**: `ScreenProjection`
- **Description**: Returns an internal `WindowsetProjection` that covers a single screen and contains all windowsets on that screen, regardless of the WM-specified projection. Depending on how the WM lays out its actual projections, multiple `ScreenProjections` may contain the same `Windowsets`.
```

--------------------------------

### Bar Component with Clock

Source: https://quickshell.org/docs/v0.3.0/guide/introduction

Implements a bar component that displays a dynamic clock, including screen handling and a process to fetch the time.

```qml
// Bar.qml
import Quickshell
import Quickshell.Io
import QtQuick

Scope {
  id: root
  property string time

  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData

      anchors {
        top: true
        left: true
        right: true
      }

      implicitHeight: 30

      Text {
        anchors.centerIn: parent
        text: root.time
      }
    }
  }

  Process {
    id: dateProc
    command: ["date"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: root.time = this.text
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: dateProc.running = true
  }
}
```

--------------------------------

### Find Workspace by Name

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.I3/I3

Finds an I3Workspace using its name.

```APIDOC
## findWorkspaceByName (name)

### Description
Find an I3Workspace using its name, returns null if the workspace doesn’t exist.

### Parameters
#### Path Parameters
- **name** (string) - Required - The name of the workspace to find.

### Response
#### Success Response (I3Workspace)
Returns the found I3Workspace object or null if not found.
```

--------------------------------

### Monitoring Track Position with Timer

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Mpris/MprisPlayer

Use a Timer to emit the positionChanged signal at a specified interval (e.g., every second) when the player is playing, useful for less frequent updates.

```javascript
Timer {
  // only emit the signal when the position is actually changing.
  running: player.playbackState == MprisPlaybackState.Playing
  // Make sure the position updates at least once per second.
  interval: 1000
  repeat: true
  // emit the positionChanged signal every second.
  onTriggered: player.positionChanged()
}
```

--------------------------------

### QuickshellSettings Signals

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/QuickshellSettings

Information about signals emitted by QuickshellSettings.

```APIDOC
## QuickshellSettings

### Signals

*   **lastWindowClosed** (): Sent when the last window is closed. To make the application exit when the last window is closed run `Qt.quit()`.
```

--------------------------------

### WifiNetwork Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Networking/WifiNetwork

Properties available for a WifiNetwork object.

```APIDOC
## WifiNetwork Properties

### security
- **Type**: WifiSecurityType
- **Description**: The security type of the wifi network.

### signalStrength
- **Type**: real
- **Description**: The current signal strength of the network, from 0.0 to 1.0.
```

--------------------------------

### Socket Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/Socket

Properties to manage the socket connection and path.

```APIDOC
## Socket Properties

### `connected` (bool)
Returns if the socket is currently connected. Writing to this property will set the target connection state and will not update the property immediately. Setting the property to false will begin disconnecting the socket, and setting it to true will begin connecting the socket if path is not empty.

### `path` (string)
The path to connect this socket to when `connected` is set to true. Changing this property will have no effect while the connection is active.
```

--------------------------------

### Declare a Singleton QML Type

Source: https://quickshell.org/docs/v0.3.0/guide/qml-language

Make a QML type a Singleton by adding `pragma Singleton` at the top of the file. Singletons ensure only one instance of a type exists and its members can be accessed by name.

```QML
pragma Singleton
import ...

Singleton {
  ...
}
```

--------------------------------

### windowConnected

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/QsWindow

This signal is emitted when the window is successfully connected.

```APIDOC
## windowConnected

### Description
This signal is emitted when the window is successfully connected.

### Parameters
_No parameters provided._

### Returns
_No return value._
```

--------------------------------

### Set HyprlandWindow Opacity

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Hyprland/HyprlandWindow

Use this snippet to set the opacity of a Hyprland window. The opacity value can be a fixed number or a binding.

```QML
PopupWindow {
  // ...
  HyprlandWindow.opacity: 0.6 // any number or binding
}
```

--------------------------------

### Greetd Functions

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Greetd/Greetd

Functions available to interact with the greetd service for session management.

```APIDOC
## Functions

* cancelSession () : void
Cancel the active greetd session.

* createSession (user)
user: string
Create a greetd session for the given user.

* launch (command)
command: list
Launch the session, exiting quickshell. must be `GreetdState.ReadyToLaunch` to call this function.

* launch (command, environment)
command: list environment: list
Launch the session, exiting quickshell. must be `GreetdState.ReadyToLaunch` to call this function.

* launch (command, environment, quit)
command: list environment: list quit: bool
Launch the session, exiting quickshell if is true. must be `GreetdState.ReadyToLaunch` to call this function.
The signal can be used to perform an action after greetd has acknowledged the desired session.
Note that greetd expects the greeter to terminate as soon as possible after setting a target session, and waiting too long may lead to unexpected behavior such as the greeter restarting.
Performing animations and such should be done _before_ calling .

* respond (response)
response: string
Respond to an authentication message.
May only be called in response to an with `responseRequired` set to true.
```

--------------------------------

### FloatingWindow Functions

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/FloatingWindow

Functions available to interact with the FloatingWindow for system operations.

```APIDOC
## FloatingWindow Functions

* `startSystemMove()` : bool
Start a system move operation. Must be called during a pointer press/drag.
* `startSystemResize(edges)` : bool
edges: 
Start a system resize operation. Must be called during a pointer press/drag.
```

--------------------------------

### Create a Rounded Window in QML

Source: https://quickshell.org/docs/v0.3.0/guide/faq

Use a transparent PanelWindow with a rounded Rectangle inside to create a rounded window effect.

```qml
PanelWindow {
  color: "transparent"

  Rectangle {
    // match the size of the window
    anchors.fill: parent

    radius: 5
    color: "white" // your actual color
  }
}
```

--------------------------------

### Quickshell QtObject Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/Quickshell

This section details the various properties of the Quickshell QtObject that can be accessed and, in some cases, modified by the user.

```APIDOC
## Quickshell QtObject Properties

### Properties

*   **cacheDir**: `string` (readonly)
    The per-shell cache directory. Usually `~/.cache/quickshell/by-shell/<shell-id>`. Can be overridden using `//@ pragma CacheDir $BASE/path` in the root qml file, where `$BASE` corresponds to `$XDG_CACHE_HOME` (usually `~/.cache`).

*   **processId**: `int` (readonly)
    Quickshell’s process id.

*   **stateDir**: `string` (readonly)
    The per-shell state directory. Usually `~/.local/state/quickshell/by-shell/<shell-id>`. Can be overridden using `//@ pragma StateDir $BASE/path` in the root qml file, where `$BASE` corresponds to `$XDG_STATE_HOME` (usually `~/.local/state`).

*   **clipboardText**: `string`
    The system clipboard. Under wayland the clipboard will be empty unless a quickshell window is focused.

*   **screens**: `list <ShellScreen>` (readonly)
    All currently connected screens. This property updates as connected screens change.
    #### Reusing a window on every screen
    ```
    ShellRoot {
      Variants {
        // see Variants for details
        variants: Quickshell.screens
        PanelWindow {
          property var modelData
          screen: modelData
        }
      }
    }
    ```
    This creates an instance of your window once on every screen. As screens are added or removed your window will be created or destroyed on those screens.

*   **dataDir**: `string` (readonly)
    The per-shell data directory. Usually `~/.local/share/quickshell/by-shell/<shell-id>`. Can be overridden using `//@ pragma DataDir $BASE/path` in the root qml file, where `$BASE` corresponds to `$XDG_DATA_HOME` (usually `~/.local/share`).

*   **shellDir**: `string` (readonly)
    The full path to the root directory of your shell. The root directory is the folder containing the entrypoint to your shell, often referred to as `shell.qml`.

*   **shellRoot**: `string` (readonly)
    Deprecated: Renamed to  for consistency.

*   **workingDirectory**: `string`
    Quickshell’s working directory. Defaults to whereever quickshell was launched from.

*   **configDir**: `string` (readonly)
    Deprecated: Renamed to  for clarity.

*   **watchFiles**: `bool`
    If true then the configuration will be reloaded whenever any files change. Defaults to true.
```

--------------------------------

### QuickshellSettings Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/QuickshellSettings

Access and modify Quickshell's operational settings.

```APIDOC
## QuickshellSettings

### Properties

*   **workingDirectory** (string): Quickshell’s working directory. Defaults to whereever quickshell was launched from.
*   **watchFiles** (bool): If true then the configuration will be reloaded whenever any files change. Defaults to true.
```

--------------------------------

### DBusMenuHandle Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.DBusMenu/DBusMenuHandle

Exposes properties of the DBusMenuHandle.

```APIDOC
## DBusMenuHandle

Handle to a menu tree provided by a remote process.

### Properties

*   **menu** (DBusMenuItem) - Readonly. Represents the root of the menu tree.
```

--------------------------------

### DesktopEntries.byId

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/DesktopEntries

Looks up a desktop entry by its exact name. This function includes entries that are marked as NoDisplay. It may return null if no entry is found.

```APIDOC
## byId (id)

### Description
Look up a desktop entry by name. Includes NoDisplay entries. May return null.
While this function requires an exact match, heuristicLookup() will correctly find an entry more often and is generally more useful.

### Parameters
#### Path Parameters
- **id** (string) - Required - The exact name of the desktop entry to look up.
```

--------------------------------

### WiredDevice Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Networking/WiredDevice

This snippet details the properties available for a WiredDevice object.

```APIDOC
## WiredDevice Properties

### linkSpeed
- **Type**: int
- **Description**: The maximum speed of the physical device link, in megabits per second.
- **Readonly**: true

### network
- **Type**: Network
- **Description**: The wired network for this device or `null`.
- **Readonly**: true

### hasLink
- **Type**: bool
- **Description**: True if the wired device has a physical link (cable plugged in).
- **Readonly**: true
```

--------------------------------

### next

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Mpris/MprisPlayer

Plays the next song in the playlist. This function may only be called if the player is in a state where playback is possible.

```APIDOC
## next

### Description
Play the next song.
May only be called if the player is in a playable state.

### Signature
`next () : void`
```

--------------------------------

### Executing Processes Detached

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/Quickshell

Launch a process detached from Quickshell using `execDetached`. Arguments must be in separate values, and shell scripts require explicit invocation via `sh -c`.

```javascript
Quickshell.execDetached({
    command: ["sh", "-c", "echo hello"]
});
```

--------------------------------

### Using PersistentProperties for Expandable Panel State

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/PersistentProperties

This snippet shows how to declare and use PersistentProperties to maintain the 'expanderOpen' state of a panel across reloads. The 'id' and 'reloadableId' are crucial for identifying and managing the persistent state.

```Quickshell
PersistentProperties {
  id: persist
  reloadableId: "persistedStates"

  property bool expanderOpen: false
}

Button {
  id: expanderButton
  anchors.centerIn: parent
  text: "toggle expander"
  onClicked: persist.expanderOpen = !persist.expanderOpen
}

Rectangle {
  anchors.top: expanderButton.bottom
  anchors.left: expanderButton.left
  anchors.right: expanderButton.right
  height: 100

  color: "lightblue"
  visible: persist.expanderOpen
}
```

--------------------------------

### Using MarginWrapperManager for Size and Position

Source: https://quickshell.org/docs/v0.3.0/guide/size-position

This snippet shows how `MarginWrapperManager` simplifies size and position management between a container and its child. It automatically handles the relationship, preventing binding loops and reducing boilerplate code.

```qml
Item {
  MarginWrapperManager { margin: 5 }

  // Automatically detected by MarginWrapperManager as the
  // primary child of the container and sized accordingly.
  Rectangle {
    implicitWidth: 50
    implicitHeight: 50
  }
}
```

--------------------------------

### Conditionally Display QML Components with Loader

Source: https://quickshell.org/docs/v0.3.0/guide/faq

Use a Loader to dynamically switch between different QML components based on a condition. This is useful for unloading component trees to save memory.

```qml
Loader {
  readonly property Component thing1: ...
  readonly property Component thing2: ...

  sourceComponent: condition ? thing1 : thing2
}
```

--------------------------------

### PwNodePeakMonitor Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Pipewire/PwNodePeakMonitor

This snippet details the properties available for the PwNodePeakMonitor. These properties allow you to inspect and control the peak monitoring functionality.

```APIDOC
## PwNodePeakMonitor Properties

### `peak` (real, readonly)
Maximum value of the peak across all channels.

### `node` (PwNode)
The PipeWire node to monitor. This must be an audio node.

### `enabled` (bool)
Controls whether the monitor is actively capturing and computing peaks. Defaults to `true`.

### `channels` (list<PwAudioChannel>, readonly)
Provides information about the channel positions for the captured audio format. The length of this list matches the number of channels.

### `peaks` (list<real>, readonly)
An array containing per-channel peak noise levels, ranging from 0.0 to 1.0. The length of this list matches the number of channels. Note that the channel's volume does not affect this property.
```

--------------------------------

### PwLink Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Pipewire/PwLink

PwLink is an uncreatable QtObject that represents a single link between Pipewire nodes. It exposes several read-only properties.

```APIDOC
## PwLink Properties

### target
- **Type**: PwNode
- **Readonly**: true
- **Description**: The node that is _receiving_ information (the sink).

### id
- **Type**: int
- **Readonly**: true
- **Description**: The Pipewire object ID of the link. Useful for debugging with `pw-cli i <id>`.

### state
- **Type**: PwLinkState
- **Readonly**: true
- **Description**: The current state of the link. This property is only valid if the node is bound using PwObjectTracker.

### source
- **Type**: PwNode
- **Readonly**: true
- **Description**: The node that is _sending_ information (the source).
```

--------------------------------

### Time Logic Component

Source: https://quickshell.org/docs/v0.3.0/guide/introduction

Encapsulates the logic for fetching and updating the current time using a process and timer.

```qml
// Time.qml
import Quickshell
import Quickshell.Io
import QtQuick

Scope {
  id: root
  property string time

  Process {
    id: dateProc
    command: ["date"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: root.time = this.text
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: dateProc.running = true
  }
}
```

--------------------------------

### Process Events

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/Process

Event handlers for process lifecycle events.

```APIDOC
## Signals

### exited (exitCode, exitStatus)

#### Parameters
- **exitCode** (int) - The exit code of the process.
- **exitStatus** (any) - The exit status of the process.

### started ()

_No details provided_
```

--------------------------------

### WlSessionLockSurface Transparent Color Workaround

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Wayland/WlSessionLockSurface

Use a colored content item over a transparent window as a workaround for potential issues with transparent colors on some systems. Avoid transparent lock screens as compositors may ignore them.

```javascript
ProxyWindow {
  Rectangle {
    anchors.fill: parent
    color: "#20ffffff"

    // your content here
  }
}
```

--------------------------------

### BluetoothAdapter Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Bluetooth/BluetoothAdapter

This section details the properties available for the BluetoothAdapter, which represent its current state and configurable options.

```APIDOC
## BluetoothAdapter Properties

### Description
Provides information about the Bluetooth adapter's status and configuration.

### Properties
- **dbusPath** (string, readonly): The DBus path of the adapter under the `org.bluez` system service.
- **adapterId** (string, readonly): The internal ID of the adapter (e.g., “hci0”).
- **devices** (ObjectModel <BluetoothDevice>, readonly): A collection of Bluetooth devices connected to this adapter.
- **pairable** (bool): Controls whether the adapter is accepting incoming pairing requests. Defaults to true.
- **pairableTimeout** (int): The timeout in seconds for how long the adapter remains pairable after being set to true. A value of 0 means it stays pairable indefinitely. Defaults to 0.
- **discoverable** (bool): Indicates if the adapter can be discovered by other Bluetooth devices.
- **discovering** (bool, readonly): Indicates if the adapter is currently scanning for new devices.
- **discoverableTimeout** (int): The timeout in seconds for how long the adapter remains discoverable after being set to true. A value of 0 means it stays discoverable indefinitely.
- **enabled** (bool): Indicates if the adapter is currently enabled. More detailed state is available from `.state`.
- **name** (string, readonly): The system-provided name of the adapter.
- **state** (BluetoothAdapterState, readonly): The detailed power state of the adapter.
```

--------------------------------

### Define a Basic QML Component

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/BoundComponent

This snippet defines a simple QML component named MouseArea with a required color property and a nested Rectangle that fills its parent and adopts its color. This serves as a component that can be loaded by BoundComponent.

```qml
MouseArea {
  required property color color;
  width: 100
  height: 100

  Rectangle {
    anchors.fill: parent
    color: parent.color
  }
}
```

--------------------------------

### mapFromItem (x, y)

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/QsWindow

Maps the given point (x, y) in the coordinate space of `item` to one in the coordinate space of this window. This function does not update reactively.

```APIDOC
## mapFromItem (item, x, y)

### Description
Maps the given point in the coordinate space of `item` to one in the coordinate space of this window. Does not update reactively.
Equivalent to calling `window.contentItem.mapFromItem(item, x, y)`

### Parameters
#### Path Parameters
- **item** (Item) - Required - The item whose coordinate space to map from.
- **x** (real) - Required - The x-coordinate to map.
- **y** (real) - Required - The y-coordinate to map.

### Returns
- **point** (point) - The mapped point in the window's coordinate space.
```

--------------------------------

### PolkitAgent Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Polkit/PolkitAgent

This section details the properties available on the PolkitAgent QtObject, which provide information about its state and configuration.

```APIDOC
## PolkitAgent Properties

### `isRegistered` (bool, readonly)
Indicates whether the agent registered successfully and is in use.

### `path` (string)
The D-Bus path that this agent listener will use. If not set, a default of /org/quickshell/Polkit will be used.

### `flow` (AuthFlow, readonly)
The current authentication state if an authentication request is active. Null when no authentication request is active.

### `isActive` (bool, readonly)
Indicates an ongoing authentication request. If this is true, other properties such as `flow` will also be populated with relevant information.
```

--------------------------------

### Toplevel Functions

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Wayland/Toplevel

Functions available for interacting with Toplevel objects.

```APIDOC
## Toplevel Functions

### activate ()
- **Description**: Request that this toplevel is activated. The request may be ignored by the compositor.
- **Returns**: void

### close ()
- **Description**: Request that this toplevel is closed. The request may be ignored by the compositor or the application.
- **Returns**: void

### fullscreenOn (screen)
- **Description**: Request that this toplevel is fullscreened on a specific screen. The request may be ignored by the compositor.
- **Parameters**:
  - **screen**: ShellScreen - The screen to fullscreen on.
- **Returns**: void

### setRectangle (window, rect)
- **Description**: Provide a hint to the compositor where the visual representation of this toplevel is relative to a quickshell window. This hint can be used visually in operations like minimization.
- **Parameters**:
  - **window**: QtObject - The window object.
  - **rect**: rect - The rectangle hint.
- **Returns**: void

### unsetRectangle ()
- **Description**: Unsets the rectangle hint for the toplevel.
- **Returns**: void
```

--------------------------------

### QsMenuAnchor Functions

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/QsMenuAnchor

Functions to control the opening and closing of menus associated with a QsMenuAnchor.

```APIDOC
## QsMenuAnchor Functions

### close ()
Close the open menu.

### open ()
Open the given menu on this menu Requires that is valid.
```

--------------------------------

### IdleMonitor Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Wayland/IdleMonitor

Configuration and status properties for the IdleMonitor.

```APIDOC
## IdleMonitor: QtObject 
`import Quickshell.Wayland`

An idle monitor detects when the user stops providing input for a period of time.
Using an idle monitor requires the compositor support the ext-idle-notify-v1 protocol.

### Properties

* **respectInhibitors** : bool
  When set to true, will depend on both user interaction and active idle inhibitors. When false, the value will depend solely on user interaction. Defaults to true.

* **timeout** : real
  The amount of time in seconds the idle monitor should wait before reporting an idle state.
  Defaults to zero, which reports idle status immediately.

* **isIdle** : bool readonly
  This property is true if the user has been idle for at least . What is considered to be idle is influenced by .

* **enabled** : bool
  If the idle monitor should be enabled. Defaults to true.
```

--------------------------------

### mapFromItem (x, y, width, height)

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/QsWindow

Maps the given rect (x, y, width, height) in the coordinate space of `item` to one in the coordinate space of this window. This function does not update reactively.

```APIDOC
## mapFromItem (item, x, y, width, height)

### Description
Maps the given rect in the coordinate space of `item` to one in the coordinate space of this window. Does not update reactively.
Equivalent to calling `window.contentItem.mapFromItem(item, x, y, width, height)`

### Parameters
#### Path Parameters
- **item** (Item) - Required - The item whose coordinate space to map from.
- **x** (real) - Required - The x-coordinate of the rectangle.
- **y** (real) - Required - The y-coordinate of the rectangle.
- **width** (real) - Required - The width of the rectangle.
- **height** (real) - Required - The height of the rectangle.

### Returns
- **rect** (rect) - The mapped rectangle in the window's coordinate space.
```

--------------------------------

### resourcesLost

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/QsWindow

This signal is emitted when resources a window depends on to display are lost, or could not be acquired during window creation.

```APIDOC
## resourcesLost

### Description
This signal is emitted when resources a window depends on to display are lost, or could not be acquired during window creation. The most common trigger for this signal is a lack of VRAM when creating or resizing a window. Following this signal, `windowConnected` will be sent.

### Parameters
_No parameters provided._

### Returns
_No return value._
```

--------------------------------

### Retrieve Return Values from IPC Handler Functions

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/IpcHandler

After invoking functions that return values, use 'qs ipc call' again to retrieve those values. The command will output the result of the function call.

```bash
$ qs ipc call rect getColor
#ffffa500
$ qs ipc call rect getAngle
40.5
$ qs ipc call rect getRadius
30
```

--------------------------------

### QsMenuEntry Triggered Signal

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/QsMenuEntry

Emits a signal when the menu entry is triggered or clicked.

```APIDOC
## Signal: triggered
Send a trigger/click signal to the menu entry.

### Parameters
None
```

--------------------------------

### Checking for Theme Icon

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/Quickshell

Check if a specified icon exists in the system's icon theme using `hasThemeIcon`.

```javascript
Quickshell.hasThemeIcon("application-icon");
```

--------------------------------

### DesktopEntries.heuristicLookup

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/DesktopEntries

Looks up a desktop entry by name using a heuristic approach. This function is generally more useful than byId() as it attempts to guess the entry if an exact match is not found. It may return null.

```APIDOC
## heuristicLookup (name)

### Description
Look up a desktop entry by name using heuristics. Unlike byId(), if no exact matches are found this function will try to guess - potentially incorrectly. May return null.

### Parameters
#### Path Parameters
- **name** (string) - Required - The name of the desktop entry to look up.
```

--------------------------------

### Send a Signal to a Process

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/Process

Sends a specified integer signal to the running process. The signal is only sent if the process is currently running.

```javascript
process.signal(15);
```

--------------------------------

### Use Implicit QML Signal Handlers

Source: https://quickshell.org/docs/v0.3.0/guide/qml-language

QML implicitly defines `on<SignalName>` properties for every signal, providing a concise way to handle signals directly within the object definition.

```qml
ColumnLayout {
  property int clicks: 0

  function updateText() {
    clicks += 1;
    label.text = `the button has been clicked ${clicks} times!`;
  }

  Button {
    text: "click me"
    onClicked: updateText()
  }

  Text {
    id: label
    text: "the button has not been clicked"
  }
}
```

--------------------------------

### HyprlandMonitor Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Hyprland/HyprlandMonitor

This section details the properties available on the HyprlandMonitor object. These properties provide information about the monitor's state and configuration.

```APIDOC
## HyprlandMonitor Properties

### x
- **Type**: int
- **Readonly**: true

### activeWorkspace
- **Type**: HyprlandWorkspace
- **Readonly**: true
- **Description**: The currently active workspace on this monitor. May be null.

### name
- **Type**: string
- **Readonly**: true

### description
- **Type**: string
- **Readonly**: true

### height
- **Type**: int
- **Readonly**: true

### focused
- **Type**: bool
- **Readonly**: true
- **Description**: If the monitor is currently focused.

### y
- **Type**: int
- **Readonly**: true

### id
- **Type**: int
- **Readonly**: true

### lastIpcObject
- **Type**: unknown
- **Readonly**: true
- **Description**: Last json returned for this monitor, as a javascript object. This is _not_ updated unless the monitor object is fetched again from Hyprland. If you need a value that is subject to change and does not have a dedicated property, run Hyprland.refreshMonitors() and wait for this property to update.

### width
- **Type**: int
- **Readonly**: true

### scale
- **Type**: real
- **Readonly**: true
```

--------------------------------

### ObjectModel Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/ObjectModel

The ObjectModel has a `values` property that provides a reactive QML list view of its content.

```APIDOC
## Properties

### values

- **Type**: list <QtObject>
- **Access**: readonly
- **Description**: The content of the object model, as a QML list. The values of this property will always be of the type of the model.
```

--------------------------------

### refreshWorkspaces

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Hyprland/Hyprland

Refreshes Hyprland workspace information. Useful when workspace state might be invalidated.

```APIDOC
  * refreshWorkspaces () : void
Refresh workspace information.
Many actions that will invalidate workspace state don’t send events, so this function is available if required.
```

--------------------------------

### Overriding Application ID with AppId Pragma

Source: https://quickshell.org/docs/v0.3.0/guide/advanced

The AppId pragma allows overriding the default application ID used by Quickshell, which is useful for custom icons on floating windows. This can also be set using the QS_APP_ID environment variable.

```qml
//@ pragma AppId <appid>
```

--------------------------------

### previous

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Mpris/MprisPlayer

Plays the previous song in the playlist or restarts the current song. This function may only be called if the player is in a state where playback is possible.

```APIDOC
## previous

### Description
Play the previous song, or go back to the beginning of the current one.
May only be called if the player is in a playable state.

### Signature
`previous () : void`
```

--------------------------------

### mapFromItem (point)

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/QsWindow

Maps the given point in the coordinate space of `item` to one in the coordinate space of this window. This function does not update reactively.

```APIDOC
## mapFromItem (item, point)

### Description
Maps the given point in the coordinate space of `item` to one in the coordinate space of this window. Does not update reactively.
Equivalent to calling `window.contentItem.mapFromItem(item, point)`

### Parameters
#### Path Parameters
- **item** (Item) - Required - The item whose coordinate space to map from.
- **point** (point) - Required - The point to map.

### Returns
- **point** (point) - The mapped point in the window's coordinate space.
```

--------------------------------

### Execute Code on Component Completion

Source: https://quickshell.org/docs/v0.3.0/guide/qml-language

Use the `Component.onCompleted` attached signal handler to execute code once an object has been fully instantiated and added to the scene.

```QML
Text {
  Component.onCompleted: {
    text = "hello!"
  }
}
```

--------------------------------

### PowerProfiles Interface

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.UPower/PowerProfiles

The PowerProfiles interface provides access to system power management features. It allows users to query information about available power profiles, understand performance degradation, and manage the current power profile.

```APIDOC
## PowerProfiles: QtObject 
singleton
`import Quickshell.Services.UPower`
An interface to the UPower power profiles daemon, which can be used to view and manage power profiles.
The power profiles daemon must be installed to use this service. Installing UPower does not necessarily install the power profiles daemon.

### Properties

* **hasPerformanceProfile** (bool, readonly)
  If the system has a performance profile.
  If this property is false, your system does not have a performance profile known to power-profiles-daemon.

* **degradationReason** (PerformanceDegradationReason, readonly)
  If power-profiles-daemon detects degraded system performance, the reason for the degradation will be present here.

* **holds** (list, readonly)
  Power profile holds created by other applications.
  This property returns a `powerProfileHold` object, which has the following properties:
    * `profile` - The PowerProfile held by the application.
    * `applicationId` - A string identifying the application
    * `reason` - The reason the application has given for holding the profile.
  Applications may “hold” a power profile in place for their lifetime, such as a game holding Performance mode or a system daemon holding Power Saver mode when reaching a battery threshold. If the user selects a different profile explicitly (e.g. by setting ) all holds will be removed.
  Multiple applications may hold a power profile, however if multiple applications request profiles than `PowerSaver` will win over `Performance`. Only `Performance` and `PowerSaver` profiles may be held.

* **profile** (PowerProfile)
  The current power profile.
  This property may be set to change the system’s power profile, however it cannot be set to `Performance` unless  is true.
```

--------------------------------

### HyprlandToplevel Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Hyprland/HyprlandToplevel

This section details the properties available on the HyprlandToplevel object.

```APIDOC
## HyprlandToplevel Properties

### handle
- Type: `HyprlandToplevel` (readonly)
- Description: The toplevel handle, exposing the Hyprland toplevel. Will be null until the address is reported.

### title
- Type: `string` (readonly)
- Description: The title of the toplevel.

### address
- Type: `string` (readonly)
- Description: Hexadecimal Hyprland window address. Will be an empty string until the address is reported.

### lastIpcObject
- Type: `unknown` (readonly)
- Description: Last json returned for this toplevel, as a javascript object. This is _not_ updated unless the toplevel object is fetched again from Hyprland. If you need a value that is subject to change and does not have a dedicated property, run Hyprland.refreshToplevels() and wait for this property to update.

### workspace
- Type: `HyprlandWorkspace` (readonly)
- Description: The current workspace of the toplevel (might be null).

### monitor
- Type: `HyprlandMonitor` (readonly)
- Description: The current monitor of the toplevel (might be null).

### activated
- Type: `bool` (readonly)
- Description: Whether the toplevel is active or not.

### urgent
- Type: `bool` (readonly)
- Description: Whether the client is urgent or not.

### wayland
- Type: `Toplevel` (readonly)
- Description: The wayland toplevel handle. Will be null intil the address is reported.
```

--------------------------------

### Process Environment Variables

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/Process

Manages environment variables for a process. Variables can be added by assigning a string value or removed by assigning `null`. The object must be wrapped in parentheses.

```javascript
environment: ({
  ADDED: "value",
  REMOVED: null,
  "i'm different": "value",
})
```

--------------------------------

### Conditional Compilation with If/Endif Pragmas

Source: https://quickshell.org/docs/v0.3.0/guide/advanced

Employ If/Endif pragmas for conditional compilation, similar to C preprocessor directives. Conditions are evaluated as JavaScript expressions using provided helper functions.

```qml
//@ if <condition>
//@ endif
```

--------------------------------

### Create an Inline QML Component

Source: https://quickshell.org/docs/v0.3.0/guide/qml-language

Define components directly within another QML file for local use. These inline components can reference IDs from the parent file but are scoped to that file.

```QML
ColumnLayout {
  id: layout
  property real textPointSize: 10

  MyText { text: "Thing 1" }
  MyText { text: "Thing 2" }
  MyText { text: "Thing 3" }

  component MyText: Text {
    // applied to all MyText instances
    color: "red"
    // references an id outside of the component
    font.pointSize: layout.textPointSize
  }
}
```

--------------------------------

### UPowerDevice Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.UPower/UPowerDevice

This section details the various properties available for a UPowerDevice. These properties provide information about the device's status, capabilities, and health.

```APIDOC
## UPowerDevice Properties

### isLaptopBattery
- **Type**: bool
- **Access**: readonly
- **Description**: Indicates if the device is a laptop battery. Useful for validating if a device is a battery.

### ready
- **Type**: bool
- **Access**: readonly
- **Description**: Indicates if device statistics have been queried. True for most devices, but may be false for the default device initially.

### timeToEmpty
- **Type**: real
- **Access**: readonly
- **Description**: Estimated time in seconds until the device is fully discharged. Set to `0` if charging.

### nativePath
- **Type**: string
- **Access**: readonly
- **Description**: The OS-specific native path of the device.

### type
- **Type**: DeviceType
- **Access**: readonly
- **Description**: The type of the device (e.g., Battery, Monitor).

### powerSupply
- **Type**: bool
- **Access**: readonly
- **Description**: Indicates if the device is a power supply for the computer and can provide charge.

### healthSupported
- **Type**: bool
- **Access**: readonly
- **Description**: Indicates if the health of the device is supported.

### timeToFull
- **Type**: real
- **Access**: readonly
- **Description**: Estimated time in seconds until the device is fully charged. Set to `0` if discharging.

### energyCapacity
- **Type**: real
- **Access**: readonly
- **Description**: Maximum energy capacity of the device in watt-hours.

### state
- **Type**: UPowerDeviceState
- **Access**: readonly
- **Description**: The current state of the device (e.g., Discharging, Charging, Full).

### iconName
- **Type**: string
- **Access**: readonly
- **Description**: Name of the icon representing the device's current state, or an empty string if not provided.

### model
- **Type**: string
- **Access**: readonly
- **Description**: Model name of the device. May not be useful for internal devices.

### isPresent
- **Type**: bool
- **Access**: readonly
- **Description**: Indicates if the power source is present. Useful for hot-removable batteries. Invalid if device `type` is not `Battery`.

### percentage
- **Type**: real
- **Access**: readonly
- **Description**: Current charge level as a percentage.

### energy
- **Type**: real
- **Access**: readonly
- **Description**: Current energy level of the device in watt-hours.

### changeRate
- **Type**: real
- **Access**: readonly
- **Description**: Rate of energy change in watts (positive when charging, negative when discharging).

### healthPercentage
- **Type**: real
- **Access**: readonly
- **Description**: Health of the device as a percentage of its original health.
```

--------------------------------

### QML `id` Property Usage

Source: https://quickshell.org/docs/v0.3.0/guide/qml-language

Demonstrates the use of the `id` property to assign a unique name to QML objects, enabling them to be referenced within the current file. It highlights how `id` facilitates inter-object communication.

```qml
ColumnLayout {
  Text {
    id: text
    text: "Hello World!"
  }

  Button {
    text: "Make the text red";
    onClicked: text.color = "red";
  }
}
```

--------------------------------

### MprisPlayer Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Mpris/MprisPlayer

This section details the various properties of the MprisPlayer, which represent the state and capabilities of a media player.

```APIDOC
## MprisPlayer Properties

### `isPlaying` (bool)
True if the player is currently playing. Setting this property can be used to play or pause the track.

### `trackAlbumArtist` (string, readonly)
The album artist of the current track.

### `shuffleSupported` (bool, readonly)
Indicates if shuffle functionality is supported.

### `lengthSupported` (bool, readonly)
Indicates if the track length information is supported.

### `position` (real)
The current playback position in seconds. Can be set if `canSeek` and `positionSupported` are true.

### `trackArtist` (string, readonly)
The artist of the current track.

### `uniqueId` (int, readonly)
A unique identifier for the current track within the player.

### `canPlay` (bool, readonly)
Indicates if the player can play tracks.

### `loopSupported` (bool, readonly)
Indicates if loop functionality is supported.

### `desktopEntry` (string, readonly)
The desktop entry name of the media player.

### `metadata` (unknown, readonly)
Metadata of the current track.

### `canSeek` (bool, readonly)
Indicates if seeking within the track is supported.

### `positionSupported` (bool, readonly)
Indicates if the playback position is supported.

### `canPause` (bool, readonly)
Indicates if the player can pause tracks.

### `dbusName` (string, readonly)
The DBus service name of the player.

### `trackAlbum` (string, readonly)
The album of the current track.

### `length` (real, readonly)
The total length of the current track in seconds.

### `minRate` (real, readonly)
The minimum playback rate supported.

### `maxRate` (real, readonly)
The maximum playback rate supported.

### `rate` (real)
The current playback rate. Can be set to values between `minRate` and `maxRate`.

### `trackArtists` (string, readonly)
Deprecated. Use `trackArtist` instead.

### `volume` (real)
The volume of the player, from 0.0 to 1.0. Can be set if `volumeSupported` is true.

### `trackTitle` (string, readonly)
The title of the current track.

### `volumeSupported` (bool, readonly)
Indicates if volume control is supported.

### `canGoPrevious` (bool, readonly)
Indicates if navigating to the previous track is supported.

### `loopState` (MprisLoopState)
The current loop state of the player. Can be set if supported.

### `canControl` (bool, readonly)
Indicates if the player has general control capabilities.

### `canRaise` (bool, readonly)
Indicates if the player window can be raised.

### `supportedUriSchemes` (list<string>, readonly)
URI schemes supported by the player for opening media.

### `canSetFullscreen` (bool, readonly)
Indicates if setting fullscreen mode is supported.

### `shuffle` (bool)
Indicates if shuffle mode is currently enabled. Can be set if supported.

### `trackArtUrl` (string, readonly)
The URL of the current track's artwork.

### `canGoNext` (bool, readonly)
Indicates if navigating to the next track is supported.

### `fullscreen` (bool)
Indicates if the player is currently in fullscreen mode. Can be set if supported.
```

--------------------------------

### PwNodeAudio Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Pipewire/PwNodeAudio

PwNodeAudio exposes properties for audio channels, mute state, and volume control. Note that these properties are only valid when the node is bound using PwObjectTracker.

```APIDOC
## PwNodeAudio Properties

### channels
- **Type**: list <PwAudioChannel>
- **Readonly**: true
- **Description**: The audio channels present on the node. This property is invalid unless the node is bound using PwObjectTracker.

### muted
- **Type**: bool
- **Description**: If the node is currently muted. Setting this property changes the mute state. This property is invalid unless the node is bound using PwObjectTracker.

### volumes
- **Type**: list <real>
- **Description**: The volumes of each audio channel individually. Each entry corresponds to the volume of the channel at the same index in `channels`. `volumes` and `channels` will always be the same length. This property is invalid unless the node is bound using PwObjectTracker.

### volume
- **Type**: real
- **Description**: The average volume over all channels of the node. Setting this property modifies the volume of all channels proportionately. This property is invalid unless the node is bound using PwObjectTracker.
```

--------------------------------

### Applying Background Blur with BackgroundEffect

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Wayland/BackgroundEffect

Use this snippet to apply a background blur effect to a PanelWindow. Ensure the `blurRegion` is set to the content item of the window you wish to blur.

```qml
PanelWindow {
  id: root
  color: "#80000000"

  BackgroundEffect.blurRegion: Region { item: root.contentItem }
}
```

--------------------------------

### File Operations

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/FileView

Methods for reloading, writing, and waiting for file operations to complete.

```APIDOC
## reload ()

### Description
Unloads the currently loaded file and reloads it, typically in response to external changes.
Blocking behavior depends on internal flags.

### Returns
- void
```

```APIDOC
## writeAdapter ()

### Description
Writes the content of the current FileView instance to the selected file.

### Returns
- void
```

```APIDOC
## waitForJob ()

### Description
Blocks all operations until the currently running file load operation completes.
Refer to internal documentation for details and warnings about blocking.

### Returns
- bool: True if the job completed, false otherwise (or if blocking is not enforced).
```

--------------------------------

### NMSettings Functions

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Networking/NMSettings

Functions available for the NMSettings object.

```APIDOC
## Functions

### clearSecrets ()
- Returns: void
- Description: Clear all of the secrets belonging to the settings.

### forget ()
- Returns: void
- Description: Delete the settings.

### read ()
- Returns: unknown
- Description: Get the settings map describing this network configuration. This will never include any secrets required for connection to the network, as those are often protected.

### write (settings)
- Parameters:
  - settings: The settings map to update the connection with.
- Returns: void
- Description: Update the connection with new settings and save the connection to disk. Only changed fields need to be included. Writing a setting to `null` will remove the setting or reset it to its default. Secrets may be part of the update request, and will be either stored in persistent storage or sent to a Secret Agent for storage, depending on the flags associated with each secret.
```

--------------------------------

### Avoiding Bindings with Component.onCompleted in QML

Source: https://quickshell.org/docs/v0.3.0/guide/qml-language

Shows how to set a property value during initialization without creating a binding. Use `Component.onCompleted` for one-time assignments.

```qml
Item {
  property string theProperty: "initial value"

  Text {
    // text: "Right now, theProperty is: " + theProperty
    Component.onCompleted: text = "At creation time, theProperty is: " + theProperty
  }
}
```

--------------------------------

### FileView Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/FileView

Details on the configurable properties of the FileView component, including write blocking, adapters, preloading, atomic writes, change watching, path, loaded status, and error printing.

```APIDOC
## Properties [?]
  * blockWrites  : bool
If true (default false), all calls to setText() or setData() will block the UI thread until the write succeeds or fails.
Blocking operations should be used carefully to avoid stutters and other performance degradations. Blocking means that your interface **WILL NOT FUNCTION** during the call.
  * adapter  : FileViewAdapter default
In addition to directly reading/writing the file as text, _adapters_ can be used to expose a file’s content in new ways.
An adapter will automatically be given the loaded file’s content. Its state may be saved with writeAdapter().
Currently the only adapter is JsonAdapter.
  * preload  : bool
If the file should be loaded in the background immediately when set. Defaults to true.
This may either increase or decrease the amount of time it takes to load the file depending on how large the file is, how fast its storage is, and how you access its data.
  * atomicWrites  : bool
If true (default), all calls to setText() or setData() will be performed atomically, meaning if the write fails for any reason, the file will not be modified.
This works by creating another file with the desired content, and renaming it over the existing file if successful.
  * watchChanges  : bool
If true (defaule false), fileChanged() will be called whenever the content of the file changes on disk, including when setText() or setData() are used.
You can reload the file’s content whenever it changes on disk like so:
```
FileView {
  // ...
  watchChanges: true
  onFileChanged: this.reload()
}
```

  * path  : string
The path to the file that should be read, or an empty string to unload the file.
  * loaded  : bool readonly
If a file is currently loaded, which may or may not be the one currently specified by .
If a file is loaded,  is changed, and a new file is loaded, this property will stay true the whole time. If  is set to an empty string to unload the file it will become false.
  * blockLoading  : bool
If text() and data() should block all operations until the file is loaded. Defaults to false.
If the file is already loaded, no blocking will occur. If a file was loaded, and  was changed to a new file, no blocking will occur.
Blocking operations should be used carefully to avoid stutters and other performance degradations. Blocking means that your interface **WILL NOT FUNCTION** during the call.
**We recommend you use a blocking load ONLY for files loaded before the windows of your shell are loaded, which happens after`Component.onCompleted` runs for the root component of your shell.**
The most reasonable use case would be to load things like configuration files that the program must have available.
  * blockAllReads  : bool
If text() and data() should block all operations while a file loads. Defaults to false.
This is nearly identical to , but will additionally block when a file is loaded and  changes. We cannot think of a valid use case for this. You almost definitely want .
  * printErrors  : bool
If true (default), read or write errors will be printed to the quickshell logs. If false, all known errors will not be printed.
```

--------------------------------

### Monitoring file changes and reloading

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/FileView

Configure FileView to automatically reload its content when the file on disk changes. This is achieved by setting `watchChanges` to true and using the `onFileChanged` signal to trigger a `reload()` operation.

```javascript
FileView {
  // ...
  watchChanges: true
  onFileChanged: this.reload()
}
```

--------------------------------

### Write Data to Process Stdin

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/Process

Writes the given string data to the process's standard input. This operation does nothing if the process is not running.

```javascript
process.write("input data\n");
```

--------------------------------

### Clock Widget Component

Source: https://quickshell.org/docs/v0.3.0/guide/introduction

A reusable QML component for displaying time, requiring a 'time' property to be set by its parent.

```qml
// ClockWidget.qml
import QtQuick

Text {
  // A property the creator of this type is required to set.
  // Note that we could just set `text` instead, but don't because your
  // clock probably will not be this simple.
  required property string time

  text: time
}
```

--------------------------------

### I3Monitor Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.I3/I3Monitor

This section details the read-only properties available for an I3Monitor object. These properties provide information about the monitor's state and configuration.

```APIDOC
## I3Monitor Properties

### Description

Provides access to various properties of an I3 monitor.

### Properties

- **focusedWorkspace** (I3Workspace readonly): The currently focused workspace on this monitor. Deprecated: See .
- **x** (int readonly): The X coordinate of this monitor within the monitor layout.
- **activeWorkspace** (I3Workspace readonly): The currently active workspace on this monitor. May be null.
- **name** (string readonly): The name of this monitor.
- **power** (bool readonly): Indicates whether this monitor is turned on.
- **height** (int readonly): The height of this monitor in pixels.
- **focused** (bool readonly): Indicates whether this monitor is currently in focus.
- **id** (int readonly): The unique identifier for this monitor.
- **lastIpcObject** (unknown readonly): The last JSON object received for this monitor from i3/Sway's `output` event.
- **y** (int readonly): The Y coordinate of this monitor within the monitor layout.
- **width** (int readonly): The width of this monitor in pixels.
- **scale** (real readonly): The scaling factor of this monitor (1.0 for native resolution).
```

--------------------------------

### HyprlandFocusGrab Object

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Hyprland/HyprlandFocusGrab

The HyprlandFocusGrab object provides properties to control and monitor input focus grabs. It can be enabled to allow specified windows to receive input normally and retain focus. The 'active' property controls the grab state, and the 'windows' property lists the whitelisted windows.

```APIDOC
## HyprlandFocusGrab: QtObject 

Object for managing input focus grabs via the hyprland_focus_grab_v1 wayland protocol.
When enabled, all of the windows listed in the `windows` property will receive input normally, and will retain keyboard focus even if the mouse is moved off of them. When areas of the screen that are not part of a listed window are clicked or touched, the grab will become inactive and emit the cleared signal.
This is useful for implementing dismissal of popup type windows.

### Properties
  * active  : bool
If the focus grab is active. Defaults to false.
When set to true, an input grab will be created for the listed windows.
This property will change to false once the grab is dismissed. It will not change to true until the grab begins, which requires at least one visible window.
  * windows  : list <QtObject>
The list of windows to whitelist for input.

### Signals
  * cleared ()
Sent whenever the compositor clears the focus grab.
This may be in response to all windows being removed from the list or simultaneously hidden, in addition to a normal clear.
```

--------------------------------

### Auto-Restart Process

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/Process

Configures a process to automatically restart if it stops running. This is useful for maintaining a continuously running service.

```javascript
Process {
  running: true
  onRunningChanged: if (!running) running = true
}
```

--------------------------------

### QsMenuAnchor Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/QsMenuAnchor

Properties of the QsMenuAnchor component, including its anchor, visibility, and associated menu.

```APIDOC
## QsMenuAnchor Properties

### anchor : PopupAnchor readonly
The menu’s anchor / positioner relative to another window. The menu will not be shown until it has a valid anchor.

### visible : bool readonly
If the menu is currently open and visible.

### menu : QsMenuHandle
The menu that should be displayed on this anchor.
```

--------------------------------

### Automatic Property Binding in QML

Source: https://quickshell.org/docs/v0.3.0/guide/qml-language

Demonstrates automatic property binding where changes in one property automatically update another. Use when a property's value depends on other properties.

```qml
Item {
  property int clicks: 0

  Button {
    text: `clicks: ${clicks}`
    onClicked: clicks += 1
  }
}
```

--------------------------------

### NMSettings Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Networking/NMSettings

Properties of the NMSettings object.

```APIDOC
## Properties

### uuid
- Type: string
- Readonly: true
- Description: A universally unique identifier for the connection.

### id
- Type: string
- Readonly: true
- Description: The human-readable unique identifier for the connection.
```

--------------------------------

### PwNode Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Pipewire/PwNode

The PwNode object exposes several read-only properties to provide information about a Pipewire node. These properties allow users to query the node's type, audio capabilities, status, and associated metadata.

```APIDOC
## PwNode Properties

### Description

Provides information about a Pipewire node, including its type, audio capabilities, name, ID, and readiness status.

### Properties

*   **type** (unknown, readonly): The type of this node. Reflects Pipewire’s media.class.
*   **audio** (PwNodeAudio, readonly): Extra information present only if the node sends or receives audio. If non-null, the node is an audio node.
*   **isSink** (bool, readonly): If `true`, the node accepts audio input. If `false`, the node outputs audio.
*   **isStream** (bool, readonly): If `true`, the node is likely a program. If `false`, it is likely a hardware device.
*   **name** (string, readonly): The node’s name, corresponding to the object’s `node.name` property.
*   **id** (int, readonly): The pipewire object id of the node. Useful for debugging with `pw-cli i <id>`.
*   **ready** (bool, readonly): True if the node is fully bound and ready to use.
*   **nickname** (string, readonly): The node’s nickname, corresponding to the object’s `node.nickname` property. May be empty.
*   **properties** (unknown, readonly): The property set present on the node, as an object containing key-value pairs. Inspectable with `pw-cli i <id>`.
    *   `application.name` - A suggested human readable name for the node.
    *   `application.icon-name` - The name of an icon recommended to display for the node.
    *   `media.name` - A description of the currently playing media.
    *   `media.title` - The title of the currently playing media.
    *   `media.artist` - The artist of the currently playing media.
*   **description** (string, readonly): The node’s description, corresponding to the object’s `node.description` property. May be empty.
```

--------------------------------

### Networking Interface

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Networking/Networking

The Networking interface provides access to network backend functionalities, including managing wireless devices, checking connectivity, and listing network devices.

```APIDOC
## Networking: QtObject 
singleton
`import Quickshell.Networking`
An interface to a network backend (currently only NetworkManager), which can be used to view, configure, and connect to various networks.

### Properties
  * wifiHardwareEnabled  : bool readonly
State of the rfkill hardware block of all wireless devices.
  * wifiEnabled  : bool
Switch for the rfkill software block of all wireless devices.
  * canCheckConnectivity  : bool readonly
True if the  supports connectivity checks.
  * connectivityCheckEnabled  : bool
True if connectivity checking is enabled.
  * backend  : NetworkBackendType readonly
The backend being used to power the Network service.
  * devices  : ObjectModel <NetworkDevice> readonly
A list of all network devices. Networks are exposed through their respective devices.
  * connectivity  : NetworkConnectivity readonly
The result of the last connectivity check.
Connectivity checks may require additional configuration depending on your distro.
This property can be used to determine if network access is restricted or gated behind a captive portal.
If checking for captive portals, checkConnectivity() should be called after the portal is dismissed to update this property.

### Functions
  * checkConnectivity () : void
Re-check the network connectivity state immediately.
This should be invoked after a user dismisses a web browser that was opened to authenticate via a captive portal.
```

--------------------------------

### Invoke IPC Handler Functions

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/IpcHandler

The 'qs ipc call' command is used to invoke functions exposed by an IpcHandler. Provide the target name, function name, and any required arguments. The output shows the return value of the function.

```bash
$ qs ipc call rect setColor orange
$ qs ipc call rect setAngle 40.5
$ qs ipc call rect setRadius 30
```

--------------------------------

### signal

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/Process

Sends a signal to the process if the signal parameter is true, otherwise does nothing.

```APIDOC
## signal (signal)

### Description
Sends a signal to the process.

### Parameters
#### Path Parameters
- **signal** (int) - Required - The signal to send to the process.
```

--------------------------------

### QML Default Property Assignment

Source: https://quickshell.org/docs/v0.3.0/guide/qml-language

Shows how to assign values to an object's default property without explicitly naming it. This is useful for setting child items or default values.

```qml
Item {
  // normal property
  foo: 3

  // this item is assigned to the outer object's default property
  Item {
  }
}
```

```qml
Item {
  // normal property
  foo: 3

  // this item is assigned to the outer object's default property
  Item {
  }

  // this one is too
  Item {
  }
}
```

--------------------------------

### I3Workspace Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.I3/I3Workspace

This section details the properties of an I3Workspace object. These properties are read-only and provide information about the workspace's state.

```APIDOC
## I3Workspace Properties

### Description
Properties of the I3Workspace object.

### Properties
- **id** (int): The unique ID of this workspace for the i3/Sway launch.
- **focused** (bool): Indicates if this workspace is currently active on a monitor and that monitor is focused.
- **name** (string): The name of the workspace.
- **active** (bool): Indicates if this workspace is currently active on its monitor.
- **urgent** (bool): Indicates if a window in this workspace has an urgent notification.
- **number** (int): The number of this workspace.
- **lastIpcObject** (unknown): The last JSON returned for this workspace, as a JavaScript object. This updates every time a `workspace` event is received from i3/Sway.
- **monitor** (I3Monitor): The monitor this workspace is being displayed on.
```

--------------------------------

### PwLinkState.toString

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Pipewire/PwLinkState

Converts a PwLinkState value to its string representation.

```APIDOC
## Functions

* **toString** (value : PwLinkState) : string
_No details provided_
```

--------------------------------

### Execute a Shell Command

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/Process

Executes a command using the system shell. This is necessary for running shell scripts directly or complex commands.

```javascript
process.exec({
  command: ["sh", "-c", "ls -l | grep .js"]
});
```

--------------------------------

### ToplevelManager Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Wayland/ToplevelManager

The ToplevelManager is a singleton object that exposes properties related to toplevel windows. It allows access to the currently active toplevel window and a collection of all exposed toplevel windows.

```APIDOC
## ToplevelManager

### Properties

*   **activeToplevel**: `Toplevel` (readonly)
    *   Description: The currently active toplevel window or null if none is active. If multiple toplevels are active, this will be the most recently activated one. Compositors typically report only one active toplevel at a time.

*   **toplevels**: `ObjectModel<Toplevel>` (readonly)
    *   Description: An object model containing all toplevel windows exposed by the compositor.
```

--------------------------------

### WlSessionLockSurface Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Wayland/WlSessionLockSurface

This snippet details the properties available for WlSessionLockSurface objects, including visibility, background color, dimensions, and associated screen.

```APIDOC
## WlSessionLockSurface

Surface displayed by a WlSessionLock when it is locked.

### Properties

*   **visible** (bool, readonly): Indicates if the surface has been made visible. Note: SessionLockSurfaces will never become invisible; they will only be destroyed.
*   **color** (color): The background color of the window. Defaults to white. Transparent colors may behave unexpectedly on some systems. Using a colored content item over a transparent window is recommended for workarounds, though transparent locks are generally discouraged and may be ignored by compositors.
*   **height** (int, readonly): The height of the surface.
*   **data** (list<QtObject>, readonly, default): Associated data.
*   **contentItem** (Item, readonly): The content item of the surface.
*   **screen** (ShellScreen, readonly): The screen on which the surface is displayed.
*   **width** (int, readonly): The width of the surface.
```

--------------------------------

### Define a QML Signal

Source: https://quickshell.org/docs/v0.3.0/guide/qml-language

Signals can be explicitly defined using the `signal` keyword, followed by the signal name and its parameters with optional types.

```qml
signal <name>(<paramname>: <type>[, ...])
```

--------------------------------

### Bar Component Using ClockWidget

Source: https://quickshell.org/docs/v0.3.0/guide/introduction

Integrates the ClockWidget into the Bar component, passing the time property for display.

```qml
// Bar.qml
import Quickshell
import Quickshell.Io
import QtQuick

Scope {
  id: root
  property string time

  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData

      anchors {
        top: true
        left: true
        right: true
      }

      implicitHeight: 30

      // the ClockWidget type we just created
      ClockWidget {
        anchors.centerIn: parent
        time: root.time
      }
    }
  }

  Process {
    id: dateProc
    command: ["date"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: root.time = this.text
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: dateProc.running = true
  }
}
```

--------------------------------

### UPower Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.UPower/UPower

This section details the properties available through the UPower service.

```APIDOC
## UPower Properties

### devices

- **Type**: ObjectModel <UPowerDevice>
- **Access**: readonly
- **Description**: All connected UPower devices.

### displayDevice

- **Type**: UPowerDevice
- **Access**: readonly
- **Description**: UPower’s DisplayDevice for your system. Cannot be null, but might not be initialized (check if you need to know). This is an aggregate device and not a physical one, meaning you will not find it in . It is typically the device that is used for displaying information in desktop environments.

### onBattery

- **Type**: bool
- **Access**: readonly
- **Description**: If the system is currently running on battery power, or discharging.
```

--------------------------------

### FloatingWindow Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/FloatingWindow

Properties that can be accessed or modified on a FloatingWindow instance.

```APIDOC
## FloatingWindow Properties

* `maximized` (bool): Whether the window is currently maximized.
* `maximumSize` (size): Maximum window size given to the window system.
* `fullscreen` (bool): Whether the window is currently fullscreen.
* `parentWindow` (QtObject): The parent window of this window. Setting this makes the window a child of the parent, which affects window stacking behavior. This property cannot be changed after the window is visible.
* `minimized` (bool): Whether the window is currently minimized.
* `minimumSize` (size): Minimum window size given to the window system.
* `title` (string): Window title.
```

--------------------------------

### Toplevel Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Wayland/Toplevel

Properties of a Toplevel object, representing a window from another application.

```APIDOC
## Toplevel Properties

### maximized
- **Type**: bool
- **Description**: If the window is currently maximized. Maximization can be requested by setting this property, though it may be ignored by the compositor.

### minimized
- **Type**: bool
- **Description**: If the window is currently minimized. Minimization can be requested by setting this property, though it may be ignored by the compositor.

### appId
- **Type**: string (readonly)
- **Description**: Application identifier for the toplevel window.

### fullscreen
- **Type**: bool
- **Description**: If the window is currently fullscreen. Fullscreen can be requested by setting this property, though it may be ignored by the compositor. Fullscreen can be requested on a specific screen with the fullscreenOn() function.

### activated
- **Type**: bool (readonly)
- **Description**: If the window is currently activated or focused. Activation can be requested with the activate() function.

### title
- **Type**: string (readonly)
- **Description**: The title of the toplevel window.

### parent
- **Type**: Toplevel (readonly)
- **Description**: Parent toplevel if this toplevel is a modal/dialog, otherwise null.

### screens
- **Type**: list <ShellScreen> (readonly)
- **Description**: Screens the toplevel is currently visible on. Screens are listed in the order they have been added by the compositor. Some compositors only list a single screen, even if a window is visible on multiple.
```

--------------------------------

### Set WlrLayershell Layer in PanelWindow

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Wayland/WlrLayershell

Use WlrLayershell as a backend for PanelWindow to attach it to screen edges. The `layer` property determines the shell layer, defaulting to `WlrLayer.Top`.

```qml
PanelWindow {
  // When PanelWindow is backed with WlrLayershell this will work
  WlrLayershell.layer: WlrLayer.Bottom
}
```

--------------------------------

### Signals

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/Quickshell

Signals emitted by Quickshell to indicate state changes.

```APIDOC
## reloadCompleted ()

### Description
The reload sequence has completed successfully.

### Return Value
void
```

```APIDOC
## reloadFailed (errorString)

### Description
The reload sequence has failed.

### Parameters
#### Path Parameters
- **errorString** (string) - Required - A string describing the error.

### Return Value
void
```

```APIDOC
## lastWindowClosed ()

### Description
Sent when the last window is closed. To make the application exit when the last window is closed run `Qt.quit()`.

### Return Value
void
```

--------------------------------

### WindowManager Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.WindowManager/WindowManager

Exposes properties related to window management, such as windowset projections and all tracked windowsets.

```APIDOC
## WindowManager Properties

### `windowsetProjections`

- **Type**: `list<WindowsetProjection>`
- **Access**: `readonly`
- **Description**: All windowset projections tracked by the WM. Does not include internal projections from `screenProjection()`.

### `windowsets`

- **Type**: `list<Windowset>`
- **Access**: `readonly`
- **Description**: All windowsets tracked by the WM across all projections.
```

--------------------------------

### Bar Component Using Time Logic

Source: https://quickshell.org/docs/v0.3.0/guide/introduction

Refactors the Bar component to use a separate Time component for managing time updates.

```qml
// Bar.qml
import Quickshell

Scope {
  // the Time type we just created
  Time { id: timeSource }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData

      anchors {
        top: true
        left: true
        right: true
      }

      implicitHeight: 30

      ClockWidget {
        anchors.centerIn: parent
        // now using the time from timeSource
        time: timeSource.time
      }
    }
  }
}
```

--------------------------------

### Hyprland Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Hyprland/Hyprland

Read-only properties providing information about the current Hyprland state.

```APIDOC
## Properties
  * focusedWorkspace  : HyprlandWorkspace readonly
The currently focused hyprland workspace. May be null.
  * requestSocketPath  : string readonly
Path to the request socket (.socket.sock)
  * toplevels  : ObjectModel <HyprlandToplevel> readonly
All hyprland toplevels
  * usingLua  : bool readonly
True if Hyprland is running in lua mode. Dispatcher syntax changes when using lua.
This property will be false until the Hyprland module is initialized.
  * activeToplevel  : HyprlandToplevel readonly
Currently active toplevel (might be null)
  * eventSocketPath  : string readonly
Path to the event socket (.socket2.sock)
  * workspaces  : ObjectModel <HyprlandWorkspace> readonly
All hyprland workspaces, sorted by id.
Named workspaces have a negative id, and will appear before unnamed workspaces.
  * focusedMonitor  : HyprlandMonitor readonly
The currently focused hyprland monitor. May be null.
  * monitors  : ObjectModel <HyprlandMonitor> readonly
All hyprland monitors.
```

--------------------------------

### Optimize Component Efficiency with Scope

Source: https://quickshell.org/docs/v0.3.0/guide/introduction

Move shared resources like Process and Timer outside of the delegate component using Scope to prevent them from being recreated for each instance. This improves efficiency when dealing with multiple dynamic components.

```qml
import Quickshell
import Quickshell.Io
import QtQuick

Scope {
  Variants {
    model: Quickshell.screens

    delegate: Component {
      PanelWindow {
        required property var modelData
        screen: modelData

        anchors {
          top: true
          left: true
          right: true
        }

        implicitHeight: 30

        Text {
          id: clock
          anchors.centerIn: parent
        }
      }
    }
  }

  Process {
    id: dateProc
    command: ["date"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: clock.text = this.text
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: dateProc.running = true
  }
}
```

--------------------------------

### Define a QML Function

Source: https://quickshell.org/docs/v0.3.0/guide/qml-language

Functions can be declared within QML components and follow property scoping rules. The `return` keyword is required for multiline expressions.

```qml
function <name>(<paramname>[: <type>][, ...])[: returntype] {
  // multiline expression (note that `return` is required)
}
```

--------------------------------

### Internal Pragma for Module Encapsulation

Source: https://quickshell.org/docs/v0.3.0/guide/advanced

Use the Internal pragma at the top of a QML file to restrict its visibility outside its module. This helps in maintaining module boundaries.

```qml
//@ pragma Internal
```

--------------------------------

### QsMenuButtonType.toString

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/QsMenuButtonType

Converts a QsMenuButtonType value to its string representation.

```APIDOC
## Functions [?]
  * toString (value) : string
value: QsMenuButtonType
_No details provided_
```

--------------------------------

### PopupAnchor Functions

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/PopupAnchor

Provides functions to manage the PopupAnchor's behavior, such as updating its anchor point.

```APIDOC
## PopupAnchor Functions

### updateAnchor ()
Update the popup’s anchor rect relative to its parent window. If anchored to an item, popups anchors will not automatically follow the item if its position changes. This function can be called to recalculate the anchors.
```

--------------------------------

### Refresh Workspaces

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.I3/I3

Refreshes the workspace information.

```APIDOC
## refreshWorkspaces ()

### Description
Refresh workspace information.

### Response
#### Success Response (void)
Indicates that workspace information has been refreshed.
```

--------------------------------

### GlobalShortcut Signals

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Hyprland/GlobalShortcut

Signals emitted by the GlobalShortcut type to indicate key press and release events.

```APIDOC
## GlobalShortcut Signals

### `released ()`
Fired when the keybind is released.

### `pressed ()`
Fired when the keybind is pressed.
```

--------------------------------

### DesktopEntry Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/DesktopEntry

Properties of the DesktopEntry object that can be accessed and sometimes modified.

```APIDOC
## DesktopEntry Properties

- **icon** (string): Name of the icon associated with this application. May be empty.
- **noDisplay** (bool): If true, this application should not be displayed in menus and launchers.
- **command** (list<string>): The parsed `Exec` command in the desktop entry. This can be run with `execute()`, or by using this command in `Quickshell.execDetached()` or `Process`. If used in `execDetached` or a `Process`, it should also be passed to the invoked process. See `execute()` for details. The provided command does not invoke a terminal even if `runInTerminal` is true.
- **categories** (list<string>): Categories associated with the desktop entry.
- **name** (string): The name of the application.
- **runInTerminal** (bool): If the application should run in a terminal.
- **actions** (list<DesktopAction> readonly): Readonly list of desktop actions available for this entry.
- **keywords** (list<string>): Keywords associated with the desktop entry for searching.
- **id** (string readonly): Readonly unique identifier for the desktop entry.
- **startupClass** (string): Initial class or app id the app intends to use. May be useful for matching running apps to desktop entries.
- **execString** (string): The raw `Exec` string from the desktop entry. This cannot be reliably run as a command. Use `command` for a runnable version.
- **genericName** (string): Short description of the application, such as “Web Browser”. May be empty.
- **comment** (string): Long description of the application, such as “View websites on the internet”. May be empty.
- **workingDirectory** (string): The working directory to execute from.
```

--------------------------------

### PwNodeType.toString

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Pipewire/PwNodeType

Converts a PwNodeType value to its string representation.

```APIDOC
## toString (type)

### Description
Converts a PwNodeType value to its string representation.

### Parameters
#### Path Parameters
- **type** (PwNodeType) - Required - The PwNodeType value to convert.
```

--------------------------------

### refreshToplevels

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Hyprland/Hyprland

Refreshes Hyprland toplevel information. Useful when toplevel state might be invalidated.

```APIDOC
  * refreshToplevels () : void
Refresh toplevel information.
Many actions that will invalidate workspace state don’t send events, so this function is available if required.
```

--------------------------------

### quit

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Mpris/MprisPlayer

Quits the media player application. This function may only be called if the player is in a state where it can be quit.

```APIDOC
## quit

### Description
Quit the media player.
May only be called if the player is in a state where it can be quit.

### Signature
`quit () : void`
```

--------------------------------

### mapFromItem (rect)

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/QsWindow

Maps the given rect in the coordinate space of `item` to one in the coordinate space of this window. This function does not update reactively.

```APIDOC
## mapFromItem (item, rect)

### Description
Maps the given rect in the coordinate space of `item` to one in the coordinate space of this window. Does not update reactively.
Equivalent to calling `window.contentItem.mapFromItem(item, rect)`

### Parameters
#### Path Parameters
- **item** (Item) - Required - The item whose coordinate space to map from.
- **rect** (rect) - Required - The rectangle to map.

### Returns
- **rect** (rect) - The mapped rectangle in the window's coordinate space.
```

--------------------------------

### PopupAnchor Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/PopupAnchor

Defines the configurable properties of a PopupAnchor, controlling its behavior and appearance.

```APIDOC
## PopupAnchor Properties

### edges : Edges
The point on the anchor rectangle the popup should anchor to. Opposing edges suchs as `Edges.Left | Edges.Right` are not allowed.
Defaults to `Edges.Top | Edges.Left`.

### gravity : Edges
The direction the popup should expand towards, relative to the anchorpoint. Opposing edges suchs as `Edges.Left | Edges.Right` are not allowed.
Defaults to `Edges.Bottom | Edges.Right`.

### adjustment : PopupAdjustment
The strategy used to adjust the popup’s position if it would otherwise not fit on screen.

### item : Item
The item to anchor / attach the popup to. Setting this property unsets `window`.

### rect : [y,h,w,width,x,height]
The anchorpoints the popup will attach to, relative to `item` or `window`.

### window : QtObject
The window to anchor / attach the popup to. Setting this property unsets `item`.

### margins : [bottom,right,left,top]
A margin applied to the anchor rect.
```

--------------------------------

### WifiDeviceMode Enum Variants

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Networking/WifiDeviceMode

This snippet details the different variants of the WifiDeviceMode enum, explaining the state each variant represents for a Wi-Fi device.

```APIDOC
## Enum: WifiDeviceMode

`import Quickshell.Networking`

The 802.11 mode of a WifiDevice.

### Variants

*   **AdHoc**: The device is part of an Ad-Hoc network without a central access point.
*   **Mesh**: The device is an 802.11s mesh point.
*   **Unknown**: The device mode is unknown.
*   **Station**: The device is a station that can connect to networks.
*   **AccessPoint**: The device is a local hotspot/access point.
```

--------------------------------

### HyprlandEvent.parse

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Hyprland/HyprlandEvent

Parses the event data with a specified number of arguments.

```APIDOC
## Functions

### parse
- **Description**: Parse this event with a known number of arguments.
- **Parameters**:
  - **argumentCount** (int) - Required - The number of arguments to parse. This is necessary because some events may contain commas within the last argument, which can be ignored if the argument count is known.
```

--------------------------------

### Network Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Networking/Network

These properties provide information about the current state and details of the network connection.

```APIDOC
## Network Properties

### Description
Properties that provide information about the current state and details of the network connection.

### Properties
- **stateChanging** (bool readonly): Indicates if the network is currently connecting or disconnecting.
- **name** (string readonly): The name of the network.
- **connected** (bool readonly): True if the network is currently connected.
- **device** (NetworkDevice readonly): The network device this network belongs to.
- **nmSettings** (list<NMSettings> readonly): A list of NetworkManager connection settings profiles for this network. Only valid for the NetworkManager backend.
- **known** (bool readonly): True if the wifi network has known connection statuses saved.
- **state** (ConnectionState readonly): The connectivity state of the network.
```

--------------------------------

### MprisPlayer Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Mpris/MprisPlayer

This section outlines the read-only properties available on the MprisPlayer interface.

```APIDOC
## MprisPlayer Properties

### Properties

*   **canTogglePlaying** (bool): Indicates if the player can toggle between playing and paused states.
*   **playbackState** (MprisPlaybackState): The current playback state of the media player. This property has constraints: 
    *   Cannot be set to `Playing` if `canTogglePlaying` is false.
    *   Cannot be set to `Paused` if `canTogglePlaying` is false.
    *   Cannot be set to `Stopped` (or other states) if the respective `can...` property is false.
*   **supportedMimeTypes** (list<string>): A list of MIME types that the player supports for the `openUri()` function.
*   **identity** (string): The human-readable name of the media player.
*   **canQuit** (bool): Indicates if the player can be quit.
```

--------------------------------

### WifiDeviceMode.toString() Function

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Networking/WifiDeviceMode

Converts a WifiDeviceMode enum value to its string representation.

```APIDOC
## Function: WifiDeviceMode.toString()

### Description
Converts a WifiDeviceMode enum value to its string representation.

### Parameters
#### Path Parameters
- **mode** (WifiDeviceMode) - The WifiDeviceMode value to convert.
```

--------------------------------

### ScreencopyView Functions

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Wayland/ScreencopyView

Functions available to interact with the ScreencopyView.

```APIDOC
## ScreencopyView Functions

### `captureFrame () : void`

Captures a single frame from the current capture source. This function has no effect if `live` is true.
```

--------------------------------

### Reloading the Shell

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/Quickshell

Reload the shell using the `reload` function. Set the `hard` parameter to true to perform a hard reload, which recreates windows.

```javascript
Quickshell.reload(true);
```

--------------------------------

### UPowerDeviceState.toString() Function

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.UPower/UPowerDeviceState

Converts a UPowerDeviceState enum value to its string representation.

```APIDOC
## Function: UPowerDeviceState.toString(status)

Converts a UPowerDeviceState enum value to its string representation.

### Parameters

*   **status** (UPowerDeviceState) - Required - The state to convert.

### Returns

*   string - The string representation of the state.
```

--------------------------------

### stop

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Mpris/MprisPlayer

Stops the current media playback. This is equivalent to setting the player's playback status to 'Stopped'.

```APIDOC
## stop

### Description
Stop the media playback.
Equivalent to setting the playback status to `Stopped`.

### Signature
`stop () : void`
```

--------------------------------

### Retainable Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/Retainable

Properties available for Retainable objects.

```APIDOC
## Properties
  * retained  : bool readonly
If the object is currently in a retained state.
```

--------------------------------

### PamContext Functions

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Pam/PamContext

Functions available on the PamContext object to control and interact with the PAM authentication process.

```APIDOC
## PamContext Functions

### `abort () : void`

Abort a running authentication session.

### `respond (response: string) : void`

Respond to PAM with the provided response string. May not be called unless an authentication session is active and a response is required.

### `start () : bool`

Start an authentication session. Returns `true` if the session was started successfully, `false` otherwise.
```

--------------------------------

### Refresh Monitors

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.I3/I3

Refreshes the monitor information.

```APIDOC
## refreshMonitors ()

### Description
Refresh monitor information.

### Response
#### Success Response (void)
Indicates that monitor information has been refreshed.
```

--------------------------------

### Clock Widget Using Singleton Time

Source: https://quickshell.org/docs/v0.3.0/guide/introduction

Updates the ClockWidget to directly access the 'time' property from the global 'Time' singleton.

```qml
// ClockWidget.qml
import QtQuick

Text {
  // we no longer need time as an input

  // directly access the time property from the Time singleton
  text: Time.time
}
```

--------------------------------

### Excluding Expensive Fonts with DropExpensiveFonts Pragma

Source: https://quickshell.org/docs/v0.3.0/guide/advanced

Use the DropExpensiveFonts pragma to exclude all woff and woff2 font files, which can be memory-intensive and cause performance issues. This setting can also be controlled via the QS_DROP_EXPENSIVE_FONTS environment variable.

```qml
//@ pragma DropExpensiveFonts
```

--------------------------------

### itemPosition

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/QsWindow

Returns the given Item’s position relative to the window. This function does not update reactively.

```APIDOC
## itemPosition

### Description
Returns the given Item’s position relative to the window. Does not update reactively.
Equivalent to calling `window.contentItem.mapFromItem(item, 0, 0)`

### Parameters
#### Path Parameters
- **item** (Item) - Required - The item to get the position of.

### Returns
- **point** (point) - The position of the item relative to the window.
```

--------------------------------

### FileView Signals

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/FileView

Signals emitted by the FileView class to indicate events such as loading, saving, and file changes.

```APIDOC
## Signals

### saveFailed (error)
Emitted if the file failed to save.
- **error** (FileViewError) - Description of the error.
```

```APIDOC
### loadFailed (error)
Emitted if the file failed to load.
- **error** (FileViewError) - Description of the error.
```

```APIDOC
### adapterUpdated ()
Emitted when the active adapter's data is changed.
```

```APIDOC
### fileChanged ()
Emitted if the file changes on disk and a specific internal flag is true.
```

```APIDOC
### loaded ()
Emitted if the file was loaded successfully.
```

```APIDOC
### saved ()
Emitted if the file was saved successfully.
```

--------------------------------

### refreshMonitors

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Hyprland/Hyprland

Refreshes Hyprland monitor information. Useful when monitor state might be invalidated.

```APIDOC
  * refreshMonitors () : void
Refresh monitor information.
Many actions that will invalidate monitor state don’t send events, so this function is available if required.
```

--------------------------------

### seek

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Mpris/MprisPlayer

Adjusts the current playback position by a specified offset. This function may still work even if the playback position cannot be directly set.

```APIDOC
## seek

### Description
Change the current playback position by an offset.
Even if the playback position cannot be directly set, this function may still work.
May only be called if the player is in a playable state.

### Parameters
#### Path Parameters
- **offset** (real) - Required - The amount to change the position by.
```

--------------------------------

### pause

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Mpris/MprisPlayer

Pauses the current media playback. This is equivalent to setting the player's playback status to 'Paused'.

```APIDOC
## pause

### Description
Pause the media playback.
Equivalent to setting the playback status to `Paused`.

### Signature
`pause () : void`
```

--------------------------------

### PopupAnchor Signals

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/PopupAnchor

Emitted signals from the PopupAnchor, useful for reacting to anchor events.

```APIDOC
## PopupAnchor Signals

### anchoring ()
Emitted when this anchor is about to be used. Mostly useful for modifying the anchor `rect` using coordinate mapping functions, which are not reactive.
```

--------------------------------

### QsMenuEntry Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/QsMenuEntry

Properties of a QsMenuEntry, including its display type, state, text, icon, and child status.

```APIDOC
## Properties
  * buttonType  : QsMenuButtonType readonly
If this menu item has an associated checkbox or radiobutton.
  * isSeparator  : bool readonly
If this menu item should be rendered as a separator between other items.
No other properties have a meaningful value when  is true.
  * enabled  : bool readonly
_No details provided_
  * text  : string readonly
Text of the menu item.
  * checkState  : unknown readonly
The check state of the checkbox or radiobutton if applicable, as a Qt.CheckState.
  * icon  : string readonly
Url of the menu item’s icon or `""` if it doesn’t have one.
This can be passed to Image.source as shown below.
```
Image {
  source: menuItem.icon
  // To get the best image quality, set the image source size to the same size
  // as the rendered image.
  sourceSize.width: width
  sourceSize.height: height
}
```

  * hasChildren  : bool readonly
If this menu item has children that can be accessed through a QsMenuOpener.
```

--------------------------------

### QsMenuAnchor Signals

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/QsMenuAnchor

Signals emitted by the QsMenuAnchor component to indicate menu state changes.

```APIDOC
## QsMenuAnchor Signals

### closed ()
Sent when the menu is closed.

### opened ()
Sent when the menu is displayed onscreen which may be after becomes true.
```

--------------------------------

### NetworkDevice Functions

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Networking/NetworkDevice

Functions available for the NetworkDevice object to manage network connections.

```APIDOC
## NetworkDevice Functions

### disconnect ()
- **Description**: Disconnects the device and prevents it from automatically activating further connections.
- **Returns**: void
```

--------------------------------

### PwAudioChannel Enum Variants

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Pipewire/PwAudioChannel

This section lists all the available variants for the PwAudioChannel enum, representing various audio channel configurations.

```APIDOC
## Variants
  * RearLeftCenter 
  * TopSideRight 
  * TopSideLeft 
  * LowFrequencyEffects 
  * LowFrequencyEffectsLeft 
  * TopFrontRight 
  * BottomRightCenter 
  * SideRight 
  * TopRearCenter 
  * NA 
  * FrontRightCenter 
  * TopFrontCenter 
  * TopFrontLeft 
  * RearLeft 
  * FrontLeftWide 
  * TopFrontLeftCenter 
  * RearRightCenter 
  * FrontRight 
  * TopFrontRightCenter 
  * FrontLeftHigh 
  * FrontRightHigh 
  * FrontRightWide 
  * FrontCenterHigh 
  * RearRight 
  * Mono 
  * SideLeft 
  * TopCenter 
  * Unknown 
  * LowFrequencyEffects2 
  * BottomCenter 
  * AuxRangeStart 
  * LowFrequencyEffectsRight 
  * FrontLeftCenter 
  * RearCenter 
  * BottomLeftCenter 
  * CustomRangeStart 
  * AuxRangeEnd 
  * FrontCenter 
  * FrontLeft 
  * TopRearRight 
  * TopRearLeft 

```

--------------------------------

### Round an Image with ClippingWrapperRectangle in QML

Source: https://quickshell.org/docs/v0.3.0/guide/faq

Apply a radius to an image using ClippingWrapperRectangle to achieve rounded corners. This component attempts to match the size of its child.

```qml
ClippingWrapperRectangle {
  radius: 10

  IconImage { // or a normal Image
    source: ...
    implicitSize: ...
  }
}
```

--------------------------------

### BluetoothDevice Functions

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Bluetooth/BluetoothDevice

Functions available on the BluetoothDevice object to control device pairing and connection.

```APIDOC
## BluetoothDevice Functions

*   `cancelPair()`: void - Cancel an active pairing attempt.
*   `connect()`: void - Attempt to connect to the device.
*   `disconnect()`: void - Disconnect from the device.
*   `forget()`: void - Forget the device.
*   `pair()`: void - Attempt to pair the device.
```

--------------------------------

### closed

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/QsWindow

This signal is emitted when the window is closed by the user, the display server, or an error.

```APIDOC
## closed

### Description
This signal is emitted when the window is closed by the user, the display server, or an error. It is not emitted when `visible` is set to false.

### Parameters
_No parameters provided._

### Returns
_No return value._
```

--------------------------------

### ShellScreen Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/ShellScreen

These are the readonly properties of the ShellScreen object that provide information about the screen.

```APIDOC
## ShellScreen Properties

- **y** (int): Readonly. The y-coordinate of the screen.
- **logicalPixelDensity** (real): Readonly. The number of device-independent (scaled) pixels per millimeter.
- **name** (string): Readonly. The name of the screen as seen by the operating system (e.g., `DP-1`, `HDMI-1`).
- **primaryOrientation** (unknown): Readonly. The primary orientation of the screen.
- **height** (int): Readonly. The height of the screen in pixels.
- **orientation** (unknown): Readonly. The current orientation of the screen.
- **model** (string): Readonly. The model of the screen as seen by the operating system.
- **devicePixelRatio** (real): Readonly. The ratio between physical pixels and device-independent (scaled) pixels.
- **physicalPixelDensity** (real): Readonly. The number of physical pixels per millimeter.
- **serialNumber** (string): Readonly. The serial number of the screen as seen by the operating system.
- **x** (int): Readonly. The x-coordinate of the screen.
- **width** (int): Readonly. The width of the screen in pixels.
```

--------------------------------

### ObjectModel Signals

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/ObjectModel

The ObjectModel emits signals to notify about object insertions and removals, both before and after the operation.

```APIDOC
## Signals

### objectInsertedPost (object, index)

- **object**: QtObject
- **index**: int
- **Description**: Sent immediately after an object is inserted into the list.

### objectInsertedPre (object, index)

- **object**: QtObject
- **index**: int
- **Description**: Sent immediately before an object is inserted into the list.

### objectRemovedPre (object, index)

- **object**: QtObject
- **index**: int
- **Description**: Sent immediately before an object is removed from the list.

### objectRemovedPost (object, index)

- **object**: QtObject
- **index**: int
- **Description**: Sent immediately after an object is removed from the list.
```

--------------------------------

### File Content Modification

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/FileView

Methods for setting the file content using either an ArrayBuffer or a string.

```APIDOC
## setData (data)

### Description
Sets the content of the file specified by the FileView instance as an ArrayBuffer.
Internal flags affect the behavior and completion signals.

### Parameters
#### Request Body
- **data** (ArrayBuffer) - Required - The new content for the file.
```

```APIDOC
## setText (text)

### Description
Sets the content of the file specified by the FileView instance as text.
Internal flags affect the behavior and completion signals.

### Parameters
#### Request Body
- **text** (string) - Required - The new text content for the file.
```

--------------------------------

### togglePlaying

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Mpris/MprisPlayer

Toggles the playback state between playing and paused. If the player is currently playing, it will be paused, and vice versa. This function requires the player to be in a playable state.

```APIDOC
## togglePlaying

### Description
Toggle the playback state between playing and paused.
Equivalent to calling play() if not playing or pause() if playing.
May only be called if the player is in a playable state, which is equivalent to the player being either playing or paused depending on the current playback state.

### Signature
`togglePlaying () : void`
```

--------------------------------

### toString Function

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Networking/ConnectionFailReason

Converts a ConnectionFailReason enum value to its string representation.

```APIDOC
## Functions

### toString (reason)

Converts a `ConnectionFailReason` to a string.

*   **Parameters**
    *   `reason` (ConnectionFailReason) - The connection failure reason to convert.
*   **Returns**
    *   string - The string representation of the reason.
```

--------------------------------

### toString Function

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Mpris/MprisPlaybackState

Converts an MprisPlaybackState enum value to its string representation.

```APIDOC
## Function: toString

### Description
Converts a given MprisPlaybackState to its string representation.

### Parameters
- **status** (MprisPlaybackState) - Required - The playback state to convert.
```

--------------------------------

### NMSettings Signals

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Networking/NMSettings

Signals emitted by the NMSettings object.

```APIDOC
## Signals

### loaded ()
- Description: Emitted when the settings are loaded.

### settingsChanged (settings)
- Parameters:
  - settings: The changed settings.
- Description: Emitted when the settings have changed.
```

--------------------------------

### HyprlandWorkspace Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Hyprland/HyprlandWorkspace

Read-only properties of a Hyprland workspace, providing information about its state and content.

```APIDOC
## HyprlandWorkspace Properties

### name
- Type: string
- Readonly: true
- Description: The name of the workspace.

### active
- Type: boolean
- Readonly: true
- Description: Indicates if this workspace is currently active on its monitor.

### id
- Type: integer
- Readonly: true
- Description: The unique identifier for the workspace.

### lastIpcObject
- Type: unknown
- Readonly: true
- Description: The last JSON object returned for this workspace from Hyprland IPC. This is not automatically updated and may require a manual refresh.

### hasFullscreen
- Type: boolean
- Readonly: true
- Description: Indicates if this workspace currently contains a fullscreen client.

### monitor
- Type: HyprlandMonitor
- Readonly: true
- Description: The monitor associated with this workspace.

### urgent
- Type: boolean
- Readonly: true
- Description: Indicates if this workspace has an urgent window. This flag is reset after the workspace is interacted with.

### focused
- Type: boolean
- Readonly: true
- Description: Indicates if this workspace is active on the currently focused monitor.

### toplevels
- Type: ObjectModel
- Readonly: true
- Description: A list of toplevel windows present on this workspace.
```

--------------------------------

### ShortcutInhibitor

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Wayland/ShortcutInhibitor

A shortcuts inhibitor prevents the compositor from processing its own keyboard shortcuts for the focused surface. This allows applications to receive key events for shortcuts that would normally be handled by the compositor. The inhibitor only takes effect when the associated window is focused and the inhibitor is enabled. The compositor may choose to ignore inhibitor requests based on its policy.

```APIDOC
## Properties
  * window  : QtObject
The window to associate the shortcuts inhibitor with. The inhibitor will only inhibit shortcuts pressed while this window has keyboard focus.
Must be set to a non null value to enable the inhibitor.
  * active  : bool readonly
Whether the inhibitor is currently active. The inhibitor is only active if is true, has keyboard focus, and the compositor grants the inhibit request.
The compositor may deactivate the inhibitor at any time (for example, if the user requests normal shortcuts to be restored). When deactivated by the compositor, the inhibitor cannot be programmatically reactivated.
  * enabled  : bool
If the shortcuts inhibitor should be enabled. Defaults to false.

## Signals
  * cancelled ()
Sent if the compositor cancels the inhibitor while it is active.
```

--------------------------------

### PwLinkGroup

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Pipewire/PwLinkGroup

Represents a group of connections between Pipewire nodes, one per source->target pair. This type is uncreatable and intended for documentation purposes.

```APIDOC
## PwLinkGroup: QtObject 

 A group of connections between pipewire nodes, one per source->target pair.

### Properties

* **target** : PwNode readonly
  The node that is _receiving_ information. (the sink)

* **state** : PwLinkState readonly
  The current state of the link group.
  This property is invalid unless the node is bound using PwObjectTracker.

* **source** : PwNode readonly
  The node that is _sending_ information. (the source)
```

--------------------------------

### NetworkDevice Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Networking/NetworkDevice

Properties of the NetworkDevice object that provide information about the network interface.

```APIDOC
## NetworkDevice Properties

### networks
- **Type**: ObjectModel <Network>
- **Description**: A list of available or connected networks for this device. When the device type is ‘Wifi’, this model will only contain WifiNetwork.

### state
- **Type**: ConnectionState
- **Description**: Connection state of the device.

### type
- **Type**: DeviceType
- **Description**: The device type. When the device type is `Wifi`, the device object is a WifiDevice. When the device type is `Wired`, the device object is a WiredDevice.

### autoconnect
- **Type**: bool
- **Description**: True if the device is allowed to autoconnect to a network.

### name
- **Type**: string
- **Description**: The name of the device’s control interface.

### address
- **Type**: string
- **Description**: The hardware address of the device in the XX:XX:XX:XX:XX:XX format.

### connected
- **Type**: bool
- **Description**: True if the device is connected.
```

--------------------------------

### ClippingWrapperRectangle Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Widgets/ClippingWrapperRectangle

This snippet details the properties available for the ClippingWrapperRectangle component, including margin settings, sizing overrides, and child resizing behavior.

```APIDOC
## ClippingWrapperRectangle Properties

This component is useful for adding a clipping border or background rectangle to a child item. If you don’t need clipping, use WrapperRectangle.

### Properties

*   **extraMargin** (real): An extra margin applied in addition to `bottomMargin`, `leftMargin`, `rightMargin`, and `topMargin`. If `true`, the rectangle’s border width will be added to this property. Defaults to 0.
*   **implicitHeight** (real): Overrides the implicit height of the wrapper. Defaults to the implicit width of the content item plus its top and bottom margin, and may be reset by assigning `undefined`.
*   **bottomMargin** (real): The requested bottom margin of the content item, not counting `extraMargin`. Defaults to `margin`, and may be reset by assigning `undefined`.
*   **leftMargin** (real): The requested left margin of the content item, not counting `extraMargin`. Defaults to `margin`, and may be reset by assigning `undefined`.
*   **margin** (real): The default for `bottomMargin`, `leftMargin`, `rightMargin`, and `topMargin`. Defaults to 0.
*   **resizeChild** (bool): Determines if child item should be resized larger than its implicit size if the parent is resized larger than its implicit size. Defaults to true.
*   **rightMargin** (real): The requested right margin of the content item, not counting `extraMargin`. Defaults to `margin`, and may be reset by assigning `undefined`.
*   **topMargin** (real): The requested top margin of the content item, not counting `extraMargin`. Defaults to `margin`, and may be reset by assigning `undefined`.
*   **child** (unknown): See `WrapperItem` for details.
*   **implicitWidth** (real): Overrides the implicit width of the wrapper. Defaults to the implicit width of the content item plus its left and right margin, and may be reset by assigning `undefined`.
```

--------------------------------

### NotificationServer Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Notifications/NotificationServer

Properties of the NotificationServer that control its advertised capabilities and behavior.

```APIDOC
## NotificationServer Properties

### `imageSupported` : bool
If the notification server should advertise that it supports images. Defaults to false.

### `extraHints` : list<string>
Extra hints to expose to notification clients.

### `actionsSupported` : bool
If notification actions should be advertised as supported by the notification server. Defaults to false.

### `actionIconsSupported` : bool
If notification actions should be advertised as supporting the display of icons. Defaults to false.

### `bodySupported` : bool
If notification body text should be advertised as supported by the notification server. Defaults to true. Note that returned notifications are likely to return body text even if this property is false, as it is only a hint.

### `inlineReplySupported` : bool
If the notification server should advertise that it supports inline replies. Defaults to false.

### `persistenceSupported` : bool
If the notification server should advertise that it can persist notifications in the background after going offscreen. Defaults to false.

### `bodyImagesSupported` : bool
If notification body text should be advertised as supporting images as described in the specification Defaults to false. Note that returned notifications may still contain images if this property is false, as it is only a hint.

### `trackedNotifications` : ObjectModel<Notification> readonly
All notifications currently tracked by the server.

### `bodyHyperlinksSupported` : bool
If notification body text should be advertised as supporting hyperlinks as described in the specification Defaults to false. Note that returned notifications may still contain hyperlinks if this property is false, as it is only a hint.

### `bodyMarkupSupported` : bool
If notification body text should be advertised as supporting markup as described in [the specification] Defaults to false. Note that returned notifications may still contain markup if this property is false, as it is only a hint. By default Text objects will try to render markup. To avoid this if any is sent, change to `PlainText`.

### `keepOnReload` : bool
If notifications should be re-emitted when quickshell reloads. Defaults to true. The flag will be set on notifications from the prior generation for further filtering/handling.
```

--------------------------------

### Assign QML Lambdas to Properties

Source: https://quickshell.org/docs/v0.3.0/guide/qml-language

Lambdas can be directly assigned to properties, offering a more compact way to define function values compared to traditional function declarations.

```qml
Item {
  // using functions
  function dub(number: int): int { return number * 2; }
  property var operation: dub

  // using lambdas
  property var operation: number => number * 2
}
```

--------------------------------

### Shell Reloading

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/Quickshell

Functions to control the shell reloading process.

```APIDOC
## inhibitReloadPopup ()

### Description
When called from reloadCompleted() or reloadFailed(), prevents the default reload popup from displaying. The popup can also be blocked by setting `QS_NO_RELOAD_POPUP=1`.

### Return Value
void
```

```APIDOC
## reload (hard)

### Description
Reload the shell.

### Parameters
#### Path Parameters
- **hard** (bool) - Optional - If true, perform a hard reload. If false, Quickshell will attempt to reuse windows that already exist. If true, windows will be recreated.

### Notes
See Reloadable for more information on what can be reloaded and how.

### Return Value
void
```

--------------------------------

### Customizing Shell ID with ShellId Pragma

Source: https://quickshell.org/docs/v0.3.0/guide/advanced

Override the default path-based Shell ID with the ShellId pragma. This is useful when a configuration might exist at multiple paths and you need to ensure consistent data directory locations.

```qml
//@ pragma ShellId <id>
```

--------------------------------

### toString Function

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Networking/ConnectionState

Converts a ConnectionState enum value to its string representation.

```APIDOC
## Function: toString

`state: ConnectionState` : `string`

Converts a ConnectionState enum value to its string representation. The specific string output for each state is not detailed in the source.
```

--------------------------------

### rawEvent Signal

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Hyprland/Hyprland

Emitted for every event received through the Hyprland event socket.

```APIDOC
## Signals
  * rawEvent (event) : void
event: HyprlandEvent
Emitted for every event that comes in through the hyprland event socket (socket2).
See Hyprland Wiki: IPC for a list of events.
```

--------------------------------

### ScreencopyView Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Wayland/ScreencopyView

Properties that can be set or read on a ScreencopyView object to control its behavior and retrieve information.

```APIDOC
## ScreencopyView Properties

### `captureSource` : QtObject

The object to capture from. Accepts `null` to clear the image, `ShellScreen` for monitor capture (requires specific compositor support), or `Toplevel` for window capture (requires specific compositor support).

### `hasContent` : bool (readonly)

Indicates if the view has content ready to display. Use this to ensure content is available before attempting to display it.

### `live` : bool

Enables live video feed display when true. Defaults to false, displaying a still image.

### `constraintSize` : unknown

If set to a non-zero value, the specified width and height will constrain the ScreencopyView's implicit size while maintaining the image's aspect ratio.

### `paintCursor` : bool

If true, the system cursor will be painted on the captured image. Defaults to false.

### `sourceSize` : size (readonly)

The dimensions of the source image. This property is valid when `hasContent` is true.
```

--------------------------------

### UPowerDeviceState Enum Variants

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.UPower/UPowerDeviceState

This snippet details the possible states for a UPower device.

```APIDOC
## Enum: UPowerDeviceState

Represents the charging state of a UPower device.

### Variants

*   **FullyCharged**: The device is fully charged.
*   **PendingCharge**: The device is waiting to be charged after it was plugged in.
*   **Discharging**: The device is currently discharging.
*   **PendingDischarge**: The device is waiting to be discharged after being unplugged.
*   **Unknown**: The state of the device is unknown.
*   **Charging**: The device is currently charging.
*   **Empty**: The device is empty or has no power.
```

--------------------------------

### PamContext Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Pam/PamContext

Properties of the PamContext object that control and reflect the state of the PAM authentication session.

```APIDOC
## PamContext Properties

### `config` : string

The PAM configuration to use. Defaults to "login". The configuration should name a file inside the configuration directory. This property may not be set while an authentication session is active.

### `active` : bool

Indicates if the PAM context is actively performing an authentication. Setting this value is equivalent to calling `start()` or `abort()`.

### `configDirectory` : string

The PAM configuration directory to use. Defaults to "/etc/pam.d". The configuration directory is resolved relative to the current file if not an absolute path. On FreeBSD, this property is ignored as the PAM configuration directory cannot be changed. This property may not be set while an authentication session is active.

### `responseVisible` : bool readonly

Indicates if the user's response should be visible. Only valid when an authentication session is active.

### `responseRequired` : bool readonly

Indicates if PAM currently requires a response. Responses can be returned with the `respond()` function.

### `user` : string

The user to authenticate as. If unset, the current user will be used. This property may not be set while an authentication session is active.

### `messageIsError` : bool readonly

Indicates if the last message should be shown as an error.

### `message` : string readonly

The last message sent by PAM.
```

--------------------------------

### MprisLoopState.toString() Function

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Mpris/MprisLoopState

Converts an MprisLoopState value to its string representation.

```APIDOC
## Functions

### toString

`toString(status: MprisLoopState): string`

Converts the given MprisLoopState to its string representation. For example, `MprisLoopState.Track` might be represented as "track".
```

--------------------------------

### itemRect

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/QsWindow

Returns the given Item’s geometry relative to the window. This function does not update reactively.

```APIDOC
## itemRect

### Description
Returns the given Item’s geometry relative to the window. Does not update reactively.
Equivalent to calling `window.contentItem.mapFromItem(item, 0, 0, 0, 0)`

### Parameters
#### Path Parameters
- **item** (Item) - Required - The item to get the geometry of.

### Returns
- **rect** (rect) - The geometry of the item relative to the window.
```

--------------------------------

### ConnectionFailReason Enum Variants

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Networking/ConnectionFailReason

The ConnectionFailReason enum lists the specific reasons why a network connection might fail. Each variant provides a descriptive name for a failure scenario.

```APIDOC
## ConnectionFailReason Enum

`import Quickshell.Networking`

The reason a connection failed.

### Variants

*   **WifiAuthTimeout** - The Wi-Fi connection took too long to authenticate.
*   **NoSecrets** - Secrets were required, but not provided.
*   **WifiClientDisconnected** - The Wi-Fi supplicant disconnected.
*   **WifiNetworkLost** - The Wi-Fi network could not be found.
*   **WifiClientFailed** - The Wi-Fi supplicant failed.
*   **Unknown** - The connection failed for an unknown reason.
```

--------------------------------

### Monitoring Track Position with FrameAnimation

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Mpris/MprisPlayer

Use FrameAnimation to emit the positionChanged signal every frame when the player is playing, suitable for smooth updates like on a slider.

```javascript
FrameAnimation {
  // only emit the signal when the position is actually changing.
  running: player.playbackState == MprisPlaybackState.Playing
  // emit the positionChanged signal every frame.
  onTriggered: player.positionChanged()
}
```

--------------------------------

### Notification Functions

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Notifications/Notification

Functions available to interact with and manage notifications.

```APIDOC
## Notification Functions

### Description
Functions available to interact with and manage notifications.

### Functions
- **dismiss()** : void
  Destroys the notification and signals the sender that it was explicitly closed by the user.

- **expire()** : void
  Destroys the notification and signals the sender that it has timed out.

- **sendInlineReply(replyText)** : void
  * **replyText** (string) - The text content of the reply.
  Sends an inline reply. This can only be called if `hasInlineReply` is true and the server has the inline reply capability set.
```

--------------------------------

### Greetd Signals

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Greetd/Greetd

Signals emitted by the greetd service to indicate status changes or events.

```APIDOC
## Signals

* error (error)
error: string
Greetd has encountered an error.

* authFailure (message)
message: string
Authentication has failed an the session has terminated.
Usually this is something like a timeout or a failed password entry.

* authMessage (message, error, responseRequired, echoResponse)
message: string error: bool responseRequired: bool echoResponse: bool
An authentication message has been sent by greetd.
  * `message` - the text of the message
  * `error` - if the message should be displayed as an error
  * `responseRequired` - if a response via `respond()` is required for this message
  * `echoResponse` - if the response should be displayed in clear text to the user
Note that `error` and `responseRequired` are mutually exclusive.
Errors are sent through `authMessage` when they are recoverable, such as a fingerprint scanner not being able to read a finger correctly, while definite failures such as a bad password are sent through `authFailure`.

* readyToLaunch ()
Authentication has finished successfully and greetd can now launch a session.

* launched ()
Greetd has acknowledged the launch request and the greeter should quit as soon as possible.
This signal is sent right before quickshell exits automatically if the launch was not specifically requested not to exit. You usually don’t need to use this signal.
```

--------------------------------

### ObjectModel Functions

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/ObjectModel

The ObjectModel includes an `indexOf` function to find the index of an object within the model.

```APIDOC
## Functions

### indexOf ()

- **Returns**: int
- **Description**: No details provided.
```

--------------------------------

### BluetoothDevice Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Bluetooth/BluetoothDevice

Properties of the BluetoothDevice object that provide information about the device and its connection status.

```APIDOC
## BluetoothDevice Properties

*   `blocked`: bool - True if the device is blocked from connecting.
*   `icon`: string (readonly) - System icon representing the device type.
*   `wakeAllowed`: bool - True if the device is allowed to wake up the host system from suspend.
*   `address`: string (readonly) - MAC address of the device.
*   `connected`: bool - True if the device is currently connected to the computer.
*   `trusted`: bool - True if the device is considered to be trusted by the system.
*   `battery`: real (readonly) - Battery level of the connected device, from `0.0` to `1.0`.
*   `batteryAvailable`: bool (readonly) - True if the connected device reports its battery level.
*   `dbusPath`: string (readonly) - DBus path of the device.
*   `adapter`: BluetoothAdapter (readonly) - The Bluetooth adapter this device belongs to.
*   `bonded`: bool (readonly) - True if pairing information is stored for future connections.
*   `deviceName`: string (readonly) - The name of the Bluetooth device, ignoring user provided aliases.
*   `name`: string - The name of the Bluetooth device. Can be written to create an alias.
*   `paired`: bool (readonly) - True if the device is paired to the computer.
*   `pairing`: bool (readonly) - True if the device is currently being paired.
*   `state`: BluetoothDeviceState (readonly) - Connection state of the device.
```

--------------------------------

### Toplevel Signals

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Wayland/Toplevel

Signals emitted by Toplevel objects.

```APIDOC
## Toplevel Signals

### closed ()
- **Description**: Emitted when the toplevel window is closed.

```

--------------------------------

### File Data Access

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/FileView

Methods for retrieving file content as an ArrayBuffer or text. These methods can block depending on configuration.

```APIDOC
## data ()

### Description
Returns the data of the file specified by the FileView instance as an ArrayBuffer.
Behavior regarding blocking and returning empty buffers depends on internal flags.

### Returns
- unknown (ArrayBuffer): The file content as an ArrayBuffer.
```

```APIDOC
## text ()

### Description
Returns the data of the file specified by the FileView instance as text.
Behavior regarding blocking and returning empty strings depends on internal flags.

### Returns
- string: The file content as a string.
```

--------------------------------

### Socket Functions

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/Socket

Functions to control socket operations like flushing and writing data.

```APIDOC
## Socket Functions

### `flush () : void`
Flush any queued writes to the socket.

### `write (data: string) : void`
Write data to the socket. Does nothing if not connected. Remember to call flush after your last write.
```

--------------------------------

### BluetoothAdapterState.toString()

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Bluetooth/BluetoothAdapterState

Converts a BluetoothAdapterState enum value to its string representation.

```APIDOC
## Function: BluetoothAdapterState.toString(state)

### Description
Converts a Bluetooth adapter state to its string representation.

### Parameters

*   **state** (BluetoothAdapterState) - Required - The state to convert.
```

--------------------------------

### toString Function

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.UPower/PerformanceDegradationReason

Converts a PerformanceDegradationReason enum value to its string representation.

```APIDOC
## Functions

### toString (reason)

#### Description
Converts a PerformanceDegradationReason to its string representation.

#### Parameters
*   **reason** (PerformanceDegradationReason) - Required - The reason to convert.
```

--------------------------------

### ScreencopyView Signals

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Wayland/ScreencopyView

Signals emitted by the ScreencopyView to notify about specific events.

```APIDOC
## ScreencopyView Signals

### `stopped ()`

Emitted when the compositor has ended the video stream. Attempting to restart the stream after this signal may not be successful.
```

--------------------------------

### StdioCollector Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/StdioCollector

Properties of the StdioCollector class for accessing process output.

```APIDOC
## StdioCollector Properties

### `data`

- **Type**: `unknown readonly`
- **Description**: The stdio buffer exposed as an ArrayBuffer. If `waitForEnd` is true, this will not change until the stream ends.

### `waitForEnd`

- **Type**: `bool`
- **Description**: If true, `data` and `text` will not be updated until the stream ends. Defaults to true.

### `text`

- **Type**: `string readonly`
- **Description**: The stdio buffer exposed as text. If `waitForEnd` is true, this will not change until the stream ends.
```

--------------------------------

### Retainable Signals

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/Retainable

Signals emitted by Retainable objects related to their destruction lifecycle.

```APIDOC
## Signals
  * dropped ()
This signal is sent when the object would normally be destroyed.
If all signal handlers return and no locks are in place, the object will be destroyed. If at least one lock is present the object will be retained until all are removed.
  * aboutToDestroy ()
This signal is sent immediately before the object is destroyed. At this point destruction cannot be interrupted.
```

--------------------------------

### Removing a Binding in QML

Source: https://quickshell.org/docs/v0.3.0/guide/qml-language

Demonstrates how to remove an existing binding by assigning a new, non-binding value to the property. This stops automatic updates.

```qml
Item {
  Text {
    id: boundText
    text: `button is pressed: ${theButton.pressed}`
  }

  Button {
    id: theButton
    text: "break the binding"
    onClicked: boundText.text = `button was pressed at the time the binding was broken: ${pressed}`
  }
}
```

--------------------------------

### NotificationAction.invoke()

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Notifications/NotificationAction

The invoke function is used to trigger the notification action. Depending on certain conditions, this may also dismiss the notification.

```APIDOC
## NotificationAction.invoke()

### Description
Invokes the notification action. If a specific condition is not met, the notification will be dismissed after invocation.

### Signature
`invoke() : void`
```

--------------------------------

### PwAudioChannel.toString Function

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Pipewire/PwAudioChannel

The toString function converts a PwAudioChannel enum value into a human-readable string representation. This is useful for debugging and logging purposes.

```APIDOC
## Functions [?]
  * toString (value) : string
value: PwAudioChannel
Print a human readable representation of the given channel, including aux and custom channel ranges.
```

--------------------------------

### NotificationServer Signals

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Notifications/NotificationServer

Signals emitted by the NotificationServer.

```APIDOC
## NotificationServer Signals

### `notification` (notification)
Sent when a notification is received by the server. If this notification should not be discarded, set its `tracked` property to true.

#### Parameters
* **notification** (Notification) - The received notification object.
```

--------------------------------

### Network Functions

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Networking/Network

Functions to control the network connection, such as connecting, disconnecting, and forgetting network settings.

```APIDOC
## Network Functions

### Description
Functions to control the network connection, such as connecting, disconnecting, and forgetting network settings.

### Functions
- **connect()** : void
  Attempt to connect to the network. If the network is a WifiNetwork and requires secrets, a signal will be emitted with `NoSecrets`. `WifiNetwork.connectWithPsk()` can be used to provide secrets.
- **connectWithSettings(settings: NMSettings)** : void
  Attempt to connect to the network with a specific entry. Only valid for the NetworkManager backend.
- **disconnect()** : void
  Disconnect from the network.
- **forget()** : void
  Forget all connection settings for this network.
```

--------------------------------

### Retainable Functions

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/Retainable

Functions to manage the retained state of an object.

```APIDOC
## Functions
  * forceUnlock () : void
Forcibly remove all locks, destroying the object.
unlock() should usually be preferred.
  * lock () : void
Hold a lock on the object so it cannot be destroyed.
A counter is used to ensure you can lock the object from multiple places and it will not be unlocked until the same number of unlocks as locks have occurred.
It is easy to forget to unlock a locked object. Doing so will create what is effectively a memory leak.
Using RetainableLock is recommended as it will help avoid this scenario and make misuse more obvious.
  * unlock () : void
Remove a lock on the object. See lock() for more information.
```

--------------------------------

### BackgroundEffect Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Wayland/BackgroundEffect

BackgroundEffect is an uncreatable QtObject that applies background blur. It has one property, blurRegion, which specifies the region to blur behind the surface. Setting blurRegion to null removes the blur.

```APIDOC
## BackgroundEffect

Applies background blur behind a QsWindow or subclass, as an attached object, using the ext-background-effect-v1 Wayland protocol.

Using a background effect requires the compositor support the ext-background-effect-v1 protocol.

### Properties

* **blurRegion** (Region) - Required - Region to blur behind the surface. Set to null to remove blur.
```

--------------------------------

### PamContext Signals

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Pam/PamContext

Signals emitted by the PamContext object to notify about events during the authentication process.

```APIDOC
## PamContext Signals

### `pamMessage ()`

Emitted whenever PAM sends a new message. This signal is emitted after the change signals for `message`, `messageIsError`, and `responseRequired`.

### `completed (result: PamResult)`

Emitted whenever authentication completes. The `result` parameter indicates the outcome of the authentication.

### `error (error: PamError)`

Emitted if PAM fails to perform authentication normally. A `completed(PamResult.Error)` signal will be emitted after this error signal.
```

--------------------------------

### WifiSecurityType.toString()

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Networking/WifiSecurityType

Converts a WifiSecurityType enum value to its string representation.

```APIDOC
## Function: WifiSecurityType.toString()

Converts a WifiSecurityType enum value to its string representation.

### Signature

`toString(type: WifiSecurityType) : string`

### Parameters

*   **type** (WifiSecurityType) - The enum value to convert.
```

--------------------------------

### NetworkBackendType Enum

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Networking/NetworkBackendType

The NetworkBackendType enum defines the possible backends for the Network service.

```APIDOC
## Enum: NetworkBackendType

`import Quickshell.Networking`

The backend supplying the Network service.

### Variants

*   **NetworkManager**
*   **None**

### Functions

*   **toString** (type: NetworkBackendType) : string
    Converts the NetworkBackendType enum to its string representation.
```

--------------------------------

### AuthFlow Functions

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Polkit/AuthFlow

Functions available on the AuthFlow object to interact with the authentication process.

```APIDOC
## AuthFlow Functions

### cancelAuthenticationRequest
- **Description**: Cancel the ongoing authentication request from the user side.
- **Signature**: `cancelAuthenticationRequest() : void`

### submit
- **Description**: Submit a response to a request that was previously emitted. Typically the password.
- **Signature**: `submit(value: string) : void`
- **Parameters**:
  - **value** (string) - The response to submit.
```

--------------------------------

### PamResult.toString()

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Pam/PamResult

Converts a PamResult enum value to its string representation.

```APIDOC
## Function: PamResult.toString()

`value`: PamResult

Converts the PamResult enum value to a human-readable string.

### Parameters

*   **value** (PamResult) - The PamResult enum value to convert.
```

--------------------------------

### Mpris Players Property

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Mpris/Mpris

Access all connected MPRIS players through the 'players' property.

```APIDOC
## Mpris.players

### Description
Retrieves a collection of all currently connected MPRIS players.

### Type
ObjectModel <MprisPlayer>

### Access
Readonly
```

--------------------------------

### Region Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/Region

Defines the properties available for a Region object, including its position, dimensions, corner radii, shape, and how it intersects with other regions.

```APIDOC
## Region Properties

* **x** (int) - The x-coordinate of the region. Defaults to 0.
* **radius** (int) - Corner radius for rounded rectangles. Defaults to 0.
* **item** (Item) - The item that determines the geometry of the region.
* **regions** (list<Region>) - Nested regions to apply on top of this region.
* **shape** (RegionShape) - The shape of the region. Defaults to `Rect`.
* **height** (int) - The height of the region. Defaults to 0.
* **intersection** (Intersection) - How this region interacts with its parent region. Defaults to `Combine`.
* **bottomLeftRadius** (int) - Bottom-left corner radius. Defaults to `radius`.
* **topLeftRadius** (int) - Top-left corner radius. Defaults to `radius`.
* **width** (int) - The width of the region. Defaults to 0.
* **topRightRadius** (int) - Top-right corner radius. Defaults to `radius`.
* **bottomRightRadius** (int) - Bottom-right corner radius. Defaults to `radius`.
* **y** (int) - The y-coordinate of the region. Defaults to 0.
```

--------------------------------

### Network Signals

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Networking/Network

Signals emitted by the Network object to indicate events such as connection failures.

```APIDOC
## Network Signals

### Description
Signals emitted by the Network object to indicate events such as connection failures.

### Signals
- **connectionFailed(reason: ConnectionFailReason)**
  Signals that a connection to the network has failed because of the given `ConnectionFailReason`.
```

--------------------------------

### HyprlandEvent Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Hyprland/HyprlandEvent

Properties of the HyprlandEvent object.

```APIDOC
## Properties

### name
- **Type**: string (readonly)
- **Description**: The name of the event. Refer to the Hyprland Wiki: IPC for a list of events.
```

```APIDOC
### data
- **Type**: string (readonly)
- **Description**: The unparsed data of the event.
```

--------------------------------

### Reactive Property Binding with ObjectModel

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/ObjectModel

Directly accessing an element via `model[index]` will not update reactively. Use `model.values[index]` to ensure reactive updates.

```javascript
// will not update reactively
property var foo: model[3]
```

```javascript
// will update reactively
property var foo: model.values[3]
```

--------------------------------

### StdioCollector Signals

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/StdioCollector

Signals emitted by the StdioCollector class.

```APIDOC
## StdioCollector Signals

### `streamFinished ()`

- **Description**: Emitted when the stdio stream has finished.
```

--------------------------------

### PerformanceDegradationReason Enum Variants

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.UPower/PerformanceDegradationReason

The PerformanceDegradationReason enum includes variants like None, LapDetected, and HighTemperature, indicating different causes for performance degradation.

```APIDOC
## PerformanceDegradationReason Enum

### Description
Represents reasons for performance degradation detected by power-profiles-daemon.

### Variants
*   **None**: Performance has not been degraded in a way power-profiles-daemon can detect.
*   **LapDetected**: Performance has been reduced due to the computer’s lap detection function, which attempts to keep the computer from getting too hot while on your lap.
*   **HighTemperature**: Performance has been reduced due to high system temperatures.
```

--------------------------------

### Socket Signals

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/Socket

Signals emitted by the socket for events like errors.

```APIDOC
## Socket Signals

### `error (error)`
This signal is sent whenever a socket error is encountered.
```

--------------------------------

### DBusMenuItem.updateLayout

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.DBusMenu/DBusMenuItem

Refreshes the menu contents. This function should typically not be called manually, but can be used if applications do not update their menus correctly. The `layoutUpdated` signal will be sent when a response is received.

```APIDOC
## updateLayout()

### Description
Refreshes the menu contents. This function should typically not be called manually, but can be used if applications do not update their menus correctly. The `layoutUpdated` signal will be sent when a response is received.

### Method
`updateLayout()`

### Parameters
None

### Returns
`void`
```

--------------------------------

### WlrLayershell Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Wayland/WlrLayershell

The WlrLayershell component exposes several properties that can be configured to control the behavior and appearance of the layer-shell window.

```APIDOC
## WlrLayershell Properties

### keyboardFocus
- **Type**: WlrKeyboardFocus
- **Description**: The degree of keyboard focus taken. Defaults to `KeyboardFocus.None`.

### layer
- **Type**: WlrLayer
- **Description**: The shell layer the window sits in. Defaults to `WlrLayer.Top`.

### namespace
- **Type**: string
- **Description**: Similar to the class property of windows. Can be used to identify the window to external tools. Cannot be set after windowConnected.
```

--------------------------------

### Reference External Properties with Property Definition

Source: https://quickshell.org/docs/v0.3.0/guide/introduction

Use a Property Definition within a Scope to define properties that can be referenced from child components. This resolves ReferenceErrors when components need to access or update shared state, like a time string.

```qml
import Quickshell
import Quickshell.Io
import QtQuick

Scope {
  id: root

  // add a property in the root
  property string time

  Variants {
    model: Quickshell.screens

    delegate: Component {
      PanelWindow {
        required property var modelData
        screen: modelData

        anchors {
          top: true
          left: true
          right: true
        }

        implicitHeight: 30

        Text {
          // remove the id as we don't need it anymore

          anchors.centerIn: parent

          // bind the text to the root object's time property
          text: root.time
        }
      }
    }
  }

  Process {
    id: dateProc
    command: ["date"]
    running: true

    stdout: StdioCollector {
      // update the property instead of the clock directly
      onStreamFinished: root.time = this.text
    }
  }

  Timer {
    interval: 1000
    running: true
```

--------------------------------

### AuthFlow Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Polkit/AuthFlow

Properties of the AuthFlow object that provide information about the current authentication state.

```APIDOC
## AuthFlow Properties

### isCancelled
- **Type**: bool
- **Description**: Indicates whether the current authentication request was cancelled.

### isResponseRequired
- **Type**: bool
- **Description**: Indicates that a response from the user is required, typically a password.

### cookie
- **Type**: string
- **Description**: A cookie that identifies this authentication request. This is an internal identifier and not recommended to show to users.

### iconName
- **Type**: string
- **Description**: The icon to present to the user in association with the message. The icon name follows the FreeDesktop icon naming specification. Use Quickshell.iconPath() to resolve the icon name to an actual file path for display.

### responseVisible
- **Type**: bool
- **Description**: Indicates whether the user’s response should be visible. (e.g. for passwords this should be false).

### isCompleted
- **Type**: bool
- **Description**: Has the authentication request been completed.

### inputPrompt
- **Type**: string
- **Description**: This message is used to prompt the user for required input.

### isSuccessful
- **Type**: bool
- **Description**: Indicates whether the authentication request was successful.

### actionId
- **Type**: string
- **Description**: The action ID represents the action that is being authorized. This is a machine-readable identifier.

### supplementaryMessage
- **Type**: string
- **Description**: An additional message to present to the user. This may be used to show errors or supplementary information.

### message
- **Type**: string
- **Description**: The main message to present to the user.

### failed
- **Type**: bool
- **Description**: Indicates whether an authentication attempt has failed at least once during this authentication flow.

### identities
- **Type**: list
- **Description**: The list of identities that may be used to authenticate. Each identity may be a user or a group. You may select any of them to authenticate by setting . By default, the first identity in the list is selected.

### selectedIdentity
- **Type**: unknown
- **Description**: The identity that will be used to authenticate. Changing this will abort any ongoing authentication conversations and start a new one.

### supplementaryIsError
- **Type**: bool
- **Description**: Indicates whether the supplementary message is an error.
```

--------------------------------

### Notification Signals

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Notifications/Notification

Signals emitted by the Notification service.

```APIDOC
## Notification Signals

### Description
Signals emitted by the Notification service.

### Signals
- **closed(reason)**
  * **reason** (NotificationCloseReason) - The reason for the notification being closed.
  Sent when a notification is closed. The notification object is destroyed after all signal handlers complete.
```

--------------------------------

### MprisPlaybackState Enum

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Mpris/MprisPlaybackState

The MprisPlaybackState enum represents the playback status of a media player. It includes variants for Stopped, Playing, and Paused states.

```APIDOC
## Enum: MprisPlaybackState

### Description
Represents the playback status of a media player.

### Variants
- **Stopped**: The media is not currently playing.
- **Playing**: The media is actively playing.
- **Paused**: The media playback is paused.
```

--------------------------------

### Preventing Reload Popup

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/Quickshell

Call `inhibitReloadPopup` when handling `reloadCompleted()` or `reloadFailed()` signals to prevent the default reload popup from appearing.

```javascript
Quickshell.inhibitReloadPopup();
```

--------------------------------

### QsMenuButtonType Enum Variants

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/QsMenuButtonType

This enum defines the visual representation of menu button types. It includes variants for CheckBox, None, and RadioButton.

```APIDOC
## Variants
  * CheckBox 
This menu item should draw a checkbox.
  * None 
This menu item does not have a checkbox or a radiobutton associated with it.
  * RadioButton 
This menu item should draw a radiobutton.
```

--------------------------------

### PamError.toString()

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Pam/PamError

Converts a PamError enum value to its string representation.

```APIDOC
## Function: toString

### Signature

`toString(value: PamError): string`

### Description

Converts a given `PamError` enum value into its corresponding string representation. This is useful for logging or displaying error messages to the user.
```

--------------------------------

### Region Signals

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/Region

Details the signals emitted by the Region object, indicating changes in its child regions or geometry.

```APIDOC
## Region Signals

* **childrenChanged()** - Emitted when the child regions of this region change.
* **changed()** - Triggered when the region’s geometry changes. Can be emitted manually if automatic updates fail.
```

--------------------------------

### Notification Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Notifications/Notification

Properties of a Notification object that provide information about the notification's state and content.

```APIDOC
## Notification Properties

### Description
Properties of a Notification object that provide information about the notification's state and content.

### Properties
- **id** (int) - Readonly - The unique identifier for the notification.
- **desktopEntry** (string) - Readonly - The desktop entry name of the sender, or an empty string if none.
- **tracked** (bool) - Tracks if the notification is being monitored by the notification server. Setting to false is equivalent to calling `dismiss()`.
- **body** (string) - Readonly - The main content of the notification.
- **image** (string) - Readonly - An associated image, such as a profile picture.
- **expireTimeout** (real) - Readonly - The time in seconds before the notification expires.
- **transient** (bool) - Readonly - Indicates if the notification should bypass persistence mechanisms.
- **appName** (string) - Readonly - The name of the application that sent the notification.
- **lastGeneration** (bool) - Readonly - Indicates if the notification is from the last generation after a quickshell reload.
- **actions** (list<NotificationAction>) - Readonly - A list of available actions for the notification.
- **resident** (bool) - Readonly - If true, the notification remains after an action is invoked.
- **appIcon** (string) - Readonly - The icon of the sending application, or a fallback.
- **hints** (unknown) - Readonly - All hints provided by the client application.
- **inlineReplyPlaceholder** (string) - Readonly - Placeholder text for the inline reply input.
- **hasInlineReply** (bool) - Readonly - Indicates if the notification supports an inline reply.
- **urgency** (NotificationUrgency) - Readonly - The urgency level of the notification.
- **hasActionIcons** (bool) - Readonly - Indicates if actions have associated icons.
- **summary** (string) - Readonly - The title or summary of the notification.
```

--------------------------------

### PwLinkState Enum Variants

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Pipewire/PwLinkState

The PwLinkState enum has the following variants: Error, Unlinked, Negotiating, Init, Allocating, Paused, and Active.

```APIDOC
## Enum Variants

* **Error**
_No details provided_
* **Unlinked**
_No details provided_
* **Negotiating**
_No details provided_
* **Init**
_No details provided_
* **Allocating**
_No details provided_
* **Paused**
_No details provided_
* **Active**
_No details provided_
```

--------------------------------

### Use QML Functions in Expressions

Source: https://quickshell.org/docs/v0.3.0/guide/qml-language

QML functions can be invoked within expressions. Changes to properties that a function depends on will trigger re-evaluation of expressions that use the function.

```qml
ColumnLayout {
  property int clicks: 0

  function makeClicksLabel(): string {
    return "the button has been clicked " + clicks + " times!";
  }

  Button {
    text: "click me"
    onClicked: clicks += 1
  }

  Text {
    text: makeClicksLabel()
  }
}
```

--------------------------------

### MarginWrapperManager Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Widgets/MarginWrapperManager

MarginWrapperManager exposes several properties to control margins and resizing behavior. These properties allow for fine-grained control over the spacing and dimensions of child elements within the wrapper.

```APIDOC
## MarginWrapperManager Properties

### bottomMargin
- **Type**: real
- **Description**: The requested bottom margin of the content item, not counting extraMargin. Defaults to 0, and may be reset by assigning `undefined`.

### implicitHeight
- **Type**: real
- **Description**: Overrides the implicit height of the wrapper. Defaults to the implicit height of the content item plus its top and bottom margin, and may be reset by assigning `undefined`.

### leftMargin
- **Type**: real
- **Description**: The requested left margin of the content item, not counting extraMargin. Defaults to 0, and may be reset by assigning `undefined`.

### rightMargin
- **Type**: real
- **Description**: The requested right margin of the content item, not counting extraMargin. Defaults to 0, and may be reset by assigning `undefined`.

### implicitWidth
- **Type**: real
- **Description**: Overrides the implicit width of the wrapper. Defaults to the implicit width of the content item plus its left and right margin, and may be reset by assigning `undefined`.

### topMargin
- **Type**: real
- **Description**: The requested top margin of the content item, not counting extraMargin. Defaults to 0, and may be reset by assigning `undefined`.

### margin
- **Type**: real
- **Description**: The default for topMargin, rightMargin, bottomMargin, and leftMargin. Defaults to 0.

### resizeChild
- **Type**: bool
- **Description**: Determines if child item should be resized larger than its implicit size if the parent is resized larger than its implicit size. Defaults to true.

### extraMargin
- **Type**: real
- **Description**: An extra margin applied in addition to topMargin, rightMargin, bottomMargin, and leftMargin. Defaults to 0.
```

--------------------------------

### NotificationAction Properties

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Notifications/NotificationAction

NotificationAction has two readonly properties: identifier and text.

```APIDOC
## NotificationAction Properties

### identifier
- **Type**: string
- **Readonly**: true
- **Description**: The identifier of the action. This can be an icon name if a specific condition is met.

### text
- **Type**: string
- **Readonly**: true
- **Description**: The localized text to be displayed on a button for this action.
```

--------------------------------

### Keep a Retainable Object Alive with RetainableLock

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/RetainableLock

Use this snippet to ensure a retainable object is kept alive for the duration of the RetainableLock's existence. Set the 'object' property to the Retainable object you want to lock and 'locked' to true.

```javascript
RetainableLock {
  object: aRetainableObject
  locked: true
}
```

--------------------------------

### MprisLoopState Enum Variants

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Mpris/MprisLoopState

This snippet details the available variants for the MprisLoopState enum.

```APIDOC
## MprisLoopState: QtObject
enum
`import Quickshell.Services.Mpris`

### Variants
- **None**: Represents no loop mode.
- **Track**: Represents looping the current track.
- **Playlist**: Represents looping the entire playlist.
```

--------------------------------

### WifiSecurityType Enum Variants

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Networking/WifiSecurityType

This enum represents the different security types available for Wi-Fi networks.

```APIDOC
## Enum: WifiSecurityType

`import Quickshell.Networking`

The security type of a WifiNetwork.

### Variants

*   **DynamicWep**
*   **WpaPsk**
*   **Wpa2Psk**
*   **Unknown**
*   **Sae**
*   **Wpa3SuiteB192**
*   **Wpa2Eap**
*   **StaticWep**
*   **Leap**
*   **Owe**
*   **Open**
*   **WpaEap**
```

--------------------------------

### Add Margin to an Item

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Widgets/WrapperItem

Applies a 10px margin to all sides of a child Text item. Ensure not to set positioning properties on the child item.

```javascript
WrapperItem {
  margin: 10

  Text { text: "Hello!" }
}
```

--------------------------------

### EasingCurve.interpolate (point)

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/EasingCurve

Interpolates between two points using the given X coordinate.

```APIDOC
## interpolate (x, a, b) : point

### Description
Interpolates between two points using the given X coordinate.

### Parameters
#### Path Parameters
- **x** (real) - Required - The X coordinate for interpolation.
- **a** (point) - Required - The starting point.
- **b** (point) - Required - The ending point.

### Response
#### Success Response (200)
- **result** (point) - The interpolated point.
```

--------------------------------

### DeviceType Enum

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Networking/DeviceType

The DeviceType enum represents the type of a NetworkDevice. It includes variants for None, Wifi, and Wired connections.

```APIDOC
## Enum: DeviceType

`import Quickshell.Networking`

Type of a NetworkDevice.

### Variants

*   **None**: Represents no specific device type.
*   **Wifi**: Represents a Wi-Fi network device.
*   **Wired**: Represents a wired network device.

### Functions

*   **toString** (type: DeviceType) : string
    Converts a DeviceType enum value to its string representation.
```

--------------------------------

### FileViewError Enum Variants

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/FileViewError

This enum defines the possible error states for file view operations. Each variant provides a specific reason for an operation's failure or success.

```APIDOC
## Enum: FileViewError

`import Quickshell.Io`

Represents the possible outcomes of a file view operation.

### Variants

*   **NotAFile**
    The specified path to read/write exists and was not a file.

*   **Success**
    No error occurred.

*   **FileNotFound**
    The file to read does not exist.

*   **Unknown**
    An unknown error occurred. Check the logs for details.

*   **PermissionDenied**
    Permission to read/write the file was not granted, or permission to create parent directories was not granted when writing the file.

### Functions

*   **toString** (value: FileViewError) : string
    Converts a FileViewError variant to its string representation.
```

--------------------------------

### ConnectionState Enum Variants

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Networking/ConnectionState

The ConnectionState enum defines the possible states for a network connection.

```APIDOC
## Enum: ConnectionState

`import Quickshell.Networking`

The connection state of a device or network.

### Variants

*   **Connecting**: Represents a connection attempt in progress.
*   **Disconnected**: Represents a state where the device or network is not connected.
*   **Unknown**: Represents an indeterminate or unknown connection state.
*   **Connected**: Represents a successful and active connection.
*   **Disconnecting**: Represents a connection that is in the process of being terminated.
```

--------------------------------

### BluetoothDeviceState Enum Variants

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Bluetooth/BluetoothDeviceState

The BluetoothDeviceState enum has the following variants: Disconnected, Connected, Connecting, and Disconnecting.

```APIDOC
## Variants
  * Disconnected 
The device is not connected.
  * Connected 
The device is connected.
  * Connecting 
The device is connecting.
  * Disconnecting 
The device is disconnecting.
```

--------------------------------

### NotificationUrgency Enum

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Notifications/NotificationUrgency

The NotificationUrgency enum defines different levels of urgency for notifications.

```APIDOC
## Enum: NotificationUrgency

An enumeration representing the urgency level of a notification.

### Variants

*   **Critical**: Represents a critical notification.
*   **Low**: Represents a low-urgency notification.
*   **Normal**: Represents a normal-urgency notification.

### Functions

*   **toString (value: NotificationUrgency): string**
    Converts a NotificationUrgency value to its string representation.
```

--------------------------------

### BluetoothAdapterState Enum Variants

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Bluetooth/BluetoothAdapterState

The BluetoothAdapterState enum defines the possible states of a Bluetooth adapter.

```APIDOC
## Enum: BluetoothAdapterState

Power state of a Bluetooth adapter.

### Variants

*   **Enabling**: The adapter is transitioning from off to on.
*   **Disabling**: The adapter is transitioning from on to off.
*   **Disabled**: The adapter is powered off.
*   **Enabled**: The adapter is powered on.
*   **Blocked**: The adapter is blocked by rfkill.
```

--------------------------------

### ElapsedTimer Functions

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/ElapsedTimer

The ElapsedTimer measures time since its last restart. It is useful for determining the time between events that don’t supply it.

```APIDOC
## elapsed ()

### Description
Return the number of seconds since the timer was last started or restarted, with nanosecond precision.

### Returns
* `real`: The elapsed time in seconds.
```

```APIDOC
## elapsedMs ()

### Description
Return the number of milliseconds since the timer was last started or restarted.

### Returns
* `int`: The elapsed time in milliseconds.
```

```APIDOC
## elapsedNs ()

### Description
Return the number of nanoseconds since the timer was last started or restarted.

### Returns
* `int`: The elapsed time in nanoseconds.
```

```APIDOC
## restart ()

### Description
Restart the timer, returning the number of seconds since the timer was last started or restarted, with nanosecond precision.

### Returns
* `real`: The elapsed time in seconds since the last restart.
```

```APIDOC
## restartMs ()

### Description
Restart the timer, returning the number of milliseconds since the timer was last started or restarted.

### Returns
* `int`: The elapsed time in milliseconds since the last restart.
```

```APIDOC
## restartNs ()

### Description
Restart the timer, returning the number of nanoseconds since the timer was last started or restarted.

### Returns
* `int`: The elapsed time in nanoseconds since the last restart.
```

--------------------------------

### PamError Enum Variants

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Pam/PamError

This snippet details the variants of the PamError enum, which represent different error conditions encountered within the PAM service.

```APIDOC
## PamError Enum

`import Quickshell.Services.Pam`

### Variants

*   **StartFailed**: Failed to start the pam session.
*   **TryAuthFailed**: Failed to try to authenticate the user. This is not the same as the user failing to authenticate.
*   **InternalError**: An error occurred inside quickshell’s pam interface.
```

--------------------------------

### EasingCurve.interpolate (real)

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/EasingCurve

Interpolates between two real numbers using the given X coordinate.

```APIDOC
## interpolate (x, a, b) : real

### Description
Interpolates between two real numbers using the given X coordinate.

### Parameters
#### Path Parameters
- **x** (real) - Required - The X coordinate for interpolation.
- **a** (real) - Required - The starting real value.
- **b** (real) - Required - The ending real value.

### Response
#### Success Response (200)
- **result** (real) - The interpolated real value.
```

--------------------------------

### EasingCurve.valueAt

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/EasingCurve

Returns the Y value for the given X value on the curve.

```APIDOC
## valueAt (x) : real

### Description
Returns the Y value for the given X value on the curve, ranging from 0.0 to 1.0.

### Parameters
#### Path Parameters
- **x** (real) - Required - The X coordinate on the curve.

### Response
#### Success Response (200)
- **result** (real) - The Y value on the curve.
```

--------------------------------

### NotificationCloseReason Enum

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Notifications/NotificationCloseReason

The NotificationCloseReason enumeration specifies the various reasons a notification can be closed. This includes expiration, user dismissal, or a request from the remote application.

```APIDOC
## Enum: NotificationCloseReason

`import Quickshell.Services.Notifications`

This enum defines the reasons a notification might be closed.

### Variants

*   **Expired**: The notification expired due to a timeout.
*   **Dismissed**: The notification was explicitly dismissed by the user.
*   **CloseRequested**: The remote application requested the notification be removed.

### Functions

*   **toString (value: NotificationCloseReason) : string**
    Converts a NotificationCloseReason value to its string representation.
```

--------------------------------

### UPowerDeviceType Enum

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.UPower/UPowerDeviceType

The UPowerDeviceType enum represents different categories of devices that can be managed by UPower. It includes a function to convert these types to their string representations.

```APIDOC
## UPowerDeviceType: QtObject
enum
`import Quickshell.Services.UPower`

### Functions
* toString (type) : string
  * type: DeviceType
  * Description: Converts a DeviceType enum value to its string representation.

### Variants
* OtherAudio
* GamingInput
* Pen
* Headphones
* RemoteControl
* Pda
* Video
* Printer
* Network
* Keyboard
* Ups
* Monitor
* Camera
* Tablet
* Computer
* MediaPlayer
* Wearable
* BluetoothGeneric
* Unknown
* Mouse
* Scanner
* Touchpad
* Toy
* Speakers
* LinePower
* Phone
* Modem
* Battery
* Headset
```

--------------------------------

### PamResult Enum Variants

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Pam/PamResult

The PamResult enum defines possible outcomes of an authentication attempt.

```APIDOC
## Enum: PamResult

`import Quickshell.Services.Pam`

Represents the result of an authentication operation.

### Variants

*   **Failed**: Authentication failed.
*   **Error**: An error occurred while trying to authenticate.
*   **MaxTries**: The authentication method ran out of tries and should not be used again.
*   **Success**: Authentication was successful.
```

--------------------------------

### EasingCurve.interpolate (rect)

Source: https://quickshell.org/docs/v0.3.0/types/Quickshell/EasingCurve

Interpolates between two rectangles using the given X coordinate.

```APIDOC
## interpolate (x, a, b) : rect

### Description
Interpolates between two rectangles using the given X coordinate.

### Parameters
#### Path Parameters
- **x** (real) - Required - The X coordinate for interpolation.
- **a** (rect) - Required - The starting rectangle.
- **b** (rect) - Required - The ending rectangle.

### Response
#### Success Response (200)
- **result** (rect) - The interpolated rectangle.
```