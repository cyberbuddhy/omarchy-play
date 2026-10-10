import QtQuick
import Quickshell
import qs.Ui

BarWidget {
  id: root
  moduleName: "io.github.cyberbuddhy.omarchy-play"

  // No details panel: this widget drives the `play` CLI directly.
  // `opened` stays false; open()/toggle() summon the play prompt so
  // `omarchy-shell shell summon` routes somewhere useful.
  readonly property bool opened: false
  readonly property bool popoutSwitchClosing: false

  function prompt() {
    if (root.bar) root.bar.run("play --prompt")
  }

  function open() {
    root.prompt()
  }

  function close() {
  }

  function toggle() {
    root.prompt()
  }

  function closeForPopoutSwitch() {
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: ""
    tooltipText: "Play music (left: prompt, right: pause/resume, middle: stop)"
    onPressed: function(buttonCode) {
      if (!root.bar) return
      if (buttonCode === Qt.RightButton) root.bar.run("play --toggle")
      else if (buttonCode === Qt.MiddleButton) root.bar.run("play --stop")
      else root.prompt()
    }
  }
}
