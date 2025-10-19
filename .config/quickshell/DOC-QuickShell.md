# Quickshell

Quickshell is a QML-based framework for building custom desktop shells, widgets, and panels for Linux window managers and compositors. It provides a declarative, reactive approach to creating graphical interfaces that integrate deeply with system services and window management protocols. Built on Qt and QML, Quickshell enables developers to construct complex UI components using JavaScript-like syntax while leveraging Qt's robust widget system and event handling.

The framework supports both X11 and Wayland environments, offering extensive integration with compositor-specific features like Hyprland IPC, i3 workspaces, and wlroots layer shell. Quickshell includes built-in services for system tray management, MPRIS media control, notification servers, Bluetooth, PipeWire audio, and UPower battery information. Configuration files live-reload during development, making rapid prototyping straightforward, while the Singleton pattern and reactive bindings ensure efficient state management across multiple windows and monitors.

## Creating a Basic Panel Window

Panel window attached to screen edges with automatic multi-monitor support.

```qml
import Quickshell
import QtQuick

// Create a bar on every connected screen
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

    margins {
      top: 10
      left: 10
      right: 10
    }

    implicitHeight: 40

    // Reserve screen space for the window
    exclusiveZone: 40

    // Make it keyboard focusable
    focusable: true

    // Render above normal windows
    aboveWindows: true

    Rectangle {
      anchors.fill: parent
      color: "#1e1e2e"

      Text {
        anchors.centerIn: parent
        text: "Status Bar"
        color: "#cdd6f4"
      }
    }
  }
}
```

## Running External Processes

Execute commands and capture output with reactive stream handling.

```qml
import Quickshell
import Quickshell.Io
import QtQuick

Scope {
  id: root
  property string cpuUsage: "..."

  Process {
    id: cpuProc
    command: ["sh", "-c", "top -bn1 | grep 'Cpu(s)' | awk '{print $2}'"]
    running: true

    // Clear environment variables
    clearEnvironment: false

    // Set working directory
    workingDirectory: Quickshell.workingDirectory

    // Custom environment
    environment: ({
      LANG: "C",
      PATH: "/usr/bin:/bin"
    })

    stdout: StdioCollector {
      onStreamFinished: {
        root.cpuUsage = this.text.trim() + "%"
      }
    }

    stderr: StdioCollector {
      onStreamFinished: {
        if (this.text !== "") {
          console.error("CPU check error:", this.text)
        }
      }
    }

    onExited: (exitCode, exitStatus) => {
      console.log("Process exited:", exitCode)
    }
  }

  Timer {
    interval: 2000
    running: true
    repeat: true
    onTriggered: cpuProc.running = true
  }

  PanelWindow {
    anchors.bottom: true
    implicitHeight: 30

    Text {
      text: "CPU: " + root.cpuUsage
      anchors.centerIn: parent
    }
  }
}
```

## System Clock Integration

Display formatted time with automatic updates at configurable intervals.

```qml
import Quickshell
import QtQuick

PanelWindow {
  anchors.top: true
  implicitHeight: 35

  SystemClock {
    id: clock
    // Update every second (Hours, Minutes, or Seconds)
    precision: SystemClock.Seconds
    enabled: true
  }

  Row {
    anchors.centerIn: parent
    spacing: 20

    Text {
      // Full date and time
      text: Qt.formatDateTime(clock.date, "ddd MMM d hh:mm:ss AP yyyy")
      color: "#cdd6f4"
    }

    Text {
      // Custom format with individual properties
      text: `${clock.hours.toString().padStart(2, '0')}:${clock.minutes.toString().padStart(2, '0')}:${clock.seconds.toString().padStart(2, '0')}`
      color: "#89b4fa"
      font.bold: true
    }
  }
}
```

## Singleton Service Pattern

Create reusable service singletons accessible from any component.

```qml
// BatteryService.qml
pragma Singleton
import Quickshell
import Quickshell.Services.UPower

Singleton {
  id: root

  property real percentage: displayDevice.percentage
  property bool charging: displayDevice.state === UPowerDeviceState.Charging
  property int timeRemaining: charging ? displayDevice.timeToFull : displayDevice.timeToEmpty

  readonly property UPowerDevice displayDevice: UPower.displayDevice

  function formatTime(seconds) {
    const hours = Math.floor(seconds / 3600)
    const mins = Math.floor((seconds % 3600) / 60)
    return `${hours}h ${mins}m`
  }
}

// shell.qml
import Quickshell
import QtQuick

PanelWindow {
  anchors.bottom: true
  implicitHeight: 30

  Row {
    anchors.centerIn: parent
    spacing: 10

    Text {
      text: `🔋 ${Math.round(BatteryService.percentage)}%`
      color: BatteryService.charging ? "#a6e3a1" : "#f38ba8"
    }

    Text {
      text: BatteryService.charging ? "Charging" : BatteryService.formatTime(BatteryService.timeRemaining)
      color: "#cdd6f4"
    }
  }
}
```

## MPRIS Media Player Control

Track and control media players via MPRIS interface.

