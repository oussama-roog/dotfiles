pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.UPower

/** Laptop battery from UPower's display device; `present` is false on a desktop. */
Singleton {
    readonly property var dev: UPower.displayDevice
    readonly property bool present: dev !== null && dev.ready && dev.isLaptopBattery && dev.isPresent
    readonly property real frac: dev ? Math.max(0, Math.min(1, dev.percentage)) : 0
    readonly property int pct: Math.round(frac * 100)
    readonly property bool charging: dev ? dev.state === UPowerDeviceState.Charging : false
}
