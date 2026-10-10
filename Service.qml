import QtQuick
import Quickshell
import Quickshell.Io

// Headless service: on load it runs the bundled setup.sh once, which
// installs the `play` binary, merges the Super+Space menu entries, and
// writes the default provider. Everything is idempotent, so enabling the
// plugin is the entire installation — there is nothing else to run.
Item {
  id: root
  property var shell: null

  readonly property string pluginDir: Quickshell.env("HOME") + "/.config/omarchy/plugins/io.github.cyberbuddhy.omarchy-play"

  Component.onCompleted: {
    if (!setupProc.running) setupProc.running = true
  }

  Process {
    id: setupProc
    command: ["bash", root.pluginDir + "/setup.sh", root.pluginDir]
    stdout: StdioCollector { waitForEnd: true }
  }
}