```qml
import Quickshell
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Controls

PanelWindow {
  anchors.bottom: true
  implicitHeight: 60

  // Get first available player (or null)
  property var player: Mpris.players.values[0] ?? null

  Row {
    anchors.centerIn: parent
    spacing: 15
    enabled: player !== null

    Image {
      width: 48
      height: 48
      source: player?.metadata.artUrl ?? ""
      fillMode: Image.PreserveAspectFit
    }

    Column {
      spacing: 5

      Text {
        text: player?.metadata.title ?? "No media"
        font.bold: true
        color: "#cdd6f4"
      }

      Text {
        text: player?.metadata.artist ?? ""
        color: "#a6adc8"
      }
    }

    Row {
      spacing: 8

      Button {
        text: "⏮"
        onClicked: player?.previous()
      }

      Button {
        text: player?.playbackState === MprisPlaybackState.Playing ? "⏸" : "▶"
        onClicked: player?.togglePlaying()
      }

      Button {
        text: "⏭"
        onClicked: player?.next()
      }
    }

    Slider {
      width: 200
      from: 0
      to: player?.length ?? 0
      value: player?.position ?? 0

      onMoved: {
        if (player) player.position = value
      }
    }
  }

  // Update position every second
  Timer {
    interval: 1000
    running: player?.playbackState === MprisPlaybackState.Playing
    repeat: true
    onTriggered: {
      // Trigger property update
      if (player) player.position = player.position
    }
  }
}
```

## System Tray Implementation

Display and interact with system tray icons.

```qml
import Quickshell
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts

PanelWindow {
  anchors.right: true
  implicitWidth: trayRow.implicitWidth + 20

  RowLayout {
    id: trayRow
    anchors.centerIn: parent
    spacing: 8

    Repeater {
      model: SystemTray.items

      delegate: Item {
        required property SystemTrayItem modelData

        width: 24
        height: 24

        Image {
          anchors.fill: parent
          source: modelData.icon

          MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

            onClicked: (mouse) => {
              if (mouse.button === Qt.LeftButton) {
                modelData.activate()
              } else if (mouse.button === Qt.RightButton) {
                modelData.menu()
              } else if (mouse.button === Qt.MiddleButton) {
                modelData.secondaryActivate()
              }
            }

            onWheel: (wheel) => {
              modelData.scroll(wheel.angleDelta.y, "vertical")
            }
          }

          ToolTip.visible: mouseArea.containsMouse
          ToolTip.text: modelData.tooltip
        }
      }
    }
  }
}
```

## Notification Server

Implement Desktop Notifications Specification to receive notifications.

```qml
import Quickshell
import Quickshell.Services.Notifications
import QtQuick

Scope {
  NotificationServer {
    id: notifServer

    // Advertise capabilities
    bodySupported: true
    bodyMarkupSupported: true
    bodyHyperlinksSupported: true
    bodyImagesSupported: true
    actionsSupported: true
    actionIconsSupported: true
    imageSupported: true
    persistenceSupported: true
    inlineReplySupported: false

    // Extra capability hints
    extraHints: ["x-quickshell-custom"]

    // Keep notifications on reload
    keepOnReload: true

    onNotification: (notification) => {
      notification.tracked = true
      console.log("Notification:", notification.summary)
    }
  }

  Column {
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.margins: 10
    spacing: 10
    width: 350

    Repeater {
      model: notifServer.trackedNotifications

      delegate: Rectangle {
        required property Notification modelData

        width: parent.width
        height: content.height + 20
        color: "#1e1e2e"
        radius: 8
        border.color: "#45475a"
        border.width: 1

        Column {
          id: content
          anchors.centerIn: parent
          width: parent.width - 20
          spacing: 8

          Row {
            spacing: 10

            Image {
              width: 32
              height: 32
              source: modelData.image || modelData.icon || ""
            }

            Column {
              Text {
                text: modelData.summary
                font.bold: true
                color: "#cdd6f4"
              }

              Text {
                text: modelData.body
                wrapMode: Text.Wrap
                color: "#a6adc8"
                textFormat: Text.StyledText
              }
            }
          }

          Row {
            spacing: 8

            Repeater {
              model: modelData.actions

              delegate: Button {
                required property NotificationAction modelData
                text: modelData.text
                onClicked: {
                  modelData.invoke()
                  parent.modelData.dismiss()
                }
              }
            }

            Button {
              text: "Dismiss"
              onClicked: modelData.dismiss()
            }
          }
        }
      }
    }
  }
}
```

## Hyprland Integration

Access Hyprland compositor state and control via IPC.

