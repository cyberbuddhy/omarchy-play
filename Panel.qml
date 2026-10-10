import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

Panel {
  id: root
  moduleName: "io.github.cyberbuddhy.omarchy-play"
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null
  property string provider: "ytmusic"
  property string nowPlaying: "Nothing playing."

  function open() {
    root.controller.show()
  }

  function close() {
    root.controller.hide()
  }

  function switchPanel(direction) {
    if (root.bar && typeof root.bar.switchPanelFrom === "function")
      return root.bar.switchPanelFrom(root.hostWidget || root, direction)
    return false
  }

  function shellQuote(s) {
    return "'" + String(s).replace(/'/g, "'\\''") + "'"
  }

  function playQuery(q) {
    var query = String(q || "").trim()
    if (query === "") return
    if (root.bar) root.bar.run("play --provider " + root.provider + " " + root.shellQuote(query))
    Qt.callLater(root.refresh)
  }

  function control(action) {
    if (root.bar) root.bar.run("play --provider " + root.provider + " " + action)
    Qt.callLater(root.refresh)
  }

  function saveProvider(value) {
    root.provider = value
    if (root.bar) root.bar.run("mkdir -p ~/.config/play && echo " + value + " > ~/.config/play/provider")
  }

  function refresh() {
    if (!providerProc.running) providerProc.running = true
    if (!stateProc.running) stateProc.running = true
  }

  onOpenedChanged: if (opened) root.refresh()

  // Poll while open so pause/skips from elsewhere show up.
  Timer {
    interval: 5000
    running: root.opened
    repeat: true
    onTriggered: root.refresh()
  }

  Process {
    id: providerProc
    command: ["bash", "-c", "cat ~/.config/play/provider 2>/dev/null || echo ytmusic"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var v = String(text || "").trim()
        root.provider = (v === "spotify") ? "spotify" : "ytmusic"
      }
    }
  }

  Process {
    id: stateProc
    command: ["bash", "-c", "cat ~/.local/state/play/current 2>/dev/null | cut -f1"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var title = String(text || "").trim()
        root.nowPlaying = (title !== "") ? title : "Nothing playing."
      }
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.hostWidget || root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(300))
    contentHeight: panel.fittedContentHeight(content.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Column {
        id: content
        width: parent.width
        spacing: Style.space(10)

        Text {
          width: parent.width
          text: "Play"
          color: root.barForeground
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.subtitle
          font.bold: true
        }

        Text {
          width: parent.width
          textFormat: Text.PlainText
          text: root.nowPlaying
          color: root.barForeground
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.body
          elide: Text.ElideRight
          maximumLineCount: 2
          wrapMode: Text.WordWrap
        }

        TextField {
          id: searchField
          width: parent.width
          placeholderText: "Artist, song, album, mood…"
          onAccepted: {
            root.playQuery(text)
            text = ""
          }
        }

        Row {
          width: parent.width
          spacing: Style.space(6)

          Button {
            width: (parent.width - Style.space(18)) / 4
            text: "⏮"
            tooltipText: "Previous track"
            onClicked: root.control("--prev")
          }

          Button {
            width: (parent.width - Style.space(18)) / 4
            text: "⏯"
            tooltipText: "Pause / resume"
            onClicked: root.control("--toggle")
          }

          Button {
            width: (parent.width - Style.space(18)) / 4
            text: "⏭"
            tooltipText: "Next track"
            onClicked: root.control("--next")
          }

          Button {
            width: (parent.width - Style.space(18)) / 4
            text: "⏹"
            tooltipText: "Stop"
            onClicked: root.control("--stop")
          }
        }

        Dropdown {
          width: parent.width
          label: "PROVIDER"
          value: root.provider
          options: [
            { value: "ytmusic", label: "YouTube Music (free)" },
            { value: "spotify", label: "Spotify (app or web)" }
          ]
          onChanged: function(value) { root.saveProvider(value) }
        }
      }
    }
  }
}
