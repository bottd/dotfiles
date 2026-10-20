import QtQuick

// A band of ordered-dither cells whose coverage ramps from empty at the top
// to solid at the bottom, so a solid surface below it breaks up into
// halftone. Each row uses all 16 thresholds so even a three-row band fades.
Canvas {
    id: root

    required property color color
    property int cell: 2

    readonly property var bayer: [0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5]

    renderStrategy: Canvas.Cooperative
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onColorChanged: requestPaint()
    onCellChanged: requestPaint()

    onPaint: {
        const ctx = getContext("2d");
        ctx.reset();
        ctx.fillStyle = root.color;

        const columns = Math.ceil(width / root.cell);
        const rows = Math.max(1, Math.ceil(height / root.cell));
        for (let row = 0; row < rows; ++row) {
            // Row centre coverage, so the top row is sparse but never empty.
            const coverage = (row + 0.5) / rows;
            for (let column = 0; column < columns; ++column) {
                const threshold = (root.bayer[(column + row * 5) % 16] + 0.5) / 16;
                if (threshold < coverage)
                    ctx.fillRect(column * root.cell, row * root.cell, root.cell, root.cell);
            }
        }
    }
}