```qml
import Quickshell
import Quickshell.Hyprland
import QtQuick

PanelWindow {
  anchors.bottom: true
  implicitHeight: 40

  Row {
    anchors.centerIn: parent
    spacing: 5

    // Workspace buttons
    Repeater {
      model: Hyprland.workspaces

      delegate: Rectangle {
        required property HyprlandWorkspace modelData

        width: 30
        height: 30
        radius: 4

        color: modelData === Hyprland.focusedWorkspace ? "#89b4fa" : "#313244"
        border.color: "#45475a"
        border.width: 1

        Text {
          anchors.centerIn: parent
          text: modelData.id.toString()
          color: modelData === Hyprland.focusedWorkspace ? "#1e1e2e" : "#cdd6f4"
          font.bold: true
        }

        MouseArea {
          anchors.fill: parent
          onClicked: Hyprland.dispatch(`workspace ${modelData.id}`)
        }
      }
    }

    Rectangle {
      width: 2
      height: 30
      color: "#45475a"
    }

    // Active window title
    Text {
      text: Hyprland.activeToplevel?.title ?? "No active window"
      color: "#cdd6f4"
      anchors.verticalCenter: parent.verticalCenter
    }
  }

  // Listen for raw Hyprland events
  Connections {
    target: Hyprland

    function onRawEvent(event) {
      console.log(`Hyprland event: ${event.name}`)
      if (event.name === "workspace") {
        console.log(`Switched to workspace: ${event.data}`)
      }
    }
  }

  Component.onCompleted: {
    // Force refresh if needed (some events don't auto-update)
    Hyprland.refreshWorkspaces()
    Hyprland.refreshMonitors()
    Hyprland.refreshToplevels()
  }
}
```

## Reactive Property Bindings

Leverage QML's reactive system for automatic UI updates.

```qml
import Quickshell
import QtQuick

Scope {
  id: root

  // Properties update dependents automatically
  property int counter: 0
  property bool isEven: counter % 2 === 0
  property string status: isEven ? "Even" : "Odd"

  // Multi-line reactive expression
  property string message: {
    const val = counter
    const parity = isEven ? "even" : "odd"
    return `Counter is ${val} (${parity})`
  }

  PanelWindow {
    anchors.bottom: true
    implicitHeight: 80

    Column {
      anchors.centerIn: parent
      spacing: 10

      Text {
        // Automatically updates when message changes
        text: root.message
        color: root.isEven ? "#a6e3a1" : "#f38ba8"
        font.pixelSize: 16
      }

      Button {
        text: "Increment"
        onClicked: root.counter++
      }

      Button {
        text: "Reset"
        onClicked: root.counter = 0
      }

      // Create manual binding at runtime
      Button {
        id: dynamicButton
        text: "Create Binding"

        onClicked: {
          dynamicButton.text = Qt.binding(() => `Count: ${root.counter}`)
        }
      }
    }
  }

  // React to property changes with signal handlers
  onCounterChanged: {
    console.log("Counter changed to:", counter)
  }
}
```

## File System Operations and Environment Access

Read files, manage paths, and access environment variables.

```qml
import Quickshell
import Quickshell.Io
import QtQuick

Scope {
  id: root

  // Access environment variables
  property string home: Quickshell.env("HOME") ?? "/home/user"
  property string editor: Quickshell.env("EDITOR") ?? "vim"

  // Path helpers
  property string shellConfigPath: Quickshell.shellDir
  property string dataPath: Quickshell.dataPath("app-state.json")
  property string cachePath: Quickshell.cachePath("cache.db")
  property string statePath: Quickshell.statePath("session.json")

  // Read file contents
  FileView {
    id: configFile
    path: shellConfigPath + "/config.json"

    onPathChanged: {
      if (configFile.exists) {
        const content = configFile.text
        const data = JSON.parse(content)
        console.log("Config loaded:", data)
      }
    }
  }

  // Watch file for changes
  FileView {
    id: watchedFile
    path: home + "/.config/status"

    onTextChanged: {
      console.log("File updated:", this.text)
    }
  }

  // Launch detached process (survives Quickshell restart)
  Component.onCompleted: {
    Quickshell.execDetached({
      command: ["notify-send", "Quickshell Started"],
      environment: {
        DISPLAY: Quickshell.env("DISPLAY")
      },
      workingDirectory: home
    })
  }

  PanelWindow {
    anchors.top: true
    implicitHeight: 30

    Text {
      text: `Shell: ${root.shellConfigPath} | Editor: ${root.editor}`
      anchors.centerIn: parent
      color: "#cdd6f4"
    }
  }
}
```

## Summary

Quickshell excels at building Linux desktop shells and widgets through its declarative QML syntax and deep system integration. The framework's primary use cases include creating status bars with workspace indicators, system monitors, media players, notification popups, and dock-style launchers. Developers can rapidly prototype using live configuration reloading while maintaining clean code through reactive bindings and property-driven design. The Variants system simplifies multi-monitor setups by automatically instantiating components per screen.

Integration patterns follow Qt's established paradigms: create Singleton services for shared state, use Process objects for system command interaction, leverage ObjectModel types for dynamic collections, and implement signal handlers for event-driven updates. Quickshell supports both platform-agnostic PanelWindow components and compositor-specific extensions like WlrLayershell for Wayland-specific features. The framework's built-in services cover common shell requirements—system tray, MPRIS, notifications, Bluetooth, audio routing, and power management—while the Io module provides sockets, IPC, and JSON parsing for custom integrations.
