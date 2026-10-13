pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

/**
 * CPU and RAM usage for the rest pill, read straight from /proc every 2s (no
 * subprocess). CPU load is a two-sample delta of /proc/stat's first line
 * (busy vs total jiffies); memory is MemTotal - MemAvailable.
 */
Singleton {
    id: root

    property int cpu: 0
    property int memPct: 0
    property real memUsedGb: 0

    property real prevTotal: 0
    property real prevIdle: 0

    FileView {
        id: stat
        path: "/proc/stat"
        onLoaded: {
            // cpu  user nice system idle iowait irq softirq steal ...
            const f = text().split("\n", 1)[0].trim().split(/\s+/).slice(1, 9).map(Number);
            const total = f.reduce((a, b) => a + b, 0);
            const idle = f[3] + f[4];
            const dt = total - root.prevTotal;
            if (root.prevTotal > 0 && dt > 0)
                root.cpu = Math.max(0, Math.min(100, Math.round(100 * (dt - (idle - root.prevIdle)) / dt)));
            root.prevTotal = total;
            root.prevIdle = idle;
        }
    }

    FileView {
        id: meminfo
        path: "/proc/meminfo"
        onLoaded: {
            const kb = (key) => Number((text().match(new RegExp("^" + key + ":\\s+(\\d+)", "m")) || [0, 0])[1]);
            const total = kb("MemTotal");
            const used = total - kb("MemAvailable");
            root.memUsedGb = used / 1048576;
            root.memPct = total > 0 ? Math.round(100 * used / total) : 0;
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            stat.reload();
            meminfo.reload();
        }
    }
}
