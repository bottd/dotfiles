import QtQuick

// Layer effect that prints a surface onto the screen through the same 8x8
// Bayer dither and plate fringe as niri's window open/close shaders
// (home/linux/niri/shaders.nix). progress runs 0 -> 1 for both directions.
ShaderEffect {
    property real progress: 1
    property real closing: 0
    property size extent: Qt.size(width, height)

    fragmentShader: Qt.resolvedUrl("press-print.frag.qsb")
}
