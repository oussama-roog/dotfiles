pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

/**
 * CPU and RAM usage for the rest pill. Polls /proc every 2s. CPU load is a
 * two-sample delta of /proc/stat (busy vs total jiffies); memory is
 * MemTotal - MemAvailable from /proc/meminfo.
 */
Singleton {
    id: root

    property int cpu: 0
    property int memPct: 0
    property real memUsedGb: 0
    property real memTotalGb: 0

    property real prevCpuTotal: 0
    property real prevCpuIdle: 0

    Process {
        id: proc
        command: ["sh", "-c",
            "read -r _ a b c d e f g h _ < /proc/stat; echo \"CPU $((a+b+c+d+e+f+g+h)) $((d+e))\"; "
            + "awk '/^MemTotal:/{mt=$2}/^MemAvailable:/{ma=$2}END{print \"MEM\",mt,ma}' /proc/meminfo"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.split("\n");
                for (var i = 0; i < lines.length; i++) {
                    var p = lines[i].trim().split(/\s+/);
                    if (p[0] === "CPU") {
                        var total = parseFloat(p[1]);
                        var idle = parseFloat(p[2]);
                        if (root.prevCpuTotal > 0) {
                            var dt = total - root.prevCpuTotal;
                            var di = idle - root.prevCpuIdle;
                            root.cpu = dt > 0 ? Math.max(0, Math.min(100, Math.round(100 * (dt - di) / dt))) : 0;
                        }
                        root.prevCpuTotal = total;
                        root.prevCpuIdle = idle;
                    } else if (p[0] === "MEM") {
                        var mt = parseFloat(p[1]);
                        var ma = parseFloat(p[2]);
                        root.memTotalGb = mt / 1048576;
                        root.memUsedGb = (mt - ma) / 1048576;
                        root.memPct = mt > 0 ? Math.round(100 * (mt - ma) / mt) : 0;
                    }
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!proc.running) proc.running = true
    }
}
