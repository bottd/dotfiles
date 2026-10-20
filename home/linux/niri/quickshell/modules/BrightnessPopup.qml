import QtQuick

LevelPopup {
    title: "Brightness"
    panelNamespace: "drake-brightness-popup"
    signal setBrightness(real level)
    onMoved: level => setBrightness(level)
}
