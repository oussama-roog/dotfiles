pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

/**
 * Now-playing source for the media OSD. `active` is the player auto-tracked by
 * playback: a playing player always wins (the most recently started one
 * preferred), and while nothing plays the last one you listened to is held,
 * so a paused background tab never takes over. `announce` fires when a player
 * starts, pauses or changes track, so the OSD can flash it even when it is not
 * the active one.
 */
Singleton {
    id: root

    signal announce(var player)

    property var preferred: null
    property bool ready: false
    Component.onCompleted: ready = true

    readonly property var list: {
        var all = Mpris.players.values;
        var out = [];
        for (var i = 0; i < all.length; i++)
            if (all[i] && !isProxy(all[i]))
                out.push(all[i]);
        return out;
    }
    onListChanged: if (preferred && list.indexOf(preferred) < 0) preferred = null

    readonly property var active: {
        var l = root.list;
        if (l.length === 0)
            return null;
        if (preferred && l.indexOf(preferred) >= 0 && preferred.isPlaying)
            return preferred;
        for (var i = 0; i < l.length; i++)
            if (l[i].isPlaying && !isIdle(l[i]))
                return l[i];
        if (preferred && l.indexOf(preferred) >= 0 && !isIdle(preferred))
            return preferred;
        for (var j = 0; j < l.length; j++)
            if (!isIdle(l[j]) && l[j].trackTitle)
                return l[j];
        return l[0];
    }

    function isProxy(p) {
        return (p && p.dbusName ? p.dbusName : "").toLowerCase().indexOf("playerctld") >= 0;
    }

    function isIdle(p) {
        if (!p || isProxy(p))
            return true;
        return !p.isPlaying && (!p.trackTitle || p.trackTitle.length === 0);
    }

    function otherPlaying(self) {
        for (var i = 0; i < list.length; i++)
            if (list[i] !== self && list[i].isPlaying)
                return true;
        return false;
    }

    Instantiator {
        model: Mpris.players
        delegate: QtObject {
            required property var modelData
            readonly property bool real: modelData && !root.isProxy(modelData)
            readonly property bool playing: real ? modelData.isPlaying : false
            readonly property string title: real && modelData.trackTitle ? modelData.trackTitle : ""

            onPlayingChanged: {
                if (!root.ready)
                    return;
                if (playing) {
                    if (!root.isIdle(modelData) && !root.otherPlaying(modelData))
                        root.preferred = modelData;
                    root.announce(modelData);
                } else if (modelData === root.active) {
                    root.announce(modelData);
                }
            }
            onTitleChanged: {
                if (root.ready && playing && title.length > 0)
                    root.announce(modelData);
            }
        }
    }

    /**
     * MPRIS trackArtists arrives as an array from some players and as a plain
     * string from others (Spotify); handles both, falls back to trackArtist.
     */
    function artistsOf(artists, single) {
        if (artists && typeof artists.join === "function" && artists.length > 0)
            return artists.join(", ");
        if (artists && String(artists).length > 0)
            return String(artists);
        return single ? String(single) : "";
    }

    /** Browsers reuse one art path per video, so fold player and title in to catch a new song. */
    function keyFor(p) {
        return p ? ((p.dbusName || "") + "|" + (p.trackTitle || "") + "|" + artUrlFor(p)) : "";
    }

    /** The player's own app icon, matched off its desktop entry. */
    function appIconFor(p) {
        if (!p)
            return "";
        var id = (p.desktopEntry && p.desktopEntry.length > 0) ? p.desktopEntry : (p.identity || "");
        if (id.length === 0)
            return "";
        var apps = DesktopEntries.applications.values;
        for (var i = 0; i < apps.length; i++) {
            var e = apps[i];
            if (e && e.id && e.id.toLowerCase() === id.toLowerCase() && e.icon)
                return Quickshell.iconPath(e.icon, "application-x-executable");
        }
        return Quickshell.iconPath(id.toLowerCase(), "application-x-executable");
    }

    /** MPRIS art, else a thumbnail derived from a YouTube or Twitch page url. */
    function artUrlFor(p) {
        if (!p)
            return "";
        if (p.trackArtUrl)
            return p.trackArtUrl;
        var url = p.metadata ? (p.metadata["xesam:url"] || "") : "";
        var yt = url.match(/^https?:\/\/(?:www\.|m\.|music\.)?youtube\.com\/watch\?(?:.*&)?v=([\w-]{11})/)
            || url.match(/^https?:\/\/youtu\.be\/([\w-]{11})/);
        if (yt)
            return "https://img.youtube.com/vi/" + yt[1] + "/mqdefault.jpg";
        var tw = url.match(/^https?:\/\/(?:www\.)?twitch\.tv\/([^\/?#]+)/);
        if (tw)
            return "https://static-cdn.jtvnw.net/previews-ttv/live_user_" + tw[1].toLowerCase() + "-320x180.jpg";
        return "";
    }
}
