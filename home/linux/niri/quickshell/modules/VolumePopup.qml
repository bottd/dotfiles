import QtQuick

LevelPopup {
    title: "Volume"
    panelNamespace: "drake-volume-popup"
    showMute: true
    signal setVolume(real level)
    onMoved: level => setVolume(level)
}
